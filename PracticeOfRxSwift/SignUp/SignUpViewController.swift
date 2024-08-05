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
    private let viewModel = SignUpViewModel()
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
        let input = SignUpViewModel.Input(emailText: emailTextField.rx.text.orEmpty, validationButtonTap: validationButton.rx.tap, nextButtonTap: nextButton.rx.tap)
        let output = viewModel.transform(input: input)
        
        output.validationText
            .bind(to: validationLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.emailLabelText
            .bind(to: emailLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.emailValid
            .bind(with: self) { owner, isValid in
                let validationButtomcolor: UIColor = isValid ? .black : .systemGray
                owner.validationButton.setTitleColor(validationButtomcolor, for: .normal)
                owner.validationLabel.isHidden = !isValid
                owner.validationButton.rx.isEnabled.onNext(isValid)
                owner.nextButton.rx.backgroundColor.onNext(.systemGray)
            }
            .disposed(by: disposeBag)
        
        output.emailValid
            .bind(to: nextButton.rx.isEnabled, validationButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        output.emailText
            .bind(with: self) { owner, tfText in
                guard let savedEmail = owner.emailLabel.text else { return }
                if !tfText.isEmpty && !savedEmail.isEmpty && "\(tfText)" == savedEmail {
                    owner.nextButton.rx.isEnabled.onNext(true)
                    owner.nextButton.rx.backgroundColor.onNext(.systemGreen)
                } else {
                    owner.nextButton.rx.isEnabled.onNext(false)
                    owner.nextButton.rx.backgroundColor.onNext(.systemGray)
                }
            }
            .disposed(by: disposeBag)
        
        output.validationResult
            .bind(with: self) { owner, email in
                owner.showAlert()
                output.emailLabelText.onNext(email)
                owner.emailLabel.rx.isHidden.onNext(false)
                owner.nextButton.rx.isEnabled.onNext(true)
                owner.nextButton.rx.backgroundColor.onNext(.systemGreen)
            }
            .disposed(by: disposeBag)
        
        output.nextButtonTap
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
