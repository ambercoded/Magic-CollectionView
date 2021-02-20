//
//  MagicCollectionViewFlowLayout.swift
//  MagicCollectionView
//
//  Created by Adrian on 18.02.21.
//
/// a physics-enabled UICollectionViewLayout that strives to provide a "magic" feel while scrolling.
/// using the UIKit Dynamics Engine to create a wave-like physics reaction while scrolling.

import UIKit

class MagicCollectionViewFlowLayout: UICollectionViewFlowLayout {
    lazy var dynamicAnimator: UIDynamicAnimator = {
        return UIDynamicAnimator(collectionViewLayout: self)
    }()

    var visibleIndexPathsSet = Set<IndexPath>()
    var latestScrollingDelta: CGFloat = 0

    /// tweak the physics parameters to your liking here
    // configure how intense the scrolling movement should be translated into movement
    let enableLimitForShiftOnYAxis = false
    let yAxisShiftLimit: CGFloat = 5
    var yAxisShiftLimitNegative: CGFloat { yAxisShiftLimit * -1 }
    let scrollReactionResistance: CGFloat = 1500.0

    // configure the spring that is attached between each item and its anchorpoint (center)
    let attachmentLength: CGFloat = 0.0
    let frictionTorque: CGFloat? = nil
    let springDamping: CGFloat = 0.8
    let oscillationFrequency: CGFloat = 1.0

    override func prepare() {
        super.prepare()
        let visibleRect = CGRect(
            origin: self.collectionView?.bounds.origin ?? CGPoint.zero,
            size: self.collectionView?.frame.size ?? CGSize.zero
        ).insetBy(dx: -100, dy: -100) // make it larger than the collectionView by 100

        // determine which items are visible
        let itemsInVisibleRectArray = super.layoutAttributesForElements(in: visibleRect) ?? []
        let itemsIndexPathsInVisibleRectSet = Set(itemsInVisibleRectArray.map{ $0.indexPath })

        /// find and remove all behaviors that are no longer visible
        // get all noLongerVisibleBehaviors
        let noLongerVisibleBehaviors = self.dynamicAnimator.behaviors.filter { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior else { return false }
            guard let attribute = behavior.items.first as? UICollectionViewLayoutAttributes else { return false }
            let currentlyVisible = itemsIndexPathsInVisibleRectSet.contains(attribute.indexPath)
            return !currentlyVisible
        }

        // remove all noLongerVisibleBehaviors
        noLongerVisibleBehaviors.forEach { behavior in
                self.dynamicAnimator.removeBehavior(behavior)
                guard let behavior = behavior as? UIAttachmentBehavior else { return }
                guard let attribute = behavior.items.first as? UICollectionViewLayoutAttributes else { return }
                self.visibleIndexPathsSet.remove(attribute.indexPath)
        }

        // find all items that just became visible
        let newlyVisibleItems = itemsInVisibleRectArray.filter { item in
            let currentlyVisible = self.visibleIndexPathsSet.contains(item.indexPath)
            return !currentlyVisible
        }

        let touchLocation = self.collectionView?.panGestureRecognizer.location(in: self.collectionView)

        // add dynamic behavior to each newly visible item
        for item in newlyVisibleItems {
            // IMPORTANT! The center coordinate needs to be rounded before it is handed to the animator.
            // else the animator does the rounding and the slight difference
            // between the unrounded center and the rounded center is animated.
            // that can lead to circular oscillations around the anchor point.
            // (eg if the animator rounds the center.x by 0.0000001, an unwanted movement
            // on the x-axis is triggered and circular oscillation occurs.

            // round the frames of the item center if necessary
            var centerRounded = CGPoint(x: CGFloat.rounded(item.center.x)(), y: CGFloat.rounded(item.center.y)())
            if item.center != centerRounded { item.center = centerRounded }

            // configure spring behavior
            let springBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: centerRounded)
            springBehavior.length = attachmentLength
            springBehavior.damping = springDamping
            springBehavior.frequency = oscillationFrequency
            if let frictionTorque = frictionTorque {
                springBehavior.frictionTorque = frictionTorque
            }

            // calculate new center y coordinate for the item after dragging
            // intensity of animation depends on the items distance to the tap location
            if let touchLocation = touchLocation, CGPoint.zero != touchLocation {
                let yDistanceFromTouch = abs(touchLocation.y - springBehavior.anchorPoint.y)
                let xDistanceFromTouch = abs(touchLocation.x - springBehavior.anchorPoint.x)
                let scrollResistance = (yDistanceFromTouch + xDistanceFromTouch) / scrollReactionResistance

                if self.latestScrollingDelta < 0.0 {
                    var amountOfYShift = max(self.latestScrollingDelta, self.latestScrollingDelta * scrollResistance)
                    let animationLimiterShouldKickIn = enableLimitForShiftOnYAxis && amountOfYShift < yAxisShiftLimitNegative
                    if animationLimiterShouldKickIn { amountOfYShift = yAxisShiftLimitNegative }
                    centerRounded.y += amountOfYShift
                } else {
                    var amountOfYShift = min(self.latestScrollingDelta, self.latestScrollingDelta * scrollResistance)
                    if enableLimitForShiftOnYAxis && amountOfYShift > yAxisShiftLimit {
                        amountOfYShift = yAxisShiftLimit
                    }
                    centerRounded.y += amountOfYShift
                }
                item.center = centerRounded
            }

            self.dynamicAnimator.addBehavior(springBehavior)
            self.visibleIndexPathsSet.insert(item.indexPath)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.dynamicAnimator.layoutAttributesForCell(at: indexPath)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        let scrollView = self.collectionView
        let scrollingDelta = newBounds.origin.y - (scrollView?.bounds.origin.y ?? 0)
        self.latestScrollingDelta = scrollingDelta
        let touchLocation = self.collectionView?.panGestureRecognizer.location(in: self.collectionView)

        for springBehavior in self.dynamicAnimator.behaviors
        {
            guard let springBehavior = springBehavior as? UIAttachmentBehavior, let touchLocation = touchLocation else { continue }
            let yDistanceFromTouch = abs(touchLocation.y - springBehavior.anchorPoint.y)
            let xDistanceFromTouch = abs(touchLocation.x - springBehavior.anchorPoint.x)
            let scrollResistance: CGFloat = (yDistanceFromTouch + xDistanceFromTouch) / scrollReactionResistance

            guard let item = springBehavior.items.first as? UICollectionViewLayoutAttributes else { continue }
            var centerRounded = CGPoint(x: CGFloat.rounded(item.center.x)(), y: CGFloat.rounded(item.center.y)())

            if self.latestScrollingDelta < 0.0 {
                var amountOfYShift = max(self.latestScrollingDelta, self.latestScrollingDelta * scrollResistance)
                if enableLimitForShiftOnYAxis {
                    if amountOfYShift < yAxisShiftLimitNegative { amountOfYShift = yAxisShiftLimitNegative }
                }
                centerRounded.y += amountOfYShift
            } else {
                var amountOfYShift = min(self.latestScrollingDelta, self.latestScrollingDelta * scrollResistance)
                if enableLimitForShiftOnYAxis {
                    if amountOfYShift > yAxisShiftLimit { amountOfYShift = yAxisShiftLimit }
                }
                centerRounded.y += amountOfYShift
            }

            item.center = centerRounded
            self.dynamicAnimator.updateItem(usingCurrentState: item)
        }

        return false
    }
}
