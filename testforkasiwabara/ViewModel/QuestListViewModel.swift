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
    @Published var dailyQuestBoard: [DailyQuestBoard] = []
    
    // 依存サービス
//    private let questService: QuestServiceProtocol
    private let appDataService: AppDataServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // 依存性注入を使用したイニシャライザ
    init(appDataService: AppDataServiceProtocol = AppDataService()) {
//        self.questService = questService
        self.appDataService = appDataService
        
        // QuestServiceからのデータを購読
//        questService.questSlotsPublisher
//            .receive(on: RunLoop.main)
//            .assign(to: \.questSlots, on: self)
//            .store(in: &cancellables)

        appDataService.dailyQuestBoardPubisher
            .receive(on: RunLoop.main)
            .assign(to: \.dailyQuestBoard, on: self)
            .store(in: &cancellables)

        // 特定のtaskに変更があった時、dailyQuestBoardが更新されたことにする
        // appDataService.tasksPublisher
        //     .receive(on: RunLoop.main)
        //     .sink { [weak self] tasks in
        //         guard let self = self else { return }
        //         self.dailyQuestBoard = self.appDataService.dailyQuestBoard
        //     }
        //     .store(in: &cancellables)
    }
    
    func editTaskTest(taskId: UUID, newText: String) {
        appDataService.editTask(taskId: taskId, newText: newText)
        print(dailyQuestBoard[0].questSlots[0].quest.tasks[0].text)
    }
    
    // クエストを受注する
//    func acceptQuest(questSlotId: UUID) {
//        questService.acceptQuest(questSlotId: questSlotId)
//    }
//
//    // チケットを使用する
//    func redeemTicket(questSlotId: UUID) {
//        questService.redeemTicket(questSlotId: questSlotId)
//    }
//    
//    // タスクの進捗状況を計算
//    func taskProgress(for questSlot: QuestSlot) -> String {
//        if let acceptedQuest = questSlot.acceptedQuest {
//            let completedCount = acceptedQuest.acceptedTasks.filter { $0.isCompleted }.count
//            let totalCount = acceptedQuest.acceptedTasks.count
//            return "\(completedCount)/\(totalCount)"
//        } else {
//            return "0/\(questSlot.quest.tasks.count)"
//        }
//    }
//    
//    // QuestDetailsViewModelを作成
//    func createDetailsViewModel(for questSlotId: UUID) -> QuestDetailsViewModel {
//        return QuestDetailsViewModel(questService: questService, questSlotId: questSlotId)
//    }
}
