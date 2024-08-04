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
    private let emptyLabel = UILabel()
    
    private var shoppingList = ShoppingList.shared.shoppingList
    lazy var list = BehaviorSubject(value: shoppingList)
    private var shoppingTitle = PublishRelay<String>()
    
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
//        view.addSubview(emptyLabel)
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
        
//        emptyLabel.snp.makeConstraints { make in
//            make.center.equalTo(view.safeAreaLayoutGuide)
//        }
        
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
                
                cell.completeButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.shoppingList[row].isCompleted.toggle()
                        owner.list.onNext(owner.shoppingList)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.starButton.rx.tap
                    .bind(with: self) { owner, _ in
                        owner.shoppingList[row].isStared.toggle()
                        owner.list.onNext(owner.shoppingList)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        shoppingTextField.rx.text.orEmpty
            .bind(to: shoppingTitle)
            .disposed(by: disposeBag)

        addButton.rx.tap
            .withLatestFrom(shoppingTitle) { _, title in
                return title
            }
            .bind(with: self) { owner, title in
                if !title.isEmpty {
                    let newShopping = Shopping(title: title, isCompleted: false, isStared: false)
                    
                    owner.shoppingList.append(newShopping)
                    owner.list.onNext(owner.shoppingList)
                } else {
                    owner.showAlert()
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                let data = owner.shoppingList[indexPath.row]
                
                let vc = ShoppingDetailViewController()
                vc.configureView(shopping: data)
                vc.shopping = data
                
                vc.moveData = { editShopping in
                    owner.shoppingList[indexPath.row] = editShopping
                    owner.list.onNext(owner.shoppingList)
                }
                
                owner.navigationController?.pushViewController(vc, animated: true)
                owner.tableView.reloadRows(at: [indexPath], with: .automatic)
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
