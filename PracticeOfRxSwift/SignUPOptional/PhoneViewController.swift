//
//  PhoneViewController.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PhoneViewController: UIViewController {
    private let phoneTextField = SignTextField(placeholderText: "연락처를 입력해주세요")
    private let phoneValidLabel = UILabel()
    private let nextButton = PointButton(title: "다음")
    
    private var phoneValidText = PublishRelay<String>()
    private var phoneText = BehaviorRelay(value: "010")
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configureView()
        bind()
    }
    
    func configureLayout() {
        view.addSubview(phoneTextField)
        view.addSubview(phoneValidLabel)
        view.addSubview(nextButton)
         
        phoneTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        phoneValidLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(phoneTextField.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(phoneValidLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    func configureView() {
        phoneTextField.keyboardType = .phonePad
    }
    
    func bind() {
        phoneText
            .bind(to: phoneTextField.rx.text)
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty
            .bind(to: phoneValidText)
            .disposed(by: disposeBag)
        
        phoneValidText
            .bind(to: phoneValidLabel.rx.text)
            .disposed(by: disposeBag)
        
        let phoneValidOfIsEmpty = phoneTextField.rx.text.orEmpty
            .map({ !$0.trimmingCharacters(in: .whitespaces).isEmpty })
        
        let phoneValidOfNum = phoneTextField.rx.text.orEmpty
            .map({ Int($0) != nil })
        
        let phoneValidOfCount = phoneTextField.rx.text.orEmpty
            .map({ $0.trimmingCharacters(in: .whitespaces).count >= 10 })
        
        Observable.combineLatest(phoneValidOfIsEmpty, phoneValidOfNum, phoneValidOfCount)
            .bind(with: self) { owner, isValid in
                let allValid = isValid.0 && isValid.1 && isValid.2
                let labelColor: UIColor = allValid ? .systemGreen : .systemGray
                let buttonColor: UIColor = allValid ? .systemGreen : .systemGray

                owner.phoneValidLabel.rx.isHidden.onNext(false)
                owner.phoneValidLabel.rx.textColor.onNext(labelColor)
                owner.nextButton.rx.backgroundColor.onNext(buttonColor)
                owner.nextButton.rx.isEnabled.onNext(allValid)
                
                if isValid.0 && isValid.1 && isValid.2 == true {
                    owner.phoneValidText.accept("올바른 형식입니다.")
                } else {
                    if !isValid.0 || !isValid.2 {
                        owner.phoneValidText.accept("10자 이상 입력하세요.")
                    } else if !isValid.1 {
                        owner.phoneValidText.accept("숫자만 입력 가능합니다.")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(NicknameViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }

}
