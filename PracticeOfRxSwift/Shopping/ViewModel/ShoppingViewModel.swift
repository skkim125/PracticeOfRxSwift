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
    private var shoppingList = ShoppingList.shared.shoppingList
    private var recentSearchList: [String] = []
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let shoppingTitle: ControlProperty<String>
        let completeButtonCellIndex: PublishRelay<Int>
        let starButtonCellIndex: PublishRelay<Int>
        let addButtonTap: ControlEvent<Void>
        let cellTapIndex: ControlEvent<IndexPath>
        let cellTapModel: ControlEvent<Shopping>
    }
    
    struct Output {
        let list: BehaviorRelay<[Shopping]>
        let shoppingTitle: ControlProperty<String>
        let addButtonTap: ControlEvent<Void>
        let showAlert: PublishRelay<Void>
        let recentSearchList: BehaviorRelay<[String]>
    }
    
    func transform(input: Input) -> Output {
        let result = BehaviorRelay(value: shoppingList)
        let shoppingTitle = input.shoppingTitle
        let addButtonTap = input.addButtonTap
        let cellTapModel = input.cellTapModel
        let cellTapIndex = input.cellTapIndex
        let showAlert = PublishRelay<Void>()
        let recentSearchList: BehaviorRelay<[String]> = BehaviorRelay(value: [])
        
        input.completeButtonCellIndex
            .bind(with: self) { owner, index in
                owner.shoppingList[index].isCompleted.toggle()
                result.accept(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        input.starButtonCellIndex
            .bind(with: self) { owner, index in
                owner.shoppingList[index].isStared.toggle()
                result.accept(owner.shoppingList)
            }
            .disposed(by: disposeBag)
        
        input.addButtonTap
            .withLatestFrom(shoppingTitle) { _, title in
                return title
            }
            .bind(with: self) { owner, title in
                if !title.isEmpty {
                    let newShopping = Shopping(title: title, isCompleted: false, isStared: false)
                    owner.shoppingList.append(newShopping)
                    result.accept(owner.shoppingList)
                } else {
                    showAlert.accept(())
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(cellTapIndex, cellTapModel)
            .bind(with: self) { owner, data in
                owner.recentSearchList.append(data.1.title)
                recentSearchList.accept(owner.recentSearchList)
            }
            .disposed(by: disposeBag)
        
        
        return Output(list: result, shoppingTitle: shoppingTitle, addButtonTap: addButtonTap, showAlert: showAlert, recentSearchList: recentSearchList)
    }
    
//    private func shoppingisCompletedChange(_ index: Int) {
//        shoppingList[index].isCompleted.toggle()
//        list.accept(shoppingList)
//    }
//    
//    private func shoppingisStaredChange(_ index: Int) {
//        shoppingList[index].isStared.toggle()
//        list.accept(shoppingList)
//    }
    
//    func addNewShopping(title: String) {
//        let newShopping = Shopping(title: title, isCompleted: false, isStared: false)
//        
//        shoppingList.append(newShopping)
//        list.accept(shoppingList)
//    }
//    
//    func editShopping(_ index: Int, editShopping: Shopping) {
//        shoppingList[index] = editShopping
//        list.accept(shoppingList)
//    }
}
