//
//  DetailsInteractionController.swift
//  video app
//
//  Created by Alexander Bozhko on 27/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

class DetailsInteractionController: UIPercentDrivenInteractiveTransition {

}

extension UIViewController {
    
    @objc func handleInteractiveDismissal(_ pan: UIPanGestureRecognizer) {
        guard let transition = transition else { return }
        let scrollView = pan.view as? UIScrollView
        if scrollView != nil && scrollView!.contentOffset.y > 0 {
            cancelDismissal(pan)
            return
        }
        let height = UIScreen.main.bounds.height
        let point = pan.translation(in: nil)
        let velocity = pan.velocity(in: nil).y
        let progress = min(1, max(0, point.y / height))
        switch pan.state {
        case .changed where transition.interactionController == nil && point.y > 0:
            startDismissal(pan)
        case .changed:
            transition.interactionController?.update(progress)
        case .ended where velocity > 0 || (velocity == 0 && progress > 0.5):
            finishDismissal(pan)
        case .ended,
             .cancelled: cancelDismissal(pan)
        default: break
        }
    }
    
    // MARK: - Helpers
    
    private var transition: DetailsTransition? {
        if let transition = transitioningDelegate as? DetailsTransition {
            return transition
        }
        return navigationController?.transitioningDelegate as? DetailsTransition
    }
    
    private func startDismissal(_ pan: UIPanGestureRecognizer) {
        transition?.interactionController = DetailsInteractionController()
        var vc = presentingViewController
        if let nc = vc as? UINavigationController {
            vc = nc.viewControllers.last
        }
        (pan.view as? UIScrollView)?.isScrollEnabled = false
        dismiss(animated: true) {
            Video.shared.sync(for: vc)
        }
    }
    
    private func cancelDismissal(_ pan: UIPanGestureRecognizer) {
        transition?.interactionController?.cancel()
        transition?.interactionController = nil
        (pan.view as? UIScrollView)?.isScrollEnabled = true
    }
    
    private func finishDismissal(_ pan: UIPanGestureRecognizer) {
        transition?.interactionController?.finish()
        transition?.interactionController = nil
        (pan.view as? UIScrollView)?.isScrollEnabled = true
    }
    
}
