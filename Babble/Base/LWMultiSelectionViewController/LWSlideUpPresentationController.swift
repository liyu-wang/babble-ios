//
//  LWSlideUpPresentationController.swift
//  Babble
//
//  Created by Liyu Wang on 10/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import UIKit

class LWSlideUpPresentationController: UIPresentationController {
    var dimmingView: UIView!
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        presentedViewController.modalPresentationStyle = .custom
    }
    
    
    override func presentationTransitionWillBegin() {
        let dimmingView = UIView(frame: self.containerView!.bounds)
        dimmingView.backgroundColor = UIColor.black
        dimmingView.isOpaque = false
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LWSlideUpPresentationController.dimmingViewTapped(_:))))
        self.dimmingView = dimmingView
        self.containerView?.addSubview(dimmingView)
        
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        
        self.dimmingView.alpha = 0.0
        transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0.5
        }, completion: nil)
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        if !completed {
            self.dimmingView = nil
        }
    }
    
    override func dismissalTransitionWillBegin() {
        let transitionCoordinator = self.presentingViewController.transitionCoordinator
        
        transitionCoordinator?.animate(alongsideTransition: { (context) in
            self.dimmingView.alpha = 0.0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        if completed {
            self.dimmingView = nil
        }
    }
    
    // MARK: - Layout
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        if container === self.presentedViewController {
            self.containerView?.setNeedsLayout()
        }
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if container === self.presentedViewController {
            return (container as! UIViewController).preferredContentSize
        } else {
            return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
        }
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let containerViewBounds = self.containerView!.bounds
        let presentedViewContentSize = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerViewBounds.size)
        
        var presentedViewControllerFrazme = containerViewBounds
        presentedViewControllerFrazme.size.height = presentedViewContentSize.height
        presentedViewControllerFrazme.origin.y = containerViewBounds.maxY - presentedViewContentSize.height
        
        return presentedViewControllerFrazme
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        
        self.dimmingView.frame = self.containerView!.bounds
    }
    
    // MARK: - Tap Gesture Recogniser
    
    @objc func dimmingViewTapped(_ sender: UIGestureRecognizer) {
//        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

extension LWSlideUpPresentationController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionContext?.isAnimated == true ? 0.35 : 0.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: .from)!
        let toViewController = transitionContext.viewController(forKey: .to)!
        
        let isPresenting = fromViewController === self.presentingViewController
        
        let containerView = transitionContext.containerView
        
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        
        let fromViewInitialFrame = transitionContext.initialFrame(for: fromViewController)
        var fromViewFinalFrame = transitionContext.finalFrame(for: fromViewController)
        
        var toViewInitialFrame = transitionContext.initialFrame(for: toViewController)
        let toViewFinalFrame = transitionContext.finalFrame(for: toViewController)
        
        if let toV = toView {
            containerView.addSubview(toV)
        }
        
        if (isPresenting) {
            toViewInitialFrame.origin = CGPoint(x: containerView.bounds.minX, y: containerView.bounds.maxY)
            toViewInitialFrame.size = toViewFinalFrame.size
            toView!.frame = toViewInitialFrame
        } else {
            fromViewFinalFrame = fromView!.frame.offsetBy(dx: 0, dy: fromView!.frame.height)
        }
        
        let transitionDuration = self.transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: transitionDuration, animations: {
            if isPresenting {
                toView!.frame = toViewFinalFrame
            } else {
                fromView!.frame = fromViewFinalFrame
            }
        }) { (finished) in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
}

extension LWSlideUpPresentationController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return self
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
}
