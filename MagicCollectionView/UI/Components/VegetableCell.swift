//
//  VegetableCell.swift
//  CollectionView-Transition
//
//  Created by Adrian B. Haeske on 16.02.21.
//
/* a cell that will be used when creating the collectionView. */

import UIKit

class VegetableCell: UICollectionViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = "VegetableCell"

    var vegetable: Vegetable!
    let imageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFit

        let stackView = UIStackView(arrangedSubviews: [imageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false // constraints will be created manually
        stackView.axis = .vertical
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("I won't support creating a cell from storyboard. Thus, no implementation.")
    }

    func configure(with vegetable: Vegetable) {
        self.vegetable = vegetable
        imageView.image = UIImage(named: vegetable.image)
    }
}
