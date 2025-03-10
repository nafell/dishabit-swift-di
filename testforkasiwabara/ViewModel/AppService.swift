import Foundation
import Combine

protocol AppDataServiceProtocol {
    var activeQuestsPubisher: AnyPublisher<[Quest], Never> { get }
    var tasksPubisher: AnyPublisher<[Task], Never> { get }
    var objectivesPubisher: AnyPublisher<[Objective], Never> { get }
    var dailyQuestBoardPubisher: AnyPublisher<[DailyQuestBoard], Never> { get }

    func editTask(taskId: UUID, newText: String)
}

class AppDataService: AppDataServiceProtocol {
    private var cancellables = Set<AnyCancellable>()
    
    private let activeQuestsSubject = CurrentValueSubject<[Quest], Never>([])
    private let tasksSubject = CurrentValueSubject<[Task], Never>([])
    private let objectivesSubject = CurrentValueSubject<[Objective], Never>([])
    private let dailyQuestBoardsSubject = CurrentValueSubject<[DailyQuestBoard], Never>([])

    // ==== Public publishers of lists ====
    var activeQuestsPubisher: AnyPublisher<[Quest], Never> { activeQuestsSubject.eraseToAnyPublisher() }
    var tasksPubisher: AnyPublisher<[Task], Never> { tasksSubject.eraseToAnyPublisher() }
    var objectivesPubisher: AnyPublisher<[Objective], Never> { objectivesSubject.eraseToAnyPublisher() }
    var dailyQuestBoardPubisher: AnyPublisher<[DailyQuestBoard], Never> { dailyQuestBoardsSubject.eraseToAnyPublisher() }
    
    init () {
        loadSampleData()
        // ==== 依存関係にあるデータの変更通知のWaterfallさせる ====
        // objectives -> tasks -> activeQuests -> dailyQuestBoards
        
        // objectives -> tasks
        objectivesPubisher
            .receive(on: RunLoop.main)
            .sink{ [weak self] objectives in
                guard let self = self else { return }
                self.activeQuestsSubject.send(self.activeQuestsSubject.value)
            }
            .store(in: &cancellables)

        // tasks -> activeQuests
        tasksPubisher
            .receive(on: RunLoop.main)
            .sink { [weak self] tasks in
                guard let self = self else { return }
                self.activeQuestsSubject.send(self.activeQuestsSubject.value)
            }
            .store(in: &cancellables)
        
        // activeQuests -> dailyQuestBoards
        activeQuestsPubisher
            .receive(on: RunLoop.main)
            .sink { [weak self] quests in
                guard let self = self else { return }
                self.dailyQuestBoardsSubject.send(self.dailyQuestBoardsSubject.value)
            }
            .store(in: &cancellables)
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
        let reward2 = Reward(id: UUID(), text: "映画を見る")
        
        // モックのクエストを作成
        let quest1 = Quest(id: UUID(), title: "健康的な朝習慣", reward: reward1, tasks: [task1, task2, task5])
        let quest2 = Quest(id: UUID(), title: "運動チャレンジ", reward: reward2, tasks: [task4, task5])
        
        // モックのQuestSlotを作成
        let questSlot1 = QuestSlot(id: UUID(), quest: quest1, acceptedQuest: nil)
        let questSlot2 = QuestSlot(id: UUID(), quest: quest2, acceptedQuest: nil)
        
        // モックのDailyQuestBoardを作成
        let dailyQuestBoard = DailyQuestBoard(
            id: UUID(),
            date: Date(),
            questSlots: [questSlot1, questSlot2]
        )
        
        // Subjectsを更新
        objectivesSubject.send([objective1, objective2, objective3])
        tasksSubject.send([task1, task2, task3, task4, task5])
        activeQuestsSubject.send([quest1, quest2])
        dailyQuestBoardsSubject.send([dailyQuestBoard])
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
        dailyQuestBoardsSubject
            .map { dailyQuestBoards in
                dailyQuestBoards.first { $0.id == id }
            }
            .eraseToAnyPublisher()
    }

    // ==== Public methods ====
    func editTask(taskId: UUID, newText: String) {
        updateTask(taskId) { task in
            task.text = newText
            return task
        }
    }

    private func updateTask(_ taskId: UUID, updateHandler: (Task) -> Task) {
        var tasks = tasksSubject.value
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            tasks[index] = updateHandler(tasks[index])
            tasksSubject.send(tasks)
        }
    }
}
