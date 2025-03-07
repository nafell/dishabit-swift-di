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
            VStack(spacing: 30) {
                if !viewModel.questSlots.isEmpty {
                    let questSlot = viewModel.questSlots[0]
                    Text(questSlot.quest.reward.text)
                    if let acceptedQuest = questSlot.acceptedQuest {
                        if !acceptedQuest.isCompletionReported {
                            Text("チェック数")
                            Text(acceptedQuest.acceptedTasks.filter {$0.isCompleted}.count.description)
                        } else {
                            if !acceptedQuest.reward.isRedeemed {
                                Button(action: {
                                    viewModel.redeemTicket(questSlotId: questSlot.id)
                                } ) {
                                    Text("チケットを使う")
                                }
                            } else {
                                Text("チケット使用済")
                            }
                        }
                    } else {
                        Button(action: {
                            viewModel.acceptQuest(questSlotId: questSlot.id)
                        }) {
                            Text("start")
                        }
                    }
                    NavigationLink(
                        destination: QuestDetailsView(
                            viewModel: viewModel.createDetailsViewModel(for: questSlot.id))) {
                        Text("detailView")
                    }
                }
            }
        }
    }
}

#Preview {
    QuestListView(viewModel: QuestListViewModel())
}
