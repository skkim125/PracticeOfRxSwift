//
//  ShoppingViewModel.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShoppingViewModel {
    private let shoppingList = ShoppingList.shared.shoppingList
    
    struct Input {
        let shoppingTitle: ControlProperty<String>
        let addButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        var shoppingList: [Shopping]
        let list: BehaviorRelay<[Shopping]>
        let shoppingTitle: ControlProperty<String>
        let addButtonTap: ControlEvent<Void>
        
        mutating func shoppingisCompletedChange(_ index: Int) {
            shoppingList[index].isCompleted.toggle()
            list.accept(shoppingList)
        }
        
        mutating func shoppingisStaredChange(_ index: Int) {
            shoppingList[index].isStared.toggle()
            list.accept(shoppingList)
        }
        
        mutating func addNewShopping(title: String) {
            let newShopping = Shopping(title: title, isCompleted: false, isStared: false)
            
            shoppingList.append(newShopping)
            list.accept(shoppingList)
        }
        
        mutating func editShopping(_ index: Int, editShopping: Shopping) {
            shoppingList[index] = editShopping
            list.accept(shoppingList)
        }
    }
    
    func transform(input: Input) -> Output {
        let shoppingList = shoppingList
        let list = BehaviorRelay(value: shoppingList)
        let shoppingTitle = input.shoppingTitle
        let addButtonTap = input.addButtonTap
        
        return Output(shoppingList: shoppingList, list: list, shoppingTitle: shoppingTitle, addButtonTap: addButtonTap)
    }
}
