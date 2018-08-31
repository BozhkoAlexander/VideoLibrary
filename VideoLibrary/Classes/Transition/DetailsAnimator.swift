//
//  DetailsAnimator.swift
//  video app
//
//  Created by Alexander Bozhko on 23/08/2018.
//  Copyright © 2018 Filmgrail AS. All rights reserved.
//

import UIKit

public protocol DetailsAnimatorDelegate {
    
    func prepare(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool)
    func animate(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool)
    func finish(using transitionContext: UIViewControllerContextTransitioning, isPresentation: Bool)
    
}

class DetailsAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let senderView: VideoView
    private var isPresent: Bool
    private let transitionDuration: TimeInterval = 0.25
    
    private weak var superview: UIView? = nil
    private var finalFrame: CGRect? = nil
    private var cornerRadius: CGFloat = 0
    
    var delegate: DetailsAnimatorDelegate? = nil
    
    init(_ senderView: VideoView, isPresent: Bool = true, superview: UIView? = nil, finalFrame: CGRect? = nil, cornerRadius: CGFloat = 0) {
        self.senderView = senderView
        self.isPresent = isPresent
        super.init()
        
        self.superview = superview
        self.finalFrame = finalFrame
        self.cornerRadius = cornerRadius
    }
    
    // MARK: - Animated transitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        prepare(using: transitionContext)
        let delegate = self.delegate
        let isPresent = self.isPresent
        let senderView = self.senderView
        let superview = self.superview
        
        UIView.animate(withDuration: transitionDuration, animations: {
            [weak self] in
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

        senderView.frame = senderView.superview!.convert(senderView.frame, to: fromView)
        toView.frame = transitionContext.finalFrame(for: toVC)
        
        if isPresent {
            containerView.addSubview(toView)
            toView.frame.origin.y = senderView.frame.minY
            toView.alpha = 0
            
            // add blur to fromview
            fromView.addBlurView()
        }
        
        containerView.addSubview(senderView)
        
        delegate?.prepare(using: transitionContext, isPresentation: isPresent)
    }
    
    private func animate(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.viewController(forKey: .from)!.view!
        let toVC = transitionContext.viewController(forKey: .to)!
        let toView = toVC.view!
        
        senderView.layer.cornerRadius = cornerRadius

        if isPresent {
            toView.layer.cornerRadius = cornerRadius
            toView.clipsToBounds = true
            let finalFrame = transitionContext.finalFrame(for: toVC)
            let k = finalFrame.width / senderView.frame.width
            senderView.transform = CGAffineTransform(scaleX: k, y: k)
            if #available(iOS 11.0, *) {
                senderView.frame.origin = CGPoint(x: toView.safeAreaInsets.left, y: toView.safeAreaInsets.top)
            } else {
                senderView.frame.origin = .zero
            }
            toView.frame = finalFrame
            toView.alpha = 1
            fromView.enableBlur()
        } else {
            fromView.layer.cornerRadius = cornerRadius
            fromView.clipsToBounds = true
            if let finalFrame = finalFrame {
                let k = finalFrame.width / senderView.frame.width
                senderView.transform = CGAffineTransform(scaleX: k, y: k)
                senderView.frame.origin = finalFrame.origin
                fromView.transform = CGAffineTransform(scaleX: k, y: k)
            }
            fromView.frame.origin.y = senderView.frame.minY
            fromView.frame.origin.x = senderView.frame.minX
            fromView.alpha = 0
            toView.disableBlur()
        }
        
        delegate?.animate(using: transitionContext, isPresentation: isPresent)
    }
    
    class func finish(using transitionContext: UIViewControllerContextTransitioning, senderView: UIView, superview: UIView?, isPresent: Bool, delegate: DetailsAnimatorDelegate?) {
        let toView = transitionContext.viewController(forKey: .to)!.view!
        
        // remove blur
        if !isPresent {
            toView.removeBlurView()
        }

        let frame = senderView.frame
        senderView.transform = CGAffineTransform.identity
        senderView.frame = frame
        
        if let superview = superview {
            superview.addSubview(senderView)
            senderView.frame = superview.convert(frame, from: nil)
        }
        delegate?.finish(using: transitionContext, isPresentation: isPresent)
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
}

// MARK: - Blur methods

fileprivate extension UIView {
    
    var blurView: UIVisualEffectView? {
        return subviews.compactMap({ $0 as? UIVisualEffectView }).filter({ $0.accessibilityIdentifier == "blur" }).first
    }
    
    func addBlurView() {
        guard !UIAccessibilityIsReduceTransparencyEnabled() && blurView == nil else { return }
        let effectView = UIVisualEffectView()
        effectView.accessibilityIdentifier = "blur"
        effectView.frame = bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(effectView)
    }
    
    func removeBlurView() {
        blurView?.removeFromSuperview()
    }
    
    func enableBlur() {
        blurView?.effect = UIBlurEffect(style: .light)
    }
    
    func disableBlur() {
        blurView?.effect = nil
    }
    
}
