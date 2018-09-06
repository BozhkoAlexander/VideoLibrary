//
//  DetailsTransition+DismissAnimator.swift
//  VideoLibrary
//
//  Created by Alexander Bozhko on 05/09/2018.
//

import UIKit

extension DetailsTransition {
    
    class DismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
        
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
        
        init(videoView: VideoView?, finalFrame: CGRect?, finalSuperview: UIView?, isInteractive: Bool) {
            super.init()
            self.videoView = videoView
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
            
            let snapshot = prepare(using: transitionContext)
            animate(using: transitionContext, snapshot: snapshot) {
                DismissAnimator.complete(using: transitionContext, snapshot: snapshot, videoView: videoView, finalSuperview: finalSuperview, delegate: delegate)
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
        
        // MARK: - Helpers
        
        func prepare(using context: UIViewControllerContextTransitioning) -> UIView? {
            guard
                let fromVC = context.viewController(forKey: .from),
                let fromView = fromVC.view
                else {
                    context.completeTransition(false)
                    return nil
            }
            delegate?.prepare(using: context, isPresentation: false)
            let container = context.containerView
            
            if let frame = videoView?.superview?.convert(videoView!.frame, to: container) {
                videoView?.frame = frame
            }
            
            let snapshot = fromView.snapshotView(afterScreenUpdates: false)
            snapshot?.contentMode = .top
            if snapshot != nil { container.addSubview(snapshot!) }
            if let videoView = videoView { container.addSubview(videoView) }
            
            fromView.isHidden = true
            
            return snapshot
        }
        
        func animate(using context: UIViewControllerContextTransitioning, snapshot: UIView?, with completion: (() -> Void)?) {
            delegate?.animate(using: context, isPresentation: false)
            UIView.animate(withDuration: collapseDuration, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.collapse(using: context, snapshot: snapshot)
                }, completion: nil)
            UIView.animate(withDuration: moveDuration, delay: collapseDuration, options: .curveEaseIn, animations: { [weak self] in
                self?.move(using: context, snapshot: snapshot)
            }) { _ in
                completion?()
            }
        }
        
        func collapse(using context: UIViewControllerContextTransitioning, snapshot: UIView?) {
            let container = context.containerView
            // transform members
            if let videoView = videoView, let finalFrame = finalFrame {
                let k = finalFrame.width / videoView.frame.width
                let transform = videoView.transform.scaledBy(x: k, y: k)
                videoView.transform = transform
                videoView.center.x = container.bounds.midX
                videoView.frame.origin.y += round((1 - k) * 0.5 * videoView.bounds.height)
            }
            if let snapshot = snapshot {
                let center = snapshot.center
                snapshot.transform = snapshot.transform.scaledBy(x: 0.9, y: 0.9)
                snapshot.center = center
            }
            
            //apply properties to members
            snapshot?.applyProperties()
            videoView?.applyProperties()
        }
        
        func move(using context: UIViewControllerContextTransitioning, snapshot: UIView?) {
            guard
                let toVC = context.viewController(forKey: .to),
                let toView = toVC.view else {
                    context.completeTransition(false)
                    return
            }
            if let finalFrame = finalFrame {
                videoView?.frame = finalFrame
                snapshot?.frame = finalFrame
            } else {
                snapshot?.frame.origin.y = context.containerView.frame.maxY
            }
            // disable blur
            toView.disableBlur()
        }
        
        class func complete(using context: UIViewControllerContextTransitioning, snapshot: UIView?, videoView: VideoView?, finalSuperview: UIView?, delegate: DetailsAnimatorDelegate?) {
            guard
                let fromVC = context.viewController(forKey: .from),
                let toVC = context.viewController(forKey: .to),
                let fromView = fromVC.view,
                let toView = toVC.view else { return }
            
            snapshot?.removeFromSuperview()
            if context.transitionWasCancelled {
                toView.enableBlur()
                fromView.isHidden = false
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
