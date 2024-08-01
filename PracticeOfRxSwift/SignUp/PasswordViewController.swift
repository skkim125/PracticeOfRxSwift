//
//  PasswordViewController.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/1/24.
//

import UIKit
import SnapKit

final class PasswordViewController: UIViewController {
   
    let passwordTextField = SignTextField(placeholderText: "비밀번호를 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
         
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)
    }
    
    @objc func nextButtonClicked() {
        navigationController?.pushViewController(PhoneViewController(), animated: true)
    }
    
    func configureLayout() {
        view.addSubview(passwordTextField)
        view.addSubview(nextButton)
         
        passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}
