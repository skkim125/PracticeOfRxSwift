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
        let input = ShoppingViewModel.Input(shoppingTitle: shoppingTextField.rx.text.orEmpty, addButtonTap: addButton.rx.tap)
        var output = viewModel.transform(input: input)
        
        output.list
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.id, cellType: ShoppingTableViewCell.self)) { (row, element, cell) in
                
                cell.configureCell(shopping: element)
                
                cell.output.completeButtonTap
                    .bind(with: self) { _, _ in
                        output.shoppingisCompletedChange(row)
                    }
                    .disposed(by: cell.disposeBag)
                
                cell.output.starButtonTap
                    .bind(with: self) { _, _ in
                        output.shoppingisStaredChange(row)
                    }
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.addButtonTap
            .withLatestFrom(output.shoppingTitle) { _, title in
                return title
            }
            .bind(with: self) { owner, title in
                if !title.isEmpty {
                    output.addNewShopping(title: title)
                } else {
                    owner.showAlert()
                }
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(with: self) { owner, indexPath in
                let data = output.shoppingList[indexPath.row]
                
                let vc = ShoppingDetailViewController()
                vc.configureView(shopping: data)
                vc.shopping = data
                
                vc.moveData = { editShopping in
                    output.editShopping(indexPath.row, editShopping: editShopping)
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
    
    private func shoppingStatusChange(output: inout ShoppingViewModel.Output, _ index: Int) {
        output.shoppingList[index].isCompleted.toggle()
        output.list.accept(output.shoppingList)
    }
}
