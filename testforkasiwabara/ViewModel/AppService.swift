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
