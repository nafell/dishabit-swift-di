//
//  QuestDetailsView.swift
//  testforkasiwabara
//
//  Created by 長峯幸佑 on 2025/03/06.
//

import SwiftUI

struct QuestDetailsView: View {
    @ObservedObject var viewModel: QuestDetailsViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 5) {
                if let questSlot = viewModel.questSlot {
                    Text(questSlot.quest.title)
                        .font(.headline)
                        .padding(.leading)
                    
                    if let acceptedQuest = questSlot.acceptedQuest {
                        ForEach(acceptedQuest.acceptedTasks , id: \.id) { task in
                            HStack(spacing: 0) {
                                Button(action: {viewModel.toggleTaskCompletion(taskId: task.id)}) {
                                    Image(systemName: task.isCompleted ? "checkmark.square.fill" : "square")
                                        .foregroundColor(task.isCompleted ? .green : .gray)
                                        .font(.system(size: 20))
                                }
                                
                                Text(task.text)
                                    .padding(.leading)
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        }
                        if acceptedQuest.isCompletionReported {
                            if acceptedQuest.reward.isRedeemed {
                                Text("チケット使用済")
                            } else {
                                Button(action: {
                                    viewModel.redeemReward()
                                }) {
                                    Text("チケットを使用する")
                                }
                            }
                        } else {
                            if acceptedQuest.isAllTaskCompleted {
                                Button(action: {
                                    viewModel.reportQuestCompletion()
                                }) {
                                    Text("完了報告")
                                }
                            } else {
                                Button(action: {
                                    print("aa")
                                }) {
                                    Text("諦める")
                                }
                            }
                        }

                    } else {
                        ForEach(questSlot.quest.tasks, id: \.id) { task in
                            HStack(spacing: 0) {
                                Text(task.text)
                                    .padding(.leading)
                                Spacer()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.4), in: RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal)
                        }
                        Button(action: {
                            viewModel.acceptQuest()
                        }) {
                            Text("受注する")
                        }
                    }
                } else {
                    Text("読み込み中...")
                }
            }
            .padding(.vertical, 5)
        }
    }
}
//
//#Preview {
//    let service = QuestService()
//    let questSlotId = service.questSlotsPublisher.value.first?.id ?? ""
//    return QuestDetailsView(viewModel: QuestDetailsViewModel(questService: service, questSlotId: questSlotId))
//}
