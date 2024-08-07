//
//  ShoppingCollectionViewCell.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/7/24.
//

import UIKit
import SnapKit

final class ShoppingCollectionViewCell: UICollectionViewCell {
    static let id = "ShoppingCollectionViewCell"
    
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureHierarchy()
        configureLayout()
        configureView()
    }
    
    func configureHierarchy() {
        contentView.addSubview(label)
    }
    
    func configureLayout() {
        label.snp.makeConstraints { make in
            make.edges.equalTo(contentView.safeAreaLayoutGuide)
        }
    }
    
    func configureView() {
        label.textAlignment = .center
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
