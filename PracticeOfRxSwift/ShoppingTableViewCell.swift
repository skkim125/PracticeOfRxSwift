//
//  CustomTableViewCell.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ShoppingTableViewCell: UITableViewCell {
    
    static let id = "ShoppingTableViewCell"
    
    let completeButton = UIButton()
    let shoppingTitleLabel = UILabel()
    let starButton = UIButton()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureHierarchy()
        configureLayout()
        configureCell()
        
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.darkGray.cgColor
    }
    
    private func configureHierarchy() {
        contentView.addSubview(completeButton)
        contentView.addSubview(shoppingTitleLabel)
        contentView.addSubview(starButton)
    }
    
    private func configureLayout() {
        completeButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.verticalEdges.leading.equalTo(contentView.safeAreaLayoutGuide).inset(10)
        }
        
        shoppingTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(completeButton.snp.trailing).offset(10)
            make.height.equalTo(40)
            make.centerY.equalTo(completeButton)
        }
        
        starButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.leading.equalTo(shoppingTitleLabel.snp.trailing).offset(10)
            make.verticalEdges.trailing.equalTo(contentView.safeAreaLayoutGuide).inset(10)
        }
    }
    
    func configureCell() {
        completeButton.tintColor = .black
        starButton.tintColor = .black
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
