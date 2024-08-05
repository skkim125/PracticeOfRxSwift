//
//  ShoppingTableViewCellViewModel.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ShoppingTableViewCellViewModel {
    struct Input {
        let shopping: BehaviorRelay<Shopping>
        let completeButtonTap: ControlEvent<Void>
        let starButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let completeButtonTap: ControlEvent<Void>
        let starButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let completeButtonTap = input.completeButtonTap
        let starButtonTap = input.starButtonTap
        
        return Output(completeButtonTap: completeButtonTap, starButtonTap: starButtonTap)
    }
}

