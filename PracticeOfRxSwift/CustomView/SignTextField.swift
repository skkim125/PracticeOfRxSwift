//
//  SignTextField.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/1/24.
//

import UIKit

class SignTextField: UITextField {
    
    init(placeholderText: String) {
        super.init(frame: .zero)
        
        textColor = Color.black
        placeholder = placeholderText
        textAlignment = .center
        borderStyle = .none
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = Color.black.cgColor
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
