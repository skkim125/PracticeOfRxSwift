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
        tv.sectionFooterHeight = 5
        tv.register(ShoppingTableViewCell.self, forCellReuseIdentifier: ShoppingTableViewCell.id)
        
        return tv
    }()
    
    private var shoppingList = ShoppingList.shared.shoppingList
    lazy var list = BehaviorSubject(value: shoppingList)
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
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(shoppingTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    func configureView() {
        view.backgroundColor = .white
        
        shoppingTextField.backgroundColor = .lightGray.withAlphaComponent(0.3)
        addButton.backgroundColor = .lightGray
    }
    
    func bind() {
        list
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                let isCompletedImage = element.isCompleted ? "checkmark.square.fill" : "checkmark.square"
                let isStaredImage = element.isStared ? "star.fill" : "star"
                
                cell.shoppingTitleLabel.text = element.title
                cell.completeButton.setImage(UIImage(systemName: isCompletedImage), for: .normal)
                cell.starButton.setImage(UIImage(systemName: isStaredImage), for: .normal)
            }
            .disposed(by: disposeBag)

    }
}

struct Shopping {
    let title: String
    var isCompleted: Bool
    var isStared: Bool
}

final class ShoppingList {
    static let shared = ShoppingList()
    private init() { }
    
    let shoppingList: [Shopping] = [
        Shopping(title: "한우 투쁠", isCompleted: false, isStared: true),
        Shopping(title: "상추", isCompleted: false, isStared: false),
        Shopping(title: "사이다", isCompleted: true, isStared: false),
        Shopping(title: "돗자리", isCompleted: true, isStared: true),
    ]
}
