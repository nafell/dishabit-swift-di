//
//  QuestDetailsViewModel.swift
//  testforkasiwabara
//
//  Created by 長峯幸佑 on 2025/03/06.
//

import Foundation
import Combine

class QuestDetailsViewModel: ObservableObject {
    // 公開プロパティ
    @Published var questSlot: QuestSlot?
    @Published var isQuestAccepted: Bool = false
    
    // 依存サービス
    private let questService: QuestServiceProtocol
    private let questSlotId: UUID
    private var cancellables = Set<AnyCancellable>()
    
    // 依存性注入を使用したイニシャライザ
    init(questService: QuestServiceProtocol, questSlotId: UUID) {
        self.questService = questService
        self.questSlotId = questSlotId
        
        // 特定のQuestSlotを購読
        questService.questSlotPublisher(for: questSlotId)
            .receive(on: RunLoop.main)
            .sink { [weak self] questSlot in
                guard let self = self, let questSlot = questSlot else { return }
                self.questSlot = questSlot
                self.isQuestAccepted = questSlot.acceptedQuest != nil
            }
            .store(in: &cancellables)
    }
    
    // クエストを受注する
    func acceptQuest() {
        questService.acceptQuest(questSlotId: questSlotId)
    }
    
    // タスクの完了状態を切り替える
    func toggleTaskCompletion(taskId: UUID) {
        questService.toggleTaskCompletion(questSlotId: questSlotId, taskId: taskId)
    }
    
    // クエスト完了を報告する
    func reportQuestCompletion() {
        questService.reportQuestCompletion(questSlotId: questSlotId)
    }
    
    // 報酬を受け取る
    func redeemReward() {
        questService.redeemReward(questSlotId: questSlotId)
    }
    
    // タスクの進捗状況を計算
    var taskProgress: String {
        guard let questSlot = questSlot else { return "0/0" }
        
        if let acceptedQuest = questSlot.acceptedQuest {
            let completedCount = acceptedQuest.acceptedTasks.filter { $0.isCompleted }.count
            let totalCount = acceptedQuest.acceptedTasks.count
            return "\(completedCount)/\(totalCount)"
        } else {
            return "0/\(questSlot.quest.tasks.count)"
        }
    }
    
    // クエストが完了しているか
    var isAllTasksCompleted: Bool {
        questSlot?.acceptedQuest?.isAllTaskCompleted ?? false
    }
    
    // 報酬が受け取り済みか
    var isRewardRedeemed: Bool {
        questSlot?.acceptedQuest?.reward.isRedeemed ?? false
    }
}
