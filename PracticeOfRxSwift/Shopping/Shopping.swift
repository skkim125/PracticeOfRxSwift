//
//  Shopping.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/5/24.
//

import Foundation

struct Shopping {
    let title: String
    var isCompleted: Bool
    var isStared: Bool
}

final class ShoppingList {
    static let shared = ShoppingList()
    private init() { }
    
    let shoppingList: [Shopping] = [
        Shopping(title: "한우 투쁠", isCompleted: false, isStared: true),
        Shopping(title: "상추", isCompleted: false, isStared: false),
        Shopping(title: "사이다", isCompleted: true, isStared: false),
        Shopping(title: "돗자리", isCompleted: true, isStared: true),
    ]
}
