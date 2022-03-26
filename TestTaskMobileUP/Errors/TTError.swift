//
//  TTError.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import Foundation

enum TTError: String, Error {
    case accessDenied
    case noData
    case stockError
    case urlError
    case invalidResponse
}
