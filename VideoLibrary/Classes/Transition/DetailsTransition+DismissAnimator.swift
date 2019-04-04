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
            var cornerRadius: CGFloat = 0
            if let sender = sender {
                var topInset = UIApplication.shared.statusBarFrame.height
                if #available(iOS 11.0, *) {
                    topInset = fromView.safeAreaInsets.top
                }
                finalFrame.origin.y -= topInset
                finalFrame.size.height += topInset
                cornerRadius = sender.layer.cornerRadius
            }
            
            let relStartTime: Double = isInteractive ? 0.01 : 0
            let duration = transitionDuration(using: context)
            let hasSender = sender != nil
            
            if hasSender {
                if #available(iOS 10.0, *) {
                    let anim1 = UIViewPropertyAnimator(duration: 0.4 * duration, curve: .easeInOut) {
                        fromView.transform = CGAffineTransform(scaleX: scale, y: scale)
                        fromView.layer.cornerRadius = cornerRadius
                    }
                    let anim2 = UIViewPropertyAnimator(duration: 0.5 * duration, curve: .easeInOut) {
                        context.containerView.disableBlur()
                        if finalFrame != .zero {
                            fromView.frame = finalFrame
                        } else {
                            fromView.frame.origin.y = context.containerView.bounds.maxY
                        }
                    }
                    let anim3 = UIViewPropertyAnimator(duration: 0.1, curve: .linear) {
                        fromView.alpha = 0
                    }
                    anim1.addCompletion({ _ in
                        anim2.startAnimation()
                    })
                    anim2.addCompletion({ _ in
                        anim3.startAnimation()
                    })
                    anim3.addCompletion({ _ in
                        completion?()
                    })
                    anim1.startAnimation()
                } else {
                    UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
                        UIView.addKeyframe(withRelativeStartTime: relStartTime, relativeDuration: 0.5 - relStartTime) {
                            fromView.transform = CGAffineTransform(scaleX: scale, y: scale)
                            fromView.layer.cornerRadius = cornerRadius
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.49) {
                            context.containerView.disableBlur()
                            if finalFrame != .zero {
                                fromView.frame = finalFrame
                            } else {
                                fromView.frame.origin.y = context.containerView.bounds.maxY
                            }
                        }
                        UIView.addKeyframe(withRelativeStartTime: 0.99, relativeDuration: 0.01, animations: {
                            fromView.alpha = 0
                        })
                    }) { (_) in
                        completion?()
                    }
                }
            } else {
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
                    context.containerView.disableBlur()
                    if finalFrame != .zero {
                        fromView.frame = finalFrame
                    } else {
                        fromView.frame.origin.y = context.containerView.bounds.maxY
                    }
                }, completion: { (_) in
                    completion?()
                })
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
