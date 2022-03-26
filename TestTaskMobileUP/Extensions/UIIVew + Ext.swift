//
//  UIIVew + Ext.swift
//  MobileUPTestTask
//
//  Created by Илья Андреев on 25.03.2022.
//

import UIKit

extension UIView {
    func addSubViews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }
}
