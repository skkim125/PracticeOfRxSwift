//
//  NicknameViewController.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/1/24.
//

import UIKit
import SnapKit

final class NicknameViewController: UIViewController {
   
    let nicknameTextField = SignTextField(placeholderText: "닉네임을 입력해주세요")
    let nextButton = PointButton(title: "다음")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
       
        nextButton.addTarget(self, action: #selector(nextButtonClicked), for: .touchUpInside)

    }
    
    @objc func nextButtonClicked() {
        navigationController?.pushViewController(BirthdayViewController(), animated: true)
    }

    
    func configureLayout() {
        view.addSubview(nicknameTextField)
        view.addSubview(nextButton)
         
        nicknameTextField.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(200)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(nicknameTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }

}

