//
//  Constants.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit

enum Constants {
    static let applicationID: String = "8115098"
}

enum Design {
    static let padding: CGFloat = 24
    static let bottomPadding: CGFloat = 50
    static let buttonHeight: CGFloat = 55
    static let cornerRadius: CGFloat = 5
}

enum Images {
    static let placeholder: UIImage = .init(named: "placeholder")!
}

enum ScreenSize {
    
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let maxLength = max(height, width)
    static let minLength = min(height, width)
}

enum DeviceTypes {
    
    static let idiom = UIDevice.current.userInterfaceIdiom
    static let nativeScale = UIScreen.main.nativeScale
    static let scale = UIScreen.main.scale
    
    static let isiPhoneSE = idiom == .phone && ScreenSize.maxLength == 568.0
    static let isiPhone8Standard = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale == scale
    static let isiPhone8Zoomed = idiom == .phone && ScreenSize.maxLength == 667.0 && nativeScale > scale
    static let isiPhone8PlusStandard = idiom == .phone && ScreenSize.maxLength == 736.0
    static let isiPhone8PlusZoomed = idiom == .phone && ScreenSize.maxLength == 736.0 && nativeScale < scale
    static let isiPhoneX = idiom == .phone && ScreenSize.maxLength == 812.0
    static let isiPhoneXsMaxAndXr = idiom == .phone && ScreenSize.maxLength == 896.0
    static let isiPad = idiom == .pad && ScreenSize.maxLength >= 1024.0
    
    static func isIphoneXAspectRatio() -> Bool {
        isiPhoneX && isiPhoneXsMaxAndXr
    }
}
