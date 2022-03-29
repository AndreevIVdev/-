//
//  String + Ext.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 29.03.2022.
//

import Foundation

extension String {
    func localized() -> String {
        NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .main,
            value: self,
            comment: self
        )
    }
}
