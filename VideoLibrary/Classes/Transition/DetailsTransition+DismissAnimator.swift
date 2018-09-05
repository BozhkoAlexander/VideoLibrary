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
        
        /** Frame for video view which it has before presentation */
        private var finalFrame: CGRect? = nil
        
        /** Superview which was contained video view before presentation */
        private var finalSuperview: UIView? = nil
        
        /** Delegate for additional animations during the transition */
        public var delegate: DetailsAnimatorDelegate? = nil
        
        private var isInteractive: Bool = false
        
        var moveDuration: TimeInterval { return isInteractive ? 0.75 : 0.35 }
        var collapseDuration: TimeInterval { return isInteractive ? 0.25 : 0.35 }
        
        init(videoView: VideoView?, sender: UIView?, finalFrame: CGRect?, finalSuperview: UIView?, isInteractive: Bool) {
            super.init()
            self.videoView = videoView
            self.sender = sender
            self.finalFrame = finalFrame
            self.finalSuperview = finalSuperview
            self.isInteractive = isInteractive
        }
        
        // MARK: - Transitioning context
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return collapseDuration + moveDuration
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            let videoView = self.videoView
            let finalSuperview = self.finalSuperview
            let delegate = self.delegate
            
            prepare(using: transitionContext)
            animate(using: transitionContext) {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                DismissAnimator.complete(using: transitionContext, videoView: videoView, finalSuperview: finalSuperview, delegate: delegate)
            }
        }
        
        // MARK: - Helpers
        
        func prepare(using context: UIViewControllerContextTransitioning) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let fromView = fromVC.view
                else {
                    context.completeTransition(false)
                    return
            }
            delegate?.prepare(using: context, isPresentation: false)
            let container = context.containerView
            
            // calculate initial frame
            fromView.mask = UIView(frame: fromView.bounds)
            fromView.mask?.backgroundColor = .white
            if let frame = videoView?.superview?.convert(videoView!.frame, to: container) {
                videoView?.frame = frame
            }
            if let videoView = videoView { container.addSubview(videoView) }
        }
        
        func animate(using context: UIViewControllerContextTransitioning, with completion: (() -> Void)?) {
            delegate?.animate(using: context, isPresentation: false)
            UIView.animate(withDuration: collapseDuration, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.collapse(using: context)
                }, completion: nil)
            UIView.animate(withDuration: moveDuration, delay: collapseDuration, options: .curveEaseIn, animations: { [weak self] in
                self?.move(using: context)
            }) { _ in
                completion?()
            }
        }
        
        func collapse(using context: UIViewControllerContextTransitioning) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let fromView = fromVC.view
                else {
                    context.completeTransition(false)
                    return
            }
            
            // transform members
            if let videoView = videoView, let finalFrame = finalFrame {
                let k = finalFrame.width / videoView.frame.width
                let transform = videoView.transform.scaledBy(x: k, y: k)
                videoView.transform = transform
                videoView.center.x = fromView.frame.midX
                videoView.frame.origin.y += round((1 - k) * 0.5 * videoView.bounds.height)
                
                fromView.mask?.frame = videoView.frame
            } else {
                let center = fromView.center
                fromView.transform = fromView.transform.scaledBy(x: 0.9, y: 0.9)
                fromView.center = center
            }
            
            //apply properties to members
            fromView.mask?.applyProperties(from: sender)
            videoView?.applyProperties(from: sender)
        }
        
        func move(using context: UIViewControllerContextTransitioning) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let toVC = context.viewController(forKey: .to),
                let fromView = fromVC.view,
                let toView = toVC.view else {
                    context.completeTransition(false)
                    return
            }
            if let finalFrame = finalFrame {
                videoView?.frame = finalFrame
                fromView.mask?.frame = finalFrame
            } else {
                fromView.frame.origin.y = context.containerView.frame.maxY
            }
            // disable blur
            toView.disableBlur()
        }
        
        class func complete(using context: UIViewControllerContextTransitioning, videoView: VideoView?, finalSuperview: UIView?, delegate: DetailsAnimatorDelegate?) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let toVC = context.viewController(forKey: .to),
                let fromView = fromVC.view,
                let toView = toVC.view else { return }
            
            if context.transitionWasCancelled {
                toView.enableBlur()
                fromView.transform = .identity
                fromView.frame = context.initialFrame(for: fromVC)
                if let videoView = videoView {
                    let frame = videoView.frame
                    videoView.transform = .identity
                    videoView.frame = frame
                }
            } else {
                toView.removeBlurView()
                fromView.removeFromSuperview()
                if let videoView = videoView, let superview = finalSuperview {
                    videoView.frame = superview.convert(videoView.frame, from: nil)
                    finalSuperview?.addSubview(videoView)
                }
            }
            
            delegate?.finish(using: context, isPresentation: false)
        }
        
    }
    
}
