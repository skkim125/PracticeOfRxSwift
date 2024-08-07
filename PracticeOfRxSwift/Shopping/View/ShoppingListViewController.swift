//
//  ShoppingListViewController.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class ShoppingListViewController: UIViewController {
    
    private let shoppingTextField = {
        let tf = UITextField()
        tf.placeholder = "무엇을 구매하실건가요?"
        tf.borderStyle = .roundedRect
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 60, height: 0 ))
        tf.rightViewMode = .always
        
        return tf
    }()
    private let addButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        
        return button
    }()
    private let tableView = {
        let tv = UITableView()
        tv.rowHeight = 60
        tv.separatorStyle = .none
        tv.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.id)
        
        return tv
    }()
    private let collectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        cv.register(ShoppingCollectionViewCell.self, forCellWithReuseIdentifier: ShoppingCollectionViewCell.id)
        
        return cv
    }()
    private let emptyLabel = UILabel()
    
    private let viewModel = ShoppingViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBaer()
        configureHierarchy()
        configureLayout()
        configureView()
        
        bind()
    }
    
    func configureNavigationBaer() {
        navigationItem.title = "쇼핑"
    }
    func configureHierarchy() {
        view.addSubview(shoppingTextField)
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(collectionView)
    }
    func configureLayout() {
        shoppingTextField.snp.makeConstraints { make in
            make.height.equalTo(55)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        addButton.snp.makeConstraints { make in
            make.verticalEdges.equalTo(shoppingTextField.snp.verticalEdges).inset(10)
            make.trailing.equalTo(shoppingTextField.snp.trailing).inset(10)
            make.width.equalTo(50)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(shoppingTextField.snp.bottom).offset(5)
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureView() {
        view.backgroundColor = .white
        
        shoppingTextField.backgroundColor = .systemGray6
        addButton.backgroundColor = .systemGray4
    }
    
    static func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.scrollDirection = .horizontal
        
        return layout
    }
    
    func bind() {
        let completeCellIndex = PublishRelay<Int>()
        let starButtonCellIndex = PublishRelay<Int>()
        let input = ShoppingViewModel.Input(shoppingTitle: shoppingTextField.rx.text.orEmpty, completeButtonCellIndex: completeCellIndex, starButtonCellIndex: starButtonCellIndex, addButtonTap: addButton.rx.tap, cellTapIndex: tableView.rx.itemSelected, cellTapModel: tableView.rx.modelSelected(Shopping.self))

        let output = viewModel.transform(input: input)
        
        output.recentSearchList
            .bind(to: collectionView.rx.items(cellIdentifier: ShoppingCollectionViewCell.id, cellType: ShoppingCollectionViewCell.self)) { (row, element, cell) in
                cell.layer.cornerRadius = 8
                cell.clipsToBounds = true
                cell.backgroundColor = .systemGray6
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.black.cgColor
                
                cell.label.text = element
            }
            .disposed(by: disposeBag)
        
        output.list
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                
                cell.selectionStyle = .none
                cell.configureCell(shopping: element)
                
                cell.completeButton.rx.tap
                    .map({ row })
                    .bind(with: self) { owner, index in
                        completeCellIndex.accept(index)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.starButton.rx.tap
                    .map({ row })
                    .bind(with: self) { owner, index in
                        starButtonCellIndex.accept(index)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .bind(with: self) { owner, _ in
                owner.showAlert()
            }
            .disposed(by: disposeBag)
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "한글자 이상 입력해주세요", message: nil, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "확인", style: .default)
        alert.addAction(ok)
        
        present(alert, animated: true)
    }
}
