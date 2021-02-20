# Magic CollectionView
A physics-enabled UICollectionViewLayout that strives to create a "magic" feeling when scrolling.
The UIKit Dynamics Engine is used to create the wave-like physics reaction.

Download the sample project to see it in action while scrolling through a list of yummy vegetables.

## Demo
![](https://github.com/ambercoded/readme-gifs/blob/main/magic-CollectionView.gif)

## Easy tweaking of the physics behavior
### Tweak the translation of scroll distance into item movement
- by setting a scrollResistance
- by setting a maximum shift along the y-axis or leaving it unlimited (set to nil)

### Tweak the spring that attaches the item to its anchor point 
- by changing the length of attachment (distance between item and its anchor point) (0.0 to infinity)
- by changing the damping of the spring (0.0 to 1.0)
- by changing the oscillation frequency (0.0 to infinity)
- by changing the friction torque (0.0 to infinity)

## Usage
Simply add it to your project in two steps: 
1. Add the MagicCollectionViewFlowLayout file. 
2. Set your collectionView's layout to an instance of MagicCollectionViewFlowLayout.

## Features to be added soon
- A natural zoom-in transition to a detail view. Goal: Give the user the impression that he/she is moving in an ever-expanding room. And completely eradicate any hard transitions.


