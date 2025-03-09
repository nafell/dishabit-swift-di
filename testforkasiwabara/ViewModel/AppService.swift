import Foundation
import Combine

protocol AppServiceProtocol {
    var activeQuestsPublisher: AnyPublisher<[Quest], Never> {get}
}

class AppService: AppServiceProtocol {
    // CurrentValueSubjectを使用して値を保持し、パブリッシャーとして公開
    private let activeQuestsSubject = CurrentValueSubject<[Quest], Never>([])
    
    var activeQuestsPublisher: AnyPublisher<[Quest], Never> {
        return activeQuestsSubject.eraseToAnyPublisher()
    }
    
    init() {
        // 初期化処理
    }
}