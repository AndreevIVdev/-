//
//  UIFont + Ext.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit

extension UIFont {
    
    /// Adds bold weight to given font
    /// - Returns: updated font
    func bold() -> UIFont {
        .init(descriptor: fontDescriptor.withSymbolicTraits(.traitBold)!, size: 0)
    }
}
