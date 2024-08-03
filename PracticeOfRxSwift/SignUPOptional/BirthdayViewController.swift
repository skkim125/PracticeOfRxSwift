//
//  BirthdayViewController.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class BirthdayViewController: UIViewController {
    
    let birthDayPicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.locale = Locale(identifier: "ko-KR")
        picker.maximumDate = Date()
        return picker
    }()
    
    let infoLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        return label
    }()
    
    let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .equalSpacing
        stack.spacing = 10
        return stack
    }()
    
    let yearLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.textAlignment = .center
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let monthLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.textAlignment = .center
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
    
    let dayLabel: UILabel = {
       let label = UILabel()
        label.textColor = Color.black
        label.textAlignment = .center
        label.snp.makeConstraints {
            $0.width.equalTo(100)
        }
        return label
    }()
  
    let nextButton = PointButton(title: "가입하기")
    
    let year = BehaviorRelay(value: 0)
    let month = BehaviorRelay(value: 0)
    let day = BehaviorRelay(value: 0)
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = Color.white
        
        configureLayout()
        bind()
    }
    
    func configureLayout() {
        view.addSubview(infoLabel)
        view.addSubview(containerStackView)
        view.addSubview(birthDayPicker)
        view.addSubview(nextButton)
 
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(150)
            $0.centerX.equalToSuperview()
        }
        
        containerStackView.snp.makeConstraints {
            $0.top.equalTo(infoLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
        }
        
        [yearLabel, monthLabel, dayLabel].forEach {
            containerStackView.addArrangedSubview($0)
        }
        
        birthDayPicker.snp.makeConstraints {
            $0.top.equalTo(containerStackView.snp.bottom)
            $0.centerX.equalToSuperview()
        }
   
        nextButton.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.top.equalTo(birthDayPicker.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
    }
    
    func bind() {
        year
            .map({ "\($0)년" })
            .bind(to: yearLabel.rx.text)
            .disposed(by: disposeBag)
        
        month
            .map({ "\($0)월" })
            .bind(to: monthLabel.rx.text)
            .disposed(by: disposeBag)
        
        day
            .map({ "\($0)일" })
            .bind(to: dayLabel.rx.text)
            .disposed(by: disposeBag)
        
        birthDayPicker.rx.date
            .bind(with: self) { owner, date in
                owner.bindPickerDateToLabel(date: date)
                
                let isUnder17 = owner.compareAge(date: date) < 17
                owner.bindCompareAge(isUnder17: isUnder17)
            }
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .bind(with: self) { owner, _ in
                owner.navigationController?.pushViewController(SearchViewController(), animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindPickerDateToLabel(date: Date) {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        guard let y = component.year, let m = component.month, let d = component.day else { return }
        
        year.accept(y)
        month.accept(m)
        day.accept(d)
    }
    
    private func compareAge(date: Date) -> Int {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        guard let year = component.year, let month = component.month, let day = component.day else { return -1}
        
        let currentDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        guard let currentYear = currentDate.year, let currentMonth = currentDate.month, let currentDay = currentDate.day else { return -1 }
        
        var age = currentYear - year //  < 17
        let isCompareMonth = currentMonth < month
        let isCompareDay = (currentMonth == month) && (currentDay < day)
        
        if isCompareMonth || isCompareDay {
            return age - 1
        }
        
        return age
    }
    
    private func bindCompareAge(isUnder17: Bool) {
        nextButton.rx.isEnabled.onNext(!isUnder17)
        nextButton.rx.backgroundColor.onNext(isUnder17 ? .lightGray : .systemGreen)
        infoLabel.rx.textColor.onNext(isUnder17 ? .systemRed : .systemGreen)
        
        if isUnder17 {
            infoLabel.rx.text.onNext("만 17세 이상만 가입 가능합니다.")
        } else {
            infoLabel.rx.text.onNext("가입 가능한 나이입니다.")
        }
    }
}
