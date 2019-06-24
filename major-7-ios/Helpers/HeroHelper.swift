//
//  HeroHelper.swift
//  major-7-ios
//
//  Created by jason on 24/6/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import Hero

class HeroHelper: NSObject {
    let navigationController: UINavigationController
    
    required init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.hero.isEnabled = true
        self.navigationController.hero.navigationAnimationType = .fade
        self.navigationController.delegate = self
    }
}

// Navigation Popping
extension HeroHelper {
    private func addEdgePanGesture(to view: UIView) {
        let pan = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(self.popViewController(_:))
        )
        pan.edges = .left
        view.addGestureRecognizer(pan)
    }
    
    @objc private func popViewController(_ gesture: UIScreenEdgePanGestureRecognizer) {
        guard let view = gesture.view else { return }
        let translation = gesture.translation(in: nil)
        let progress = translation.x / 2 / view.bounds.width
        
        switch gesture.state {
        case .began:
            self.navigationController.topViewController?.hero.dismissViewController()
        case .changed:
            Hero.shared.update(progress)
        default:
            if progress + gesture.velocity(in: nil).x / view.bounds.width > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
    }
}

// Navigation Controller Delegate
extension HeroHelper: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        interactionControllerFor animationController: UIViewControllerAnimatedTransitioning
        ) -> UIViewControllerInteractiveTransitioning? {
        return Hero.shared.navigationController(navigationController, interactionControllerFor: animationController)
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if navigationController.viewControllers.count > 1 {
            self.addEdgePanGesture(to: viewController.view)
        }
    }
    
    func navigationController(
        _ navigationController: UINavigationController,
        animationControllerFor operation: UINavigationController.Operation,
        from fromVC: UIViewController,
        to toVC: UIViewController
        ) -> UIViewControllerAnimatedTransitioning? {
        return Hero.shared.navigationController(navigationController, animationControllerFor: operation, from: fromVC, to: toVC)
    }
}
