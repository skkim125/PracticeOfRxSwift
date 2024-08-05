//
//  PasswordViewModel.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PasswordViewModel {
    private let disposeBag = DisposeBag()
    
    struct Input {
        let passwordText: ControlProperty<String>
        let nextButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let passwordValid: Observable<Bool>
        let nextButtonTap: ControlEvent<Void>
        let validText: PublishRelay<String>
    }
    
    func transform(input: Input) -> Output {
        let passwordValid = input.passwordText
            .map({ $0.count >= 8 })
        let nextButtonTap = input.nextButtonTap
        let validText = PublishRelay<String>()
        
        passwordValid
            .bind { isValid in
                let text = isValid ? "알맞은 형식입니다" : "8자 이상 입력해주세요"
                validText.accept(text)
            }
            .disposed(by: disposeBag)
        
        return Output(passwordValid: passwordValid, nextButtonTap: nextButtonTap, validText: validText)
    }
}
