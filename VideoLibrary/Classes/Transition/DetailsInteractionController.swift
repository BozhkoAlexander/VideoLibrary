//
//  DetailsInteractionController.swift
//  video app
//
//  Created by Alexander Bozhko on 27/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

class DetailsInteractionController: UIPercentDrivenInteractiveTransition {
    
    private var isCancelled: Bool = false
    
    private var isCompleted: Bool = false
    
    private var isFinished: Bool {
        return !isCancelled && !isCompleted
    }
    
    override func cancel() {
        guard !isFinished else { return }
        super.cancel()
        isCancelled = true
    }
    
    override func finish() {
        guard !isFinished else { return }
        super.cancel()
        isCompleted = true
    }

}

extension UIViewController {
    
    @objc func handleInteractiveDismissal(_ pan: UIPanGestureRecognizer) {
        guard let transition = transition else { return }
        let scrollView = pan.view as? UIScrollView
        if scrollView != nil && scrollView!.contentOffset.y > 0 {
            cancelDismissal(pan)
            return
        }
        let height = (UIScreen.main.bounds.height / 2)
        let point = pan.translation(in: nil)
        let progress = min(1, max(0, point.y / height))
        switch pan.state {
        case .changed where transition.interactionController == nil && point.y > 0:
            startDismissal(pan)
        case .changed:
            if progress > 0.5 {
                finishDismissal(pan)
            } else {
                transition.interactionController?.update(progress)
            }
        case .ended where progress > 0.5:
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
        } else {
            return navigationController?.transitioningDelegate as? DetailsTransition
        }
    }
    
    private func startDismissal(_ pan: UIPanGestureRecognizer) {
        transition?.interactionController = DetailsInteractionController()
        (pan.view as? UIScrollView)?.isScrollEnabled = false
        dismiss(animated: true) {
            let vc = UIViewController.presented()
            Video.shared.sync(for: vc)
        }
    }
    
    private func cancelDismissal(_ pan: UIPanGestureRecognizer) {
        transition?.interactionController?.cancel()
        (pan.view as? UIScrollView)?.isScrollEnabled = true
    }
    
    private func finishDismissal(_ pan: UIPanGestureRecognizer) {
        transition?.interactionController?.finish()
        (pan.view as? UIScrollView)?.isScrollEnabled = true
    }
    
}
