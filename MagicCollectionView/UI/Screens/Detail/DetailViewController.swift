//
//  DetailViewController.swift
//  MagicCollectionView
//
//  Created by Adrian on 20.02.21.
//
/* a view with more information about an item */

import UIKit

class DetailViewController: UIViewController {
    enum viewMode {
        case full
        case reduced
    }

    private let vegetable: Vegetable

    // MARK: Views
    var titleLabel: UILabel!
    var weightLabel: UILabel!
    var imageView: UIImageView!
    var dismissButton: UIButton!

    init(vegetable: Vegetable) {
        self.vegetable = vegetable
        super.init(nibName: nil, bundle: nil) // check
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented. no use of storyboard.")
    }
}

extension DetailViewController {
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)

        dismissButton = UIButton()
        dismissButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
        dismissButton.setTitle("Back", for: .normal)
        dismissButton.setTitleColor(.label, for: .normal)
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        view.addSubview(dismissButton)

        titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        titleLabel.textAlignment = .center
        titleLabel.text = vegetable.name

        imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: vegetable.image)
        imageView.contentMode = .scaleAspectFit

        weightLabel = UILabel()
        weightLabel.translatesAutoresizingMaskIntoConstraints = false
        weightLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        weightLabel.textAlignment = .center
        weightLabel.text = String(format: "Weight: %.0fg", vegetable.weight)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, imageView, weightLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        view.addSubview(stackView)

        let safeArea = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            dismissButton.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            dismissButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),

            titleLabel.topAnchor.constraint(equalTo: dismissButton.bottomAnchor),

            imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: stackView.widthAnchor, multiplier: 0.8),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: stackView.heightAnchor, multiplier: 0.5),

            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: dismissButton.bottomAnchor),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor)
        ])
    }

    @objc func backTapped(_ sender: UIButton) {
        print("back tapped")
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

