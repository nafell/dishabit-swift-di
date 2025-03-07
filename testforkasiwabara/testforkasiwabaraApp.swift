//
//  testforkasiwabaraApp.swift
//  testforkasiwabara
//
//  Created by 長峯幸佑 on 2025/03/06.
//

import SwiftUI

@main
struct testforkasiwabaraApp: App {
    // アプリケーション全体で共有するQuestServiceのインスタンス
    let questService = QuestService()
    
    var body: some Scene {
        WindowGroup {
            // QuestServiceを注入してQuestListViewを初期化
            QuestListView(viewModel: QuestListViewModel(questService: questService))
        }
    }
}
