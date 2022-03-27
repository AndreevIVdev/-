//
//  Int + Ext.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import Foundation

extension Int {
    func convertToTime() -> String {
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.locale = Locale(identifier: "ru_RU")
        dayTimePeriodFormatter.dateFormat = "d MMMM YYYY"
        return dayTimePeriodFormatter.string(from: NSDate(timeIntervalSince1970: TimeInterval(self)) as Date)
    }
}
