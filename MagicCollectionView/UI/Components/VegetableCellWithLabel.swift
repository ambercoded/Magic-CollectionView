//
//  VegetableCellWithLabel.swift
//  MagicCollectionView
//
//  Created by Adrian on 20.02.21.
/* a cell that will be used when creating the collectionView. */

import UIKit

class VegetableCellWithLabel: UICollectionViewCell, SelfConfiguringCell {
    static var reuseIdentifier: String = "VegetableCell"

    let imageView = UIImageView()
    let weightLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        imageView.contentMode = .scaleAspectFit

        weightLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        weightLabel.textAlignment = .center
        weightLabel.textColor = .secondaryLabel

        let stackView = UIStackView(arrangedSubviews: [imageView, weightLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        stackView.setCustomSpacing(4, after: imageView)
    }

    required init?(coder: NSCoder) {
        fatalError("I won't support creating a cell from storyboard. Thus, no implementation.")
    }

    func configure(with vegetable: Vegetable) {
        weightLabel.text = String(format: "%.0fg", vegetable.weight)
        imageView.image = UIImage(named: vegetable.image)
    }
}
