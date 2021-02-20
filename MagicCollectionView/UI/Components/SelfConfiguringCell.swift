//
//  SelfConfiguringCell.swift
//  MagicCollectionView
//
//  Created by Adrian B. Haeske on 16.02.21.
//
/* a protocol with two requirements.
 all collectionView cells will conform to this protocol. this means:
 1. they have to be reusable and
 2. they know how to configure themselves with the model (vegetable) */

import Foundation

protocol SelfConfiguringCell {
    static var reuseIdentifier: String { get }
    func configure(with vegetable: Vegetable)
}
