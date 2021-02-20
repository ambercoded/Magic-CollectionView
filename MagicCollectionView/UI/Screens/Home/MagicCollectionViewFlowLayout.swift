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

    var currentlyVisibleItemsIndexPaths = Set<IndexPath>()
    var latestScrollingDelta: CGFloat = 0

    // MARK: - Physics Parameter Tweaking
    /// a spring that is attached between each item and its anchorpoint (center)
    let attachmentLength: CGFloat = 0.0
    let frictionTorque: CGFloat? = nil
    let springDamping: CGFloat = 0.8
    let oscillationFrequency: CGFloat = 1.0

    /// configure how intense the scrolling movement should be translated into movement here
    let scrollReactionResistance: CGFloat = 1500.0
    let enableLimitForShiftOnYAxis = false
    let yAxisShiftLimit: CGFloat = 5
    var yAxisShiftLimitNegative: CGFloat { yAxisShiftLimit * -1 }
}

// MARK: - Layout Lifecycle Methods
extension MagicCollectionViewFlowLayout {
    override func prepare() {
        super.prepare()
        removeAllNoLongerVisibleBehaviors()
        let newlyVisibleItems = getItemsThatJustBecameVisible()
        addSpringBehavior(to: newlyVisibleItems)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.dynamicAnimator.items(in: rect) as? [UICollectionViewLayoutAttributes]
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return self.dynamicAnimator.layoutAttributesForCell(at: indexPath)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        self.latestScrollingDelta = calculateScrollDistance(forBoundsChange: newBounds)
        animateCenterChangeOfAllBehaviors()
        return false // invalidating the layout is the dynamic animators responsibility.
    }

    func calculateScrollDistance(forBoundsChange newBounds: CGRect) -> CGFloat {
        let scrollingDelta = newBounds.origin.y - (collectionView?.bounds.origin.y ?? 0)
        return scrollingDelta
    }
}

// MARK: - Tiling DynamicBehavior for Performance
extension MagicCollectionViewFlowLayout {
    func removeAllNoLongerVisibleBehaviors() {
        let noLongerVisibleBehaviors = getAllNoLongerVisibleBehaviors()
        removeBehaviors(noLongerVisibleBehaviors)
    }

    func getAllNoLongerVisibleBehaviors() -> [UIDynamicBehavior] {
        let visibleItems = getVisibleItems()
        let visibleItemsIndexPaths = getIndexPaths(of: visibleItems)
        let noLongerVisibleBehaviors = self.dynamicAnimator.behaviors.filter { behavior in
            guard let behavior = behavior as? UIAttachmentBehavior else { return false }
            guard let attribute = behavior.items.first as? UICollectionViewLayoutAttributes else { return false }
            let currentlyVisible = visibleItemsIndexPaths.contains(attribute.indexPath)
            return !currentlyVisible
        }
        return noLongerVisibleBehaviors
    }

    func getVisibleItems() -> [UICollectionViewLayoutAttributes] {
        // include items within 100points of the actual size as a buffer
        let visibleRect = getVisibleRect().insetBy(dx: -100, dy: -100)
        let itemsInVisibleRectArray = super.layoutAttributesForElements(in: visibleRect) ?? []
        return itemsInVisibleRectArray
    }

    func getVisibleRect() -> CGRect {
        return CGRect(
            origin: self.collectionView?.bounds.origin ?? CGPoint.zero,
            size: self.collectionView?.frame.size ?? CGSize.zero
        )
    }

    func getIndexPaths(of visibleItems: [UICollectionViewLayoutAttributes]) -> Set<IndexPath> {
        let itemsIndexPathsInVisibleRectSet = Set(visibleItems.map{ $0.indexPath })
        return itemsIndexPathsInVisibleRectSet
    }

    func removeBehaviors(_ behaviors: [UIDynamicBehavior]) {
        behaviors.forEach { behavior in
            self.dynamicAnimator.removeBehavior(behavior)
            guard let behavior = behavior as? UIAttachmentBehavior else { return }
            guard let attribute = behavior.items.first as? UICollectionViewLayoutAttributes else { return }
            self.currentlyVisibleItemsIndexPaths.remove(attribute.indexPath)
        }
    }

    func getItemsThatJustBecameVisible() -> [UICollectionViewLayoutAttributes] {
        let visibleItems = getVisibleItems()
        let newlyVisibleItems = visibleItems.filter { item in
            let currentlyVisible = self.currentlyVisibleItemsIndexPaths.contains(item.indexPath)
            return !currentlyVisible
        }
        return newlyVisibleItems
    }

    func addSpringBehavior(to items: [UICollectionViewLayoutAttributes]) {
        for item in items {
            // IMPORTANT. An item's center coordinate has to be rounded before it's handed to the animator.
            // Else the animator does the rounding and animates the rounding difference.
            // Unwanted effect: circular oscillations around the anchor point due to a slight x-axis shift.
            // (eg if the animator rounds the center.x by 0.0000001, that movement is animated)
            let centerRounded = CGPoint(
                x: CGFloat.rounded(item.center.x)(),
                y: CGFloat.rounded(item.center.y)()
            )

            // set the item center to a rounded center if it's not rounded yet
            if item.center != centerRounded { item.center = centerRounded }

            // configure spring behavior
            let springBehavior = UIAttachmentBehavior(item: item, attachedToAnchor: centerRounded)
            springBehavior.length = attachmentLength
            springBehavior.damping = springDamping
            springBehavior.frequency = oscillationFrequency
            if let frictionTorque = frictionTorque {
                springBehavior.frictionTorque = frictionTorque
            }

            self.dynamicAnimator.addBehavior(springBehavior)
            self.currentlyVisibleItemsIndexPaths.insert(item.indexPath)
        }
    }
}

// MARK: - Animation Calculation
extension MagicCollectionViewFlowLayout {
    func animateCenterChangeOfAllBehaviors() {
        self.dynamicAnimator.behaviors.forEach(animateCenterChange)
    }

    func animateCenterChange(for behavior: UIDynamicBehavior) {
        guard let touchLocation = getTouchLocation() else { return }
        guard let springBehavior = behavior as? UIAttachmentBehavior else { return }
        guard let item = springBehavior.items.first as? UICollectionViewLayoutAttributes else { return }

        let scrollResistance = calculateScrollResistance(
            touchLocation: touchLocation,
            behaviorAnchorPoint: springBehavior.anchorPoint
        )

        let amountOfYShift = calculateAmountOfYShiftAfterScrolling(for: item.center, with: scrollResistance)
        item.center.y += amountOfYShift
        self.dynamicAnimator.updateItem(usingCurrentState: item)
    }

    func getTouchLocation() -> CGPoint? {
        self.collectionView?.panGestureRecognizer.location(in: self.collectionView)
    }

    func calculateScrollResistance(touchLocation: CGPoint, behaviorAnchorPoint: CGPoint) -> CGFloat {
        let yDistanceFromTouch = abs(touchLocation.y - behaviorAnchorPoint.y)
        let xDistanceFromTouch = abs(touchLocation.x - behaviorAnchorPoint.x)
        let scrollResistance: CGFloat = (yDistanceFromTouch + xDistanceFromTouch) / scrollReactionResistance
        return scrollResistance
    }

    func calculateAmountOfYShiftAfterScrolling(for center: CGPoint, with scrollResistance: CGFloat) -> CGFloat {
        // intensity of an item's center change depends on its distance to the tap location.
        // items that are farther away (x and y) are animated more strongly to create a wave effect.
        let scrollingUp = self.latestScrollingDelta < 0.0
        if scrollingUp {
            let amountOfYShift = max(self.latestScrollingDelta, self.latestScrollingDelta * scrollResistance)
            if enableLimitForShiftOnYAxis && amountOfYShift < yAxisShiftLimitNegative {
                return yAxisShiftLimitNegative
            } else {
                return amountOfYShift
            }
        } else {
            let amountOfYShift = min(self.latestScrollingDelta, self.latestScrollingDelta * scrollResistance)
            if enableLimitForShiftOnYAxis && amountOfYShift > yAxisShiftLimit {
                return yAxisShiftLimit
            } else {
                return amountOfYShift
            }
        }
    }
}
