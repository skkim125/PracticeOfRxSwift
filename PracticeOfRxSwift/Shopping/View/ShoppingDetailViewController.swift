//
//  ShoppingDetailViewController.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ShoppingDetailViewController: UIViewController {
    private let shoppingTitleLabel = UILabel()
    private let completeButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGreen.cgColor
        
        return button
    }()
    private let starButton = {
        let button = UIButton()
        button.setTitle("중요", for: .normal)
        button.setImage(UIImage(systemName: "star.fill"), for: .normal)
        button.layer.cornerRadius = 4
        button.clipsToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemYellow.cgColor
        
        return button
    }()
    
    private let disposeBag = DisposeBag()
    let viewModel = ShoppingDetailViewModel()
    var moveData: ((Shopping) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        configureNavigationBar()
        configureHierarchy()
        configureLayout()
        
        bind()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "상세 정보"
    }
    
    private func configureHierarchy() {
        view.addSubview(shoppingTitleLabel)
        view.addSubview(completeButton)
        view.addSubview(starButton)
    }
    
    private func configureLayout() {
        shoppingTitleLabel.snp.makeConstraints { make in
            make.centerY.equalTo(view).offset(20)
            make.centerX.equalTo(view)
        }
        
        completeButton.snp.makeConstraints { make in
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        
        starButton.snp.makeConstraints { make in
            make.leading.equalTo(completeButton.snp.trailing).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.size.equalTo(completeButton)
        }
    }
    
    func configureView(shopping: Shopping) {
        let isCompletedButtonText = shopping.isCompleted ? "담기 완료" : "담기"
        let isCompletedButtonColor: UIColor = shopping.isCompleted ? .systemGreen : .white
        let isCompletedButtonTextColor: UIColor = shopping.isCompleted ? .white : .systemGreen
        let isStaredButtonColor: UIColor = shopping.isStared ? .systemYellow : .white
        let isStaredButtonTextColor: UIColor = shopping.isStared ? .white : .systemYellow
        
        shoppingTitleLabel.text = shopping.title
        
        completeButton.setTitle(isCompletedButtonText, for: .normal)
        completeButton.setTitleColor(isCompletedButtonTextColor, for: .normal)
        completeButton.imageView?.tintColor = isCompletedButtonTextColor
        completeButton.backgroundColor = isCompletedButtonColor
        
        starButton.setTitleColor(isStaredButtonTextColor, for: .normal)
        starButton.imageView?.tintColor = isStaredButtonTextColor
        starButton.backgroundColor = isStaredButtonColor
    }
    
    func bind() {
        let input = ShoppingDetailViewModel.Input(completeButtonTap: completeButton.rx.tap, starButtonTap: starButton.rx.tap)
        let output = viewModel.transform(input: input)
        var shopping = viewModel.shopping
        
        output.completeButtonTap
            .bind(with: self) { owner, _ in
                shopping?.isCompleted.toggle()
                guard let shopping = shopping else { return }
                owner.configureView(shopping: shopping)
                owner.viewModel.shopping = shopping
            }
            .disposed(by: disposeBag)
        
        output.starButtonTap
            .bind(with: self) { owner, _ in
                shopping?.isStared.toggle()
                guard let shopping = shopping else { return }
                owner.configureView(shopping: shopping)
                owner.viewModel.shopping = shopping
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let shopping = viewModel.shopping else { return }
        
        moveData?(shopping)
    }
}
