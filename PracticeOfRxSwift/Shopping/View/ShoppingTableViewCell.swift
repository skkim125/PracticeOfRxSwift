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
    private let bgView = UIView()
    let completeButton = UIButton()
    let shoppingTitleLabel = UILabel()
    let starButton = UIButton()
    
    var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureHierarchy()
        configureLayout()
    }
    
    private func configureHierarchy() {
        contentView.addSubview(bgView)
        contentView.addSubview(completeButton)
        contentView.addSubview(shoppingTitleLabel)
        contentView.addSubview(starButton)
    }
    
    private func configureLayout() {
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(2)
        }
        
        completeButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.centerY.equalTo(bgView.snp.centerY)
            make.leading.equalTo(bgView.safeAreaLayoutGuide).inset(10)
        }
        
        shoppingTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(completeButton.snp.trailing).offset(10)
            make.height.equalTo(40)
            make.centerY.equalTo(completeButton)
        }
        
        starButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.leading.equalTo(shoppingTitleLabel.snp.trailing).offset(10)
            make.centerY.equalTo(bgView.snp.centerY)
            make.trailing.equalTo(bgView.safeAreaLayoutGuide).inset(10)
        }
    }
    
    func configureCell(shopping: Shopping) {
        bgView.layer.borderWidth = 1
        bgView.layer.borderColor = UIColor.darkGray.cgColor
        bgView.clipsToBounds = true
        bgView.layer.cornerRadius = 4
        
        completeButton.tintColor = .black
        starButton.tintColor = .black
        
        let isCompletedImage = shopping.isCompleted ? "checkmark.square.fill" : "checkmark.square"
        let isStaredImage = shopping.isStared ? "star.fill" : "star"
        
        shoppingTitleLabel.text = shopping.title
        completeButton.setImage(UIImage(systemName: isCompletedImage), for: .normal)
        starButton.setImage(UIImage(systemName: isStaredImage), for: .normal)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .white
        
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 5, right: 0))
    }
}
