//
//  NewTransition+DismissAnimator.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 12/11/2018.
//

import UIKit

extension DetailsTransition {
    
    class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        var isInteractive: Bool = false
        
        private var scale: CGFloat = 1
        private var finalFrame: CGRect = .zero
        
        private var sender: UIView? = nil
        
        private let duration: TimeInterval
        
        init(_ sender: UIView?) {
            self.duration = sender != nil ? 0.5 : 0.25
            super.init()
            self.sender = sender
        }
        
        // MARK: Transitioning
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return duration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            prepare(using: transitionContext)
            animate(using: transitionContext) {
                DismissAnimator.complete(using: transitionContext)
            }
        }
        
        private func prepare(using context: UIViewControllerContextTransitioning) {
            let container = context.containerView
            guard let fromView = context.view(forKey: .from) else {
                context.completeTransition(false)
                return
            }
            let toVC = context.viewController(forKey: .to)
            toVC?.beginAppearanceTransition(true, animated: true)
            
            if let videoView = (sender as? VideoCell)?.videoView, let superview = videoView.superview  {
                scale = videoView.frame.width / fromView.frame.width
                finalFrame = superview.convert(videoView.frame, to: container)
            } else if let sender = sender, let superview = sender.superview {
                scale = sender.frame.width / fromView.frame.width
                finalFrame = superview.convert(sender.frame, to: container)
            }
            fromView.clipsToBounds = true
        }
        
        private func animate(using context: UIViewControllerContextTransitioning, with completion: (() -> Void)?) {
            guard let fromView = context.view(forKey: .from) else {
                context.completeTransition(false)
                return
            }
            let scale = self.scale
            var finalFrame = self.finalFrame
            var cornderRadius: CGFloat = 0
            if let sender = sender {
                var topInset = UIApplication.shared.statusBarFrame.height
                if #available(iOS 11.0, *) {
                    topInset = fromView.safeAreaInsets.top
                }
                finalFrame.origin.y -= topInset
                finalFrame.size.height += topInset
                cornderRadius = sender.layer.cornerRadius
            }
            
            let relStartTime: Double = isInteractive ? 0.01 : 0
            let duration = self.duration * (isInteractive ? 2 : 1)
            let hasSender = sender != nil
            
            UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
                if hasSender {
                    UIView.addKeyframe(withRelativeStartTime: relStartTime, relativeDuration: 0.5) {
                        fromView.transform = CGAffineTransform(scaleX: scale, y: scale)
                        fromView.layer.cornerRadius = cornderRadius
                    }
                }
                let relDuration = hasSender ? 0.5 : 1
                UIView.addKeyframe(withRelativeStartTime: 1 - relDuration, relativeDuration: relDuration) {
                    context.containerView.disableBlur()
                    if finalFrame != .zero {
                        fromView.frame = finalFrame
                    } else {
                        fromView.frame.origin.y = context.containerView.bounds.maxY
                    }
                }
            }) { (_) in
                completion?()
            }
        }
        
        private class func complete(using context: UIViewControllerContextTransitioning) {
            if context.transitionWasCancelled {
                context.containerView.enableBlur()
            } else {
                context.containerView.removeBlurView()
            }
            context.completeTransition(!context.transitionWasCancelled)
            
            let toVC = context.viewController(forKey: .to)
            if context.transitionWasCancelled {
                toVC?.beginAppearanceTransition(false, animated: true)
            }
            toVC?.endAppearanceTransition()
        }
        
    }
    
}
