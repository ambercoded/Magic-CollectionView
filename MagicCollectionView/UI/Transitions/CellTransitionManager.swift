//
//  CellTransitionManager.swift
//  MagicCollectionView
//
//  Created by Adrian on 20.02.21.
//

import UIKit

enum CellTransitionType {
    case presentation
    case dismissal
}

class CellTransitionManager: NSObject {
    let transitionDuration: Double = 0.8
    var transition: CellTransitionType = .presentation
    let shrinkDuration: Double = 0.2
}

extension CellTransitionManager: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

    }
}

extension CellTransitionManager: UIViewControllerTransitioningDelegate {
    // called whenever a vc is presented
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = .presentation
        return self
    }

    // called whenever a vc is dismissed
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition = .dismissal
        return self
      }
}
