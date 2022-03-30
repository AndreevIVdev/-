//
//  UIIVew + Ext.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit

extension UIView {
    /// Adds many views to subviews
    /// - Parameter views: views to add
    func addSubViews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
