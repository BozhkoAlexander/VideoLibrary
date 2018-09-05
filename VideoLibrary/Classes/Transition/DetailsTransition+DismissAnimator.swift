//
//  DetailsTransition+DismissAnimator.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 05/09/2018.
//

import UIKit

extension DetailsTransition {
    
    class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        /** This view is used to set animated properties to transition proccess */
        private var sender: UIView? = nil
        
        /** This view is used for animated video view transfer */
        private var videoView: VideoView? = nil
        
        private let moveDuration: TimeInterval = 0.35
        private let collapseDuration: TimeInterval = 0.35
        
        init(videoView: VideoView?, sender: UIView?) {
            super.init()
            self.videoView = videoView
            self.sender = sender
        }
        
        // MARK: - Transitioning context
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return collapseDuration + moveDuration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let videoView = self.videoView
            
            prepare(using: transitionContext)
            animate(using: transitionContext) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                DismissAnimator.complete(using: transitionContext, videoView: videoView)
            }
        }
        
        // MARK: - Helpers
        
        private func prepare(using context: UIViewControllerContextTransitioning) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let toVC = context.viewController(forKey: .to),
                let fromView = fromVC.view,
                let toView = toVC.view else { return }
            let container = context.containerView
            container.clipsToBounds = true
            
            // calculate initial frame
            var initialFrame: CGRect! = videoView?.superview?.convert(videoView!.frame, to: container)
            if initialFrame == nil {
                initialFrame = sender?.superview?.convert(sender!.frame, to: container)
                if initialFrame == nil {
                    initialFrame = context.finalFrame(for: toVC)
                    initialFrame.origin.y = initialFrame.maxY
                }
            }
            toView.frame = initialFrame
            videoView?.frame = initialFrame
            
            // apply initial properties
            toView.applyProperties(from: sender)
            videoView?.applyProperties(from: sender)
            
            // add members to transition container
            container.addSubview(toView)
            if let videoView = videoView { container.addSubview(videoView) }
            
            //add blur
            fromView.addBlurView()
        }
        
        private func animate(using context: UIViewControllerContextTransitioning, with completion: (() -> Void)?) {
            UIView.animate(withDuration: collapseDuration, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                self?.move(using: context)
                }, completion: nil)
            UIView.animate(withDuration: moveDuration, delay: collapseDuration, options: .curveEaseOut, animations: { [weak self] in
                self?.expand(using: context)
            }) { _ in
                completion?()
            }
        }
        
        private func move(using context: UIViewControllerContextTransitioning) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let toVC = context.viewController(forKey: .to),
                let fromView = fromVC.view,
                let toView = toVC.view else { return }
            let container = context.containerView
            
            // transform members
            if sender != nil {
                var finalFrame = context.finalFrame(for: toVC)
                var safeInset: UIEdgeInsets! = nil
                if #available(iOS 11.0, *) {
                    safeInset = fromView.safeAreaInsets
                } else {
                    safeInset = UIEdgeInsets(top: UIApplication.shared.statusBarFrame.maxY, left: 0, bottom: 0, right: 0)
                }
                finalFrame = UIEdgeInsetsInsetRect(finalFrame, safeInset)
                
                let k = finalFrame.width / toView.frame.width
                let transform = toView.transform.scaledBy(x: k, y: k)
                toView.transform = transform
                videoView?.transform = transform
                
                // apply properties to members
                toView.applyProperties(from: container)
                videoView?.applyProperties(from: container)
                
                // move members
                toView.frame.origin = finalFrame.origin
                videoView?.frame.origin = finalFrame.origin
            }
            
            // enbale blur
            fromView.enableBlur()
        }
        
        private func expand(using context: UIViewControllerContextTransitioning) {
            guard
                let toVC = context.viewController(forKey: .to),
                let toView = toVC.view else { return }
            
            toView.frame = context.finalFrame(for: toVC)
        }
        
        private class func complete(using context: UIViewControllerContextTransitioning, videoView: VideoView?) {
            videoView?.removeFromSuperview()
        }
        
    }
    
}
