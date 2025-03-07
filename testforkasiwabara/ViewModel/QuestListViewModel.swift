//
//  QuestListViewModel.swift
//  testforkasiwabara
//
//  Created by 長峯幸佑 on 2025/03/06.
//

import Foundation
import Combine

class QuestListViewModel: ObservableObject {
    // 公開プロパティ
    @Published var questSlots: [QuestSlot] = []
    
    // 依存サービス
    private let questService: QuestServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // 依存性注入を使用したイニシャライザ
    init(questService: QuestServiceProtocol = QuestService()) {
        self.questService = questService
        
        // QuestServiceからのデータを購読
        questService.questSlotsPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.questSlots, on: self)
            .store(in: &cancellables)
    }
    
    // クエストを受注する
    func acceptQuest(questSlotId: String) {
        questService.acceptQuest(questSlotId: questSlotId)
    }

    // チケットを使用する
    func redeemTicket(questSlotId: String) {
        questService.redeemTicket(questSlotId: questSlotId)
    }
    
    // タスクの進捗状況を計算
    func taskProgress(for questSlot: QuestSlot) -> String {
        if let acceptedQuest = questSlot.acceptedQuest {
            let completedCount = acceptedQuest.acceptedTasks.filter { $0.isCompleted }.count
            let totalCount = acceptedQuest.acceptedTasks.count
            return "\(completedCount)/\(totalCount)"
        } else {
            return "0/\(questSlot.quest.tasks.count)"
        }
    }
    
    // QuestDetailsViewModelを作成
    func createDetailsViewModel(for questSlotId: String) -> QuestDetailsViewModel {
        return QuestDetailsViewModel(questService: questService, questSlotId: questSlotId)
    }
}
