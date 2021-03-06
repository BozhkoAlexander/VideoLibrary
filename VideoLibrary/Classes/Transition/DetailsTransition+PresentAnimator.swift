//
//  NewTransition+PresentAnimator.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 09/11/2018.
//

import UIKit

extension DetailsTransition {
    
    class PresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
        private var sender: UIView? = nil
        
        private var initialFrame: CGRect = .zero
        private var scale: CGFloat = 1
        
        private let duration: TimeInterval
        
        init(_ sender: UIView?) {
            self.duration = sender != nil ? 0.5 : 0.35
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
                PresentAnimator.complete(using: transitionContext)
            }
        }
        
        private func prepare(using context: UIViewControllerContextTransitioning) {
            let container = context.containerView
            guard let toView = context.view(forKey: .to), let fromView = context.viewController(forKey: .from)?.view else {
                context.completeTransition(false)
                return
            }
            toView.frame = container.bounds
            toView.clipsToBounds = true

            let fromVC = context.viewController(forKey: .from)
            fromVC?.beginAppearanceTransition(false, animated: true)

            if let videoView = (sender as? VideoCell)?.videoView, let superview = videoView.superview {
                initialFrame = superview.convert(videoView.frame, to: container)
                scale = initialFrame.width / container.bounds.width
                
                toView.frame.size.height = toView.bounds.width * initialFrame.height / initialFrame.width
                toView.layer.cornerRadius = sender!.layer.cornerRadius
                toView.transform = CGAffineTransform(scaleX: scale, y: scale)
                toView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
                var topInset = UIApplication.shared.statusBarFrame.height
                if #available(iOS 11.0, *) {
                    topInset = fromView.safeAreaInsets.top
                }
                toView.frame.origin.y -= round(scale * topInset)
            } else if let sender = sender, let superview = sender.superview {
                initialFrame = superview.convert(sender.frame, to: container)
                scale = initialFrame.width / container.bounds.width
                toView.frame.size.height = toView.bounds.width * initialFrame.height / initialFrame.width
                toView.layer.cornerRadius = sender.layer.cornerRadius
                toView.transform = CGAffineTransform(scaleX: scale, y: scale)
                toView.center = CGPoint(x: initialFrame.midX, y: initialFrame.midY)
            } else {
                scale = 1
                
                toView.layer.cornerRadius = 0
                toView.center.x = container.bounds.midX
                toView.frame.origin.y = container.bounds.maxY
            }

            container.addBlurView()
            container.addSubview(toView)
        }
        
        private func animate(using context: UIViewControllerContextTransitioning, with completion: (() -> Void)?) {
            let container = context.containerView
            guard let toView = context.view(forKey: .to) else {
                context.completeTransition(false)
                return
            }
            
            let alphaDuration = sender != nil ? 0.1 * duration : 0
            let moveDuration = sender != nil ? 0.5 * duration : 0
            let transformDuration = sender != nil ? 0.4 * duration : duration
            let scale = self.scale
            if alphaDuration > 0 {
                toView.alpha = 0
                UIView.animate(withDuration: alphaDuration, delay: 0, animations: {
                    toView.alpha = 1
                })
            }
            if moveDuration > 0 {
                UIView.animate(withDuration: moveDuration, delay: alphaDuration, options: .curveEaseInOut, animations: {
                    toView.frame.size.height = round(container.bounds.height * scale)
                    toView.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
                    container.enableBlur()
                })
            }
            UIView.animate(withDuration: transformDuration, delay: duration - transformDuration, options: .curveEaseInOut, animations: {
                toView.transform = CGAffineTransform.identity
                toView.layer.cornerRadius = 0
                toView.frame = container.bounds
            }) { (_) in
                completion?()
            }
        }
        
        private class func complete(using context: UIViewControllerContextTransitioning) {
            context.completeTransition(!context.transitionWasCancelled)
            let fromVC = context.viewController(forKey: .from)
            if context.transitionWasCancelled {
                fromVC?.beginAppearanceTransition(true, animated: true)
            }
            fromVC?.endAppearanceTransition()
        }
        
    }
    
}
