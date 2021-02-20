//
//  Vegetable.swift
//  MagicCollectionView
//
//  Created by Adrian B. Haeske on 16.02.21.
//
/* a model that represents an entity of the data to be displayed. */

import Foundation

struct Vegetable: Hashable {
    let id: UUID
    let name: String
    let weight: Double = Double.random(in: 42..<111)
    var image: String {
        name
    }
}

// MARK: - Sample Data
extension Vegetable {
    static let examplesGreenMultiplied: [Vegetable] = {
        var array = [Vegetable]()
        let greenVegetableNames = ["Cucumber", "Pea", "Broccoli", "Brussel Sprouts"]

        for i in 0..<8 {
            for j in 0..<4 {
                let vegetable = Vegetable(id: UUID(), name: greenVegetableNames[j])
                array.append(vegetable)
            }
        }
        return array
    }()

    static let examplesRedMultiplied: [Vegetable] = {
        var array = [Vegetable]()
        let vegetableNames = ["Red Pepper", "Chili", "Beetroot", "Tomato"]

        for i in 0..<7 {
            for j in 0..<4 {
                let vegetable = Vegetable(id: UUID(), name: vegetableNames[j])
                array.append(vegetable)
            }
        }
        return array
    }()

    static let examplesYellowMultiplied: [Vegetable] = {
        var array = [Vegetable]()
        let vegetableNames = ["Corn", "Potato", "Yellow Zucchini"]

        for i in 0..<6 {
            for j in 0..<3 {
                let vegetable = Vegetable(id: UUID(), name: vegetableNames[j])
                array.append(vegetable)
            }
        }
        return array
    }()
}
