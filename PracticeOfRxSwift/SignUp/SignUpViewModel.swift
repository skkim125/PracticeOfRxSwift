//
//  SignUpViewModel.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SignUpViewModel {
    private var email = PublishSubject<String>()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let emailText: ControlProperty<String>
        let validationButtonTap: ControlEvent<Void>
        let nextButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let validationText: Observable<String>
        
        let emailText: ControlProperty<String>
        let emailValid: Observable<Bool>
        
        let validationButtonTap: ControlEvent<Void>
        let validationResult: Observable<ControlProperty<String>.Element>
        let emailLabelText: PublishSubject<String>
        
        let nextButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let validationText = Observable.just("알맞은 이메일 형식입니다")
        
        let emailText = input.emailText
        let emailValid = emailText
            .map({ $0.contains("@") && ( $0.contains(".com") || $0.contains(".net")) })
        
        let validationButtonTap = input.validationButtonTap
        let validationResult = input.validationButtonTap
            .withLatestFrom(input.emailText) { _, email in
                return email
            }
        
        let emailLabelText = PublishSubject<String>()
        
        let nextButtonTap = input.nextButtonTap
        
        return Output(validationText: validationText, emailText: emailText, emailValid: emailValid, validationButtonTap: validationButtonTap, validationResult: validationResult, emailLabelText: emailLabelText, nextButtonTap: nextButtonTap)
    }
}
