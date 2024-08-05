//
//  PhoneViewModel.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PhoneViewModel {
    private var phoneValidText = PublishRelay<String>()
    private let disposeBag = DisposeBag()
    
    struct Input {
        var phoneText: ControlProperty<String?>
        let nextButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let phoneText: ControlProperty<String?>
        let nextButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let initPhoneText = BehaviorRelay(value: "010")
        let phoneText = input.phoneText
        let afterPhoneText = input.phoneText
        let nextButtonTap = input.nextButtonTap
        
        initPhoneText
            .map({ "\($0)" })
            .bind(to: phoneText)
            .disposed(by: disposeBag)
        
        phoneText
            .bind(to: afterPhoneText)
            .disposed(by: disposeBag)
        
//        let phoneValidOfIsEmpty = afterPhoneText.orEmpty
//            .map({ !$0.trimmingCharacters(in: .whitespaces).isEmpty })
//        
//        let phoneValidOfNum = afterPhoneText.orEmpty
//            .map({ Int($0) != nil })
//        
//        let phoneValidOfCount = afterPhoneText.orEmpty
//            .map({ $0.trimmingCharacters(in: .whitespaces).count >= 10 })
        
        return Output(phoneText: afterPhoneText, nextButtonTap: nextButtonTap)
    }
}
