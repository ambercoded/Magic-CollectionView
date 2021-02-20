//
//  Section.swift
//  MagicCollectionView
//
//  Created by Adrian B. Haeske on 16.02.21.
//
/* sections are needed for structuring the collectionviews datasource. */

import Foundation

struct Section: Hashable {
    let id: Int
    let title: String
    let items: [Vegetable]
}

// MARK: - Sample Data
extension Section {
    static let examplesMultiplied: [Section] =
    [
        Section(id: 1, title: "Green", items: Vegetable.examplesGreenMultiplied),
        Section(id: 2, title: "Red", items: Vegetable.examplesRedMultiplied),
        Section(id: 3, title: "Yellow", items: Vegetable.examplesYellowMultiplied)
    ]
}
