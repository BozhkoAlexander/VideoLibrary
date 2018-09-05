//
//  DetailsAnimator.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

class DetailsAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private var videoView: VideoView? = nil
    private var isPresent: Bool
    private let transitionDuration: TimeInterval = 0.35
    
    private weak var superview: UIView? = nil
    private var fromFrame: CGRect? = nil
    private var cornerRadius: CGFloat = 0
    
    var delegate: DetailsAnimatorDelegate? = nil
    
    init(_ senderView: VideoView?, isPresent: Bool = true, superview: UIView? = nil, fromFrame: CGRect? = nil, fromRadius: CGFloat? = nil) {
        self.videoView = senderView
        self.isPresent = isPresent
        super.init()
        
        self.superview = superview
        self.fromFrame = fromFrame
        self.cornerRadius = fromRadius ?? 0
    }
    
    // MARK: - Animated transitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        prepare(using: transitionContext)
        let delegate = self.delegate
        let isPresent = self.isPresent
        let senderView = self.videoView
        let superview = self.superview
        
        UIView.animate(withDuration: transitionDuration, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
            self?.animate(using: transitionContext)
        }) { (completed) in
            DetailsAnimator.finish(using: transitionContext, senderView: senderView, superview: superview, isPresent: isPresent, delegate: delegate)
        }
    }
    
    // MARK: - animations
    
    private func prepare(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        let fromView = transitionContext.viewController(forKey: .from)!.view!
        let toVC = transitionContext.viewController(forKey: .to)!
        let toView = toVC.view!
        
        


        if isPresent {
            toView.clipsToBounds = true
            toView.layer.cornerRadius = cornerRadius
            
            if let frame = videoView?.superview?.convert(videoView!.frame, to: fromView) {
                videoView?.frame = frame
            }
            
            if let frame = fromFrame {
                toView.frame = frame
            } else if let videoView = videoView {
               toView.frame = videoView.frame
            } else {
                toView.frame = transitionContext.finalFrame(for: toVC)
                toView.frame.origin.y = UIScreen.main.bounds.height
            }
            containerView.addSubview(toView)
            if videoView != nil { containerView.addSubview(videoView!) }
            
            // add blur to fromview
            fromView.addBlurView()
        }
        
        if videoView != nil {
            containerView.addSubview(videoView!)
        }
        
        delegate?.prepare(using: transitionContext, isPresentation: isPresent)
    }
    
    private func animate(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewController(forKey: .from)!.view!
        let toVC = transitionContext.viewController(forKey: .to)!
        let toView = toVC.view!
        
        if isPresent {
            let finalFrame = transitionContext.finalFrame(for: toVC)

            if let videoView = videoView {
                videoView.layer.cornerRadius = 0
                let k = finalFrame.width / videoView.frame.width
                videoView.transform = CGAffineTransform(scaleX: k, y: k)
                if #available(iOS 11.0, *) {
                    videoView.frame.origin = CGPoint(x: toView.safeAreaInsets.left, y: toView.safeAreaInsets.top)
                } else {
                    videoView.frame.origin = .zero
                }
            }
            
            toView.layer.cornerRadius = 0
            toView.frame = finalFrame
            fromView.enableBlur()
        } else {
            videoView?.layer.cornerRadius = cornerRadius
            fromView.layer.cornerRadius = cornerRadius
            fromView.clipsToBounds = true
            fromView.alpha = 0
            if let finalFrame = fromFrame {
                let k = finalFrame.width / fromView.frame.width
                fromView.transform = CGAffineTransform(scaleX: k, y: k)
                fromView.frame.origin = finalFrame.origin
                if let videoView = videoView {
                    videoView.frame = finalFrame
//                    videoView.transform = CGAffineTransform(scaleX: k, y: k)
//                    videoView.frame.origin = finalFrame.origin
                }
            } else {
                fromView.frame.origin.y = UIScreen.main.bounds.height
                fromView.frame.origin.x = 0
            }

            toView.disableBlur()
        }
        
        delegate?.animate(using: transitionContext, isPresentation: isPresent)
    }
    
    class func finish(using transitionContext: UIViewControllerContextTransitioning, senderView: VideoView?, superview: UIView?, isPresent: Bool, delegate: DetailsAnimatorDelegate?) {
        let toView = transitionContext.viewController(forKey: .to)!.view!
        
        if isPresent {
            if let videoView = senderView {
                let frame = videoView.frame
                videoView.transform = CGAffineTransform.identity
                videoView.frame = frame
                if let superview = superview {
                    superview.addSubview(videoView)
                    videoView.frame = superview.convert(frame, from: nil)
                }
            }
        } else {
            // remove blur
            toView.removeBlurView()
            
            if let videoView = senderView {
                let frame = videoView.frame
//                videoView.transform = CGAffineTransform.identity
//                videoView.frame = frame
                if let superview = superview {
                    superview.addSubview(videoView)
                    videoView.frame = superview.convert(frame, from: nil)
                }
            }
        }
        
        delegate?.finish(using: transitionContext, isPresentation: isPresent)
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
}
