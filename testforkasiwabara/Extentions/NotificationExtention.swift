//
//  NotificationExtention.swift
//  testforkasiwabara
//
//  Created by 長峯幸佑 on 2025/03/06.
//

import Foundation

// 注: 現在はCombineベースのPublisher/Subscriberパターンを使用しているため、
// このNotification拡張は使用していません。将来的に必要になる場合のために残しています。
extension Notification.Name {
    static let questUpdated = Notification.Name("questUpdated")
}
