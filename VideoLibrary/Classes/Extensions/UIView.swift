//
//  UIView.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 05/09/2018.
//

import UIKit


extension UIView {
    
    // MARK: - Blur methods
    
    var blurView: UIVisualEffectView? {
        return subviews.compactMap({ $0 as? UIVisualEffectView }).filter({ $0.accessibilityIdentifier == "blur" }).first
    }
    
    func addBlurView() {
        guard !UIAccessibilityIsReduceTransparencyEnabled() && blurView == nil else { return }
        let effectView = UIVisualEffectView()
        effectView.accessibilityIdentifier = "blur"
        effectView.frame = bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(effectView)
    }
    
    func removeBlurView() {
        blurView?.removeFromSuperview()
    }
    
    func enableBlur() {
        blurView?.effect = UIBlurEffect(style: .light)
    }
    
    func disableBlur() {
        blurView?.effect = nil
    }
    
    // MARK: - Other
    
    /** Apply properties from one view to sedond */
    func applyProperties(from view: UIView?) {
        guard let view = view else {
            clipsToBounds = true
            layer.cornerRadius = 10
            return
        }
        clipsToBounds = view.clipsToBounds
        layer.cornerRadius = view.layer.cornerRadius
    }
    
}
