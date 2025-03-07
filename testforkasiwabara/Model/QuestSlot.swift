//
//  QuestSlot.swift
//  testforkasiwabara
//
//  Created by 長峯幸佑 on 2025/03/06.
//

import Foundation

// タスク定義

struct Objective: Codable {
    var id: String
    var text: String
}

struct Task: Identifiable {
    var id: String
    var text: String
    var objective: Objective?
}

// 受注済みタスク定義
struct AcceptedTask: Identifiable {
    var originalTask: Task
    var isCompleted: Bool = false
    
    // 元のTaskのプロパティにアクセスするための転送プロパティ
    var id: String { originalTask.id }
    var text: String { originalTask.text }
    var objective: Objective? { originalTask.objective }
    
    // 完了状態を変更した新しいインスタンスを返す
    func markAsCompleted() -> AcceptedTask {
        var updated = self
        updated.isCompleted = true
        return updated
    }
}

// 未受注のクエスト
struct Quest: Identifiable {
    var id: String
    var title: String
    var reward: Reward
    var tasks: [Task]
    
    // AcceptedQuestを生成するメソッド
    func accept() -> AcceptedQuest {
        let acceptedTasks = tasks.map { AcceptedTask(originalTask: $0) }
        let accetedReward = RedeemableReward(originalReward: reward)
        
        return AcceptedQuest(
            id: id,
            title: title,
            reward: accetedReward,
            acceptedTasks: acceptedTasks
        )
    }
}

struct AcceptedQuest: Identifiable {
    var id: String
    var title: String
    var reward: RedeemableReward // 変更: RewardからRedeemableRewardに
    var acceptedTasks: [AcceptedTask]
    
    // クエストの完了報告が完了しているかどうかのboolean
    var isCompletionReported: Bool = false
    
    // 全てのタスクが完了しているかどうか
    var isAllTaskCompleted: Bool {
        return acceptedTasks.allSatisfy { $0.isCompleted }
    }
    
    // ごほうびを受け取る
    mutating func redeemReward() {
        if isAllTaskCompleted && !reward.isRedeemed {
            reward = reward.markAsRedeemed()
        }
    }
    
    // ごほうびを受け取った新しいインスタンスを返す（イミュータブル版）
    func redeemingReward() -> AcceptedQuest {
        var updated = self
        updated.redeemReward()
        return updated
    }
    
    func reportCompletion() -> AcceptedQuest {
        var updated = self
        updated.isCompletionReported = true
        return updated
    }
}
// QuestSlot定義
struct QuestSlot: Identifiable {
    var id: String
    var quest: Quest
    var acceptedQuest: AcceptedQuest?
    
    // クエストを受注するメソッド
    func acceptQuest() -> QuestSlot {
        return QuestSlot(
            id: id,
            quest: quest,
            acceptedQuest: quest.accept()
        )
    }
    
    static func acceptQuest() -> QuestSlot? {
        return nil
    }
}

// ごほうびメニューアイテム
struct Reward: Identifiable {
    var id: String
    var text: String
}

// 受注済みクエストに付与されるごほうびチケット
struct RedeemableReward: Identifiable {
    var originalReward: Reward
    var isRedeemed: Bool = false
    // var grantDate: Date
    var redeemedDate: Date?
    
    // 元のRewardのプロパティにアクセスするための転送プロパティ
    var id: String { originalReward.id }
    var text: String { originalReward.text }
    
    // ごほうびを使用済みとしてマークする
    func markAsRedeemed() -> RedeemableReward {
        var updated = self
        updated.isRedeemed = true
        updated.redeemedDate = Date()
        return updated
    }
    
    // 有効期限を確認（オプション）
//    func isValid(asOf date: Date = Date()) -> Bool {
//        // 例: 30日間有効
//        let validityPeriod: TimeInterval = 30 * 24 * 60 * 60 // 30日間（秒単位）
//        return !isRedeemed && date < grantDate.addingTimeInterval(validityPeriod)
//    }
}
