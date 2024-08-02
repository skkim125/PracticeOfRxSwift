//
//  PasswordViewController.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class PasswordViewController: UIViewController {
   
    private let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    private let passwordValidLabel = UILabel()
    private let nextButton = PointButton(title: "다음")
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
    }
    
    func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(passwordValidLabel)
        view.addSubview(nextButton)
         
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordValidLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(passwordTextField.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordValidLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        passwordValidLabel.font = .systemFont(ofSize: 14)
    }
    
    func bind() {
        let passwordValid = passwordTextField.rx.text.orEmpty
            .map({ $0.count >= 8 })
        
        passwordValid
            .bind(with: self) { owner, isValid in
                let labelColor: UIColor = isValid ? .black : .systemRed
                let buttonColor: UIColor = isValid ? .systemGreen : .systemGray
                let labelText = isValid ? "알맞은 형식입니다" : "8자 이상 입력해주세요"
                owner.passwordValidLabel.rx.text.onNext(labelText)
                owner.passwordValidLabel.rx.textColor.onNext(labelColor)
                
                owner.nextButton.rx.backgroundColor.onNext(buttonColor)
                owner.nextButton.rx.isEnabled.onNext(isValid)
            }
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PhoneViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
}
