//
//  SignUpViewController.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SignUpViewController: UIViewController {

    // View
    private let emailTextField = SignTextField(placeholderText: "이메일을 입력해주세요")
    private let validationButton = UIButton()
    private let validationLabel = UILabel()
    private let nextButton = PointButton(title: "다음")
    private let emailLabel = UILabel()
    
    // Property
    private var email = PublishSubject<String>()
    private var emailValidText = BehaviorRelay(value: "알맞은 이메일 형식입니다")
    private var nextButtonColor = BehaviorRelay(value: UIColor.systemGray)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        configure()
        bind()
    }
    private func configure() {
        
        emailLabel.font = .boldSystemFont(ofSize: 18)
        emailLabel.textAlignment = .center
        emailLabel.isHidden = true
        
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        
        validationButton.setTitle("중복확인", for: .normal)
        validationButton.setTitleColor(Color.black, for: .normal)
        validationButton.layer.borderWidth = 1
        validationButton.layer.borderColor = Color.black.cgColor
        validationButton.layer.cornerRadius = 10
        
        validationLabel.textColor = .systemGreen
        validationLabel.font = .systemFont(ofSize: 14)
    }
    private func configureLayout() {
        view.addSubview(emailLabel)
        view.addSubview(emailTextField)
        view.addSubview(validationButton)
        view.addSubview(nextButton)
        view.addSubview(validationLabel)
        
        emailLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        validationButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailLabel.snp.bottom).offset(50)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(100)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(emailLabel.snp.bottom).offset(50)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(validationButton.snp.leading).offset(-8)
        }
        
        validationLabel.snp.makeConstraints { make in
            make.height.equalTo(30)
            make.top.equalTo(emailTextField.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(validationLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    private func bind() {
        
        emailValidText
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        email
            .bind(to: emailLabel.rx.text)
            .disposed(by: disposeBag)
        
        nextButtonColor
            .bind(to: nextButton.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        let emailValid = emailTextField.rx.text.orEmpty
            .map({ $0.contains("@") && ( $0.contains(".com") || $0.contains(".net")) })
        
        emailValid
            .bind(with: self) { owner, isValid in
                let validationButtomcolor: UIColor = isValid ? .black : .systemGray
                owner.validationButton.setTitleColor(validationButtomcolor, for: .normal)
                owner.validationLabel.isHidden = !isValid
                
                owner.nextButtonColor.accept(isValid ? .systemGreen : .systemGray)
            }
            .disposed(by: disposeBag)
        
        emailValid
            .bind(to: nextButton.rx.isEnabled, validationButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        validationButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.showAlert()
                owner.email.onNext(owner.emailTextField.text ?? "")
                owner.emailLabel.isHidden = false
            }
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(PasswordViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "사용가능한 이메일입니다", message: nil, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
}
