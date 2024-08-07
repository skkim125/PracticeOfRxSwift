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
    private var recentList: [String] = ["비상금 챙기기", "오레오 사기"]
    
    let disposeBag = DisposeBag()
    
    struct Input {
        let shoppingTitle: ControlProperty<String>
        let completeButtonCellIndex: PublishRelay<Int>
        let starButtonCellIndex: PublishRelay<Int>
        let addButtonTap: ControlEvent<Void>
        let tableViewCellTapIndex: ControlEvent<IndexPath>
        let tableViewCellTapModel: ControlEvent<Shopping>
        let searchButtonClicked: ControlEvent<Void>
    }
    
    struct Output {
        let list: BehaviorRelay<[Shopping]>
        let shoppingTitle: ControlProperty<String>
        let addButtonTap: ControlEvent<Void>
        let showAlert: PublishRelay<Void>
        let recentSearchList: BehaviorRelay<[String]>
        let searchButtonClicked: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = BehaviorRelay(value: shoppingList)
        let shoppingTitle = input.shoppingTitle
        let addButtonTap = input.addButtonTap
        let cellTapModel = input.tableViewCellTapModel
        let cellTapIndex = input.tableViewCellTapIndex
        let showAlert = PublishRelay<Void>()
        let recentSearchList = BehaviorRelay(value: recentList)
        let searchButtonClicked = input.searchButtonClicked
        
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
                owner.recentList.append(data.1.title)
                recentSearchList.accept(owner.recentList)
            }
            .disposed(by: disposeBag)
        
        input.searchButtonClicked
            .withLatestFrom(shoppingTitle)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .map({ (!$0.isEmpty, $0) })
            .bind(with: self) { owner, value in
                if value.0 {
                    let filter = owner.shoppingList.filter({ $0.title.lowercased().contains(value.1) })
                    result.accept(filter)
                }
            }
            .disposed(by: disposeBag)
        
        input.shoppingTitle
            .map({ (!$0.isEmpty) })
            .bind(with: self) { owner, isNotEmpty in
                if isNotEmpty {
                    result.accept(owner.shoppingList)
                }
            }
            .disposed(by: disposeBag)

        return Output(list: result, shoppingTitle: shoppingTitle, addButtonTap: addButtonTap, showAlert: showAlert, recentSearchList: recentSearchList, searchButtonClicked: searchButtonClicked)
    }
}
