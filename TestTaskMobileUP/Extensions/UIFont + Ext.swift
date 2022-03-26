//
//  UIFont + Ext.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit

extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }

    func bold() -> UIFont {
        withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        withTraits(traits: .traitItalic)
    }
}
