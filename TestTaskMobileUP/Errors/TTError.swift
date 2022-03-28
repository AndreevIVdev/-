//
//  TTError.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import Foundation

enum TTError: String, Error {
    case serverProblem = "Something went wrong on the server side, please try again later"
    case accessDenied = "Access denied, please relogin"
    case noData = "Something went wrong with internet, please try again later"
    case urlError = "Internal error"
    case invalidResponse = "Something went wrong with VK servers, please try again later"
    case internalError = "Application internal logic error"
    case invalidToken = "Authorisation error, please relogin"
}
