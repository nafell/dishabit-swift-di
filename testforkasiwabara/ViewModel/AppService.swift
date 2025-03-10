import Foundation
import Combine

protocol AppDataServiceProtocol {
    var activeQuestsPubisher: AnyPublisher<[Quest], Never> { get }
    var tasksPubisher: AnyPublisher<[Task], Never> { get }
    var objectivesPubisher: AnyPublisher<[Objective], Never> { get }
    var dailyQuestBoardPubisher: AnyPublisher<[DailyQuestBoard], Never> { get }
}

class AppDataService: AppDataServiceProtocol {
    private let activeQuestsSubject = CurrentValueSubject<[Quest], Never>([])
    private let tasksSubject = CurrentValueSubject<[Task], Never>([])
    private let objectivesSubject = CurrentValueSubject<[Objective], Never>([])
    private let dailyQuestBoardSubject = CurrentValueSubject<[DailyQuestBoard], Never>([])

    // ==== Public publishers of lists ====
    var activeQuestsPubisher: AnyPublisher<[Quest], Never> { activeQuestsSubject.eraseToAnyPublisher() }
    var tasksPubisher: AnyPublisher<[Task], Never> { tasksSubject.eraseToAnyPublisher() }
    var objectivesPubisher: AnyPublisher<[Objective], Never> { objectivesSubject.eraseToAnyPublisher() }
    var dailyQuestBoardPubisher: AnyPublisher<[DailyQuestBoard], Never> { dailyQuestBoardSubject.eraseToAnyPublisher() }
    
    init () {
        loadSampleData()
    }

    private func loadSampleData() {
                // Create mock data for activeQuests.
        // モックの目標を作成
        let objective1 = Objective(id: UUID(), text: "健康的な生活を送る")
        let objective2 = Objective(id: UUID(), text: "勉強習慣を身につける")
        let objective3 = Objective(id: UUID(), text: "運動を習慣化する")
        
        // モックのタスクを作成
        let task1 = Task(id: UUID(), text: "朝7時に起床する", objective: objective1)
        let task2 = Task(id: UUID(), text: "朝食を食べる", objective: objective1)
        let task3 = Task(id: UUID(), text: "1時間勉強する", objective: objective2)
        let task4 = Task(id: UUID(), text: "30分ジョギングする", objective: objective3)
        let task5 = Task(id: UUID(), text: "ストレッチをする", objective: objective3)
        
        // モックの報酬を作成
        let reward1 = Reward(id: UUID(), text: "好きなお菓子を1つ買う")
        let reward2 = Reward(id: UUID(), text: "1時間ゲームをする")
        let reward3 = Reward(id: UUID(), text: "映画を見る")
        
        // モックのクエストを作成
        let quest1 = Quest(id: UUID(), title: "健康的な朝習慣", reward: reward1, tasks: [task1, task2])
        let quest2 = Quest(id: UUID(), title: "勉強タイム", reward: reward2, tasks: [task3])
        let quest3 = Quest(id: UUID(), title: "運動チャレンジ", reward: reward3, tasks: [task4, task5])
        
        // モックのQuestSlotを作成
        let questSlot1 = QuestSlot(id: UUID(), quest: quest1, acceptedQuest: nil)
        let questSlot2 = QuestSlot(id: UUID(), quest: quest2, acceptedQuest: nil)
        let questSlot3 = QuestSlot(id: UUID(), quest: quest3, acceptedQuest: nil)
        
        // モックのDailyQuestBoardを作成
        let dailyQuestBoard = DailyQuestBoard(
            id: UUID(),
            date: Date(),
            questSlots: [questSlot1, questSlot2, questSlot3]
        )
        
        // Subjectsを更新
        objectivesSubject.send([objective1, objective2, objective3])
        tasksSubject.send([task1, task2, task3, task4, task5])
        activeQuestsSubject.send([quest1, quest2, quest3])
        dailyQuestBoardSubject.send([dailyQuestBoard])
    }

    // ==== Publishers for single items for each list ====
    func activeQuestPublisher(for id: UUID) ->  AnyPublisher<Quest?, Never> {
        activeQuestsSubject
            .map { quests in
                quests.first { $0.id == id }
            }
            .eraseToAnyPublisher()
    }
    func taskPublisher(for id: UUID) ->  AnyPublisher<Task?, Never> {
        tasksSubject
            .map { tasks in
                tasks.first { $0.id == id }
            }
            .eraseToAnyPublisher()
    }
    func objectivePublisher(for id: UUID) ->  AnyPublisher<Objective?, Never> {
        objectivesSubject
            .map { objectives in
                objectives.first { $0.id == id }
            }
            .eraseToAnyPublisher()
    }
    func dailyQuestBoardPublisher(for id: UUID) ->  AnyPublisher<DailyQuestBoard?, Never> {
        dailyQuestBoardSubject
            .map { dailyQuestBoards in
                dailyQuestBoards.first { $0.id == id }
            }
            .eraseToAnyPublisher()
    }

    init() {
        
    }
    

}
