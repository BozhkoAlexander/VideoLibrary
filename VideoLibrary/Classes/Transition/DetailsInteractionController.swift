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
        return isCancelled || isCompleted
    }
    
    override func cancel() {
        guard !isFinished else { return }
        super.cancel()
        isCancelled = true
    }
    
    override func finish() {
        guard !isFinished else { return}
        super.finish()
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
                pan.isEnabled = false
                pan.isEnabled = true
            } else {
                transition.interactionController?.update(progress)
            }
        case .ended where progress > 0.5:
            finishDismissal(pan)
            pan.isEnabled = false
            pan.isEnabled = true
        case .ended,
             .cancelled:
            cancelDismissal(pan)
            pan.isEnabled = false
            pan.isEnabled = true
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
            if vc is VideoViewController {
                Video.shared.sync(for: vc)
            } else {
                vc?.children.forEach({
                    Video.shared.sync(for: $0)
                })
            }
        }
    }
    
    private func cancelDismissal(_ pan: UIPanGestureRecognizer) {
        transition?.interactionController?.cancel()
        (pan.view as? UIScrollView)?.isScrollEnabled = true
        transition?.interactionController = nil
    }
    
    private func finishDismissal(_ pan: UIPanGestureRecognizer) {
        transition?.interactionController?.finish()
        (pan.view as? UIScrollView)?.isScrollEnabled = true
        transition?.interactionController = nil
    }
    
}
