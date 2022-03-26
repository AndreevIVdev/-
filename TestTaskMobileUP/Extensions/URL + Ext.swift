//
//  URL + Ext.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 25.03.2022.
//

import Foundation

extension URL: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StaticString) {
        self.init(string: "\(value)")!
    }
}
