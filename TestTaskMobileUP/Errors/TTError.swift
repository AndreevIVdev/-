//
//  TTError.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import Foundation

enum TTError: String, Error {
    case serverProblem
    case accessDenied
    case noData
    case urlError
    case invalidResponse
    case internalError
    case invalidToken
    case unsuccessfulLogin
}
