//
//  BirthDayViewModel.swift
//  PracticeOfRxSwift
//
//  Created by 김상규 on 8/5/24.
//

import Foundation
import RxSwift
import RxCocoa

final class BirthdayViewModel {
    private let disposeBag = DisposeBag()
    struct Input {
        let birth: ControlProperty<Date>
        let nextButtonTap: ControlEvent<Void>
    }
    
    struct Output {
        let year: BehaviorRelay<Int>
        let month: BehaviorRelay<Int>
        let day: BehaviorRelay<Int>
        let infoLabelText: BehaviorRelay<String>
        let validAge: BehaviorRelay<Bool>
        let nextButtonTap: ControlEvent<Void>
    }
    
    func transform(input: Input) -> Output {
        let date = input.birth
        let year = BehaviorRelay(value: 0)
        let month = BehaviorRelay(value: 0)
        let day = BehaviorRelay(value: 0)
        let nextButtonTap = input.nextButtonTap
        let text = BehaviorRelay(value: "")
        let validAge = BehaviorRelay(value: false)
        
        date
            .bind(with: self) { owner, birth in
                let component = Calendar.current.dateComponents([.year, .month, .day], from: birth)
                
                guard let y = component.year, let m = component.month, let d = component.day else { return }
                
                year.accept(y)
                month.accept(m)
                day.accept(d)
                
                let age = owner.compareAge(date: birth)
                
                if age < 17 {
                    text.accept("만 17세 이상만 가입 가능합니다.")
                    validAge.accept(false)
                } else {
                    text.accept("가입 가능한 나이입니다.")
                    validAge.accept(true)
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(year: year, month: month, day: day, infoLabelText: text, validAge: validAge, nextButtonTap: nextButtonTap)
    }
    
    private func compareAge(date: Date) -> Int {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: date)
        
        guard let year = component.year, let month = component.month, let day = component.day else { return -1}
        
        let currentDate = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        
        guard let currentYear = currentDate.year, let currentMonth = currentDate.month, let currentDay = currentDate.day else { return -1 }
        
        let age = currentYear - year //  < 17
        let isCompareMonth = currentMonth < month
        let isCompareDay = (currentMonth == month) && (currentDay < day)
        
        if isCompareMonth || isCompareDay {
            return age - 1
        }
        
        return age
    }
}
