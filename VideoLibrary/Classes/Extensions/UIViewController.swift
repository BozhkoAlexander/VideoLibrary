//
//  UIViewController.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 06/09/2018.
//

import UIKit

extension UIViewController {
    
    class func presented(_ viewController: UIViewController? = nil) -> UIViewController? {
        let vc = viewController ?? UIApplication.shared.keyWindow?.rootViewController
        if let presentedVC = vc?.presentedViewController {
            return presented(presentedVC)
        } else {
            if let navigationController = vc as? UINavigationController {
                return navigationController.viewControllers.last ?? navigationController
            } else if let tabController = vc as? UITabBarController, let selectedVC = tabController.selectedViewController {
                return presented(selectedVC)
            } else if let child = vc?.children.last {
                return presented(child)
            }
            return vc
        }
    }
    
}
