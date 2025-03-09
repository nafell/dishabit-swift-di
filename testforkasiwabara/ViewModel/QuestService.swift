//
//  QuestService.swift
//  testforkasiwabara
//
//  Created by 長峯幸佑 on 2025/03/06.
//

import Foundation
import Combine
@testable import testforkasiwabara

// QuestServiceプロトコル - 依存性注入のためのインターフェース
protocol QuestServiceProtocol {
    // 現在のQuestSlotsを取得するPublisher
    var questSlotsPublisher: AnyPublisher<[QuestSlot], Never> { get }
    
    // 特定のQuestSlotを取得するPublisher
    func questSlotPublisher(for id: UUID) -> AnyPublisher<QuestSlot?, Never>
    
    // クエストを受注する
    func acceptQuest(questSlotId: UUID)
    
    // チケットを使用する
    func redeemTicket(questSlotId: UUID)
    
    // タスクの完了状態を切り替える
    func toggleTaskCompletion(questSlotId: UUID, taskId: UUID)
    
    // クエスト完了を報告する
    func reportQuestCompletion(questSlotId: UUID)
    
    // 報酬を受け取る
    func redeemReward(questSlotId: UUID)
}

// QuestServiceの実装
class QuestService: QuestServiceProtocol {
    // 内部状態
    private let questSlotsSubject = CurrentValueSubject<[QuestSlot], Never>([])
    
    // 公開するPublisher
    var questSlotsPublisher: AnyPublisher<[QuestSlot], Never> {
        questSlotsSubject.eraseToAnyPublisher()
    }
    
    init() {
        loadSampleData()
    }
    
    // 特定のQuestSlotを取得するPublisher
    func questSlotPublisher(for id: UUID) -> AnyPublisher<QuestSlot?, Never> {
        return questSlotsPublisher
            .map { questSlots in
                questSlots.first { $0.id == id }
            }
            .eraseToAnyPublisher()
    }
    
    // サンプルデータのロード
    private func loadSampleData() {
        // サンプルデータの作成
        let tasks1 = [
            Task(id: UUID(), text: "タスク1", objective: Objective(id: UUID(), text: "目標1")),
            Task(id: UUID(), text: "タスク2", objective: Objective(id: UUID(), text: "目標2")),
            Task(id: UUID(), text: "タスク3", objective: nil),
            Task(id: UUID(), text: "タスク4", objective: nil)
        ]
        
        let tasks2 = [
            Task(id: UUID(), text: "タスク5", objective: Objective(id: UUID(), text: "目標3")),
            Task(id: UUID(), text: "タスク6", objective: nil),
            Task(id: UUID(), text: "タスク7", objective: nil)
        ]
        
        let quest1 = Quest(
            id: UUID(),
            title: "最初のクエスト",
            reward: Reward(id: UUID(), text: "アイスクリーム"),
            tasks: tasks1
        )
        
        let quest2 = Quest(
            id: UUID(),
            title: "2番目のクエスト",
            reward: Reward(id: UUID(), text: "映画鑑賞"),
            tasks: tasks2
        )
        
        let questSlots = [
            QuestSlot(id: UUID(), quest: quest1, acceptedQuest: nil),
            QuestSlot(id: UUID(), quest: quest2, acceptedQuest: nil)
        ]
        
        questSlotsSubject.send(questSlots)
    }
    
    // クエストを受注する
    func acceptQuest(questSlotId: UUID) {
        updateQuestSlot(questSlotId) { questSlot in
            questSlot.acceptQuest()
        }
    }
    
    // チケットを使用する
    func redeemTicket(questSlotId: UUID) {
        updateQuestSlot(questSlotId) { questSlot in
            guard let acceptedQuest = questSlot.acceptedQuest else { return questSlot }
            
            let updatedAcceptedQuest = acceptedQuest.redeemingReward()
            return QuestSlot(
                id: questSlot.id,
                quest: questSlot.quest,
                acceptedQuest: updatedAcceptedQuest
            )
        }
    }
    
    // タスクの完了状態を切り替える
    func toggleTaskCompletion(questSlotId: UUID, taskId: UUID) {
        updateQuestSlot(questSlotId) { questSlot in
            guard var acceptedQuest = questSlot.acceptedQuest else { return questSlot }
            
            if let index = acceptedQuest.acceptedTasks.firstIndex(where: { $0.id == taskId }) {
                let task = acceptedQuest.acceptedTasks[index]
                acceptedQuest.acceptedTasks[index] = task.isCompleted ?
                    AcceptedTask(originalTask: task.originalTask) :
                    task.markAsCompleted()
                
                return QuestSlot(
                    id: questSlot.id,
                    quest: questSlot.quest,
                    acceptedQuest: acceptedQuest
                )
            }
            
            return questSlot
        }
    }
    
    // クエスト完了を報告する
    func reportQuestCompletion(questSlotId: UUID) {
        updateQuestSlot(questSlotId) { questSlot in
            guard let acceptedQuest = questSlot.acceptedQuest else { return questSlot }
            
            if !acceptedQuest.isAllTaskCompleted { return questSlot }
            
            return QuestSlot(
                id: questSlot.id,
                quest: questSlot.quest,
                acceptedQuest: acceptedQuest.reportCompletion()
            )
        }
    }
    
    // 報酬を受け取る
    func redeemReward(questSlotId: UUID) {
        updateQuestSlot(questSlotId) { questSlot in
            guard var acceptedQuest = questSlot.acceptedQuest,
                  acceptedQuest.isAllTaskCompleted else { return questSlot }
            
            acceptedQuest = acceptedQuest.redeemingReward()
            return QuestSlot(
                id: questSlot.id,
                quest: questSlot.quest,
                acceptedQuest: acceptedQuest
            )
        }
    }
    
    // QuestSlotの更新ヘルパーメソッド
    private func updateQuestSlot(_ questSlotId: UUID, updateHandler: (QuestSlot) -> QuestSlot) {
        var questSlots = questSlotsSubject.value
        
        if let index = questSlots.firstIndex(where: { $0.id == questSlotId }) {
            let updatedQuestSlot = updateHandler(questSlots[index])
            questSlots[index] = updatedQuestSlot
            questSlotsSubject.send(questSlots)
        }
    }
} 