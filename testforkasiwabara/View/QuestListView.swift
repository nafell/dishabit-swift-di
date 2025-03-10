//
//  QuestListView.swift
//  testforkasiwabara
//
//  Created by 長峯幸佑 on 2025/03/06.
//

import SwiftUI

struct QuestListView: View {
    @ObservedObject var viewModel: QuestListViewModel
    
    // 依存性注入を使用したイニシャライザ
    init(viewModel: QuestListViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                VStack(spacing: 10){
                    ForEach(viewModel.dailyQuestBoard[0].questSlots, id: \.id) { questSlot in
                        VStack(spacing: 10){
                            Text(questSlot.quest.reward.text)
                            ForEach(questSlot.quest.tasks, id: \.id) { task in
                                HStack{
                                    Text(task.text)
                                    Spacer()
                                    Button(action: {
                                        viewModel.editTaskTest(taskId: task.id, newText: task.text + "1")
                                    }) {
                                        Text("共通編集テスト")
                                    }
                                }
                            }
                        }.background(Color.gray.opacity(0.3))
                    }
                }
//                VStack(spacing: 10){
//                    if !viewModel.questSlots.isEmpty {
//                        let questSlot = viewModel.questSlots[0]
//                        Text(questSlot.quest.reward.text)
//                        if let acceptedQuest = questSlot.acceptedQuest {
//                            if !acceptedQuest.isCompletionReported {
//                                Text("チェック数")
//                                Text(acceptedQuest.acceptedTasks.filter {$0.isCompleted}.count.description)
//                            } else {
//                                if !acceptedQuest.reward.isRedeemed {
//                                    Button(action: {
//                                        viewModel.redeemTicket(questSlotId: questSlot.id)
//                                    } ) {
//                                        Text("チケットを使う")
//                                    }
//                                } else {
//                                    Text("チケット使用済")
//                                }
//                            }
//                        } else {
//                            Button(action: {
//                                viewModel.acceptQuest(questSlotId: questSlot.id)
//                            }) {
//                                Text("start")
//                            }
//                        }
//                        NavigationLink(
//                            destination: QuestDetailsView(
//                                viewModel: viewModel.createDetailsViewModel(for: questSlot.id))) {
//                                    Text("detailView")
//                                }
//                    }
//                }.background(Color.gray.opacity(0.1))
            }
        }
    }
}

#Preview {
    QuestListView(viewModel: QuestListViewModel())
}
