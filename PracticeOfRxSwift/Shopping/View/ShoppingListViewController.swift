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
    
    private let searchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "쇼핑할 것을 추가 혹은 검색해보세요!"
        searchBar.searchBarStyle = .minimal
        
        return searchBar
    }()
    private let addButton = {
        let button = UIButton()
        button.setTitle("추가", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .systemBlue
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        
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
        
        configureNavigationBar()
        configureHierarchy()
        configureLayout()
        configureView()
        
        bind()
    }
    
    func configureNavigationBar() {
        navigationItem.title = "쇼핑"
    }
    func configureHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(addButton)
        view.addSubview(tableView)
        view.addSubview(collectionView)
    }
    func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.equalTo(view.safeAreaLayoutGuide).inset(15)
        }
        
        addButton.snp.makeConstraints { make in
            make.centerY.equalTo(searchBar)
            make.height.equalTo(35)
            make.leading.equalTo(searchBar.snp.trailing).offset(5)
            make.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.equalTo(50)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(5)
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
        tableView.rowHeight = 60
    }
    
    static func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        layout.itemSize = CGSize(width: 80, height: 40)
        layout.scrollDirection = .horizontal
        
        return layout
    }
    
    func bind() {
        let completeCellIndex = PublishRelay<Int>()
        let starButtonCellIndex = PublishRelay<Int>()
        let input = ShoppingViewModel.Input(shoppingTitle: searchBar.rx.text.orEmpty, completeButtonCellIndex: completeCellIndex, starButtonCellIndex: starButtonCellIndex, addButtonTap: addButton.rx.tap, tableViewCellTapIndex: tableView.rx.itemSelected, tableViewCellTapModel: tableView.rx.modelSelected(Shopping.self), searchButtonClicked: searchBar.rx.searchButtonClicked)

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
