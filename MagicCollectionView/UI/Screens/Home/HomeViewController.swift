//
//  HomeViewController.swift
//  MagicCollectionView
//
//  Created by Adrian on 20.02.21.
//
/* an overview of all vegetables. */

import UIKit

class HomeViewController: UIViewController {
    let sections = Section.examplesMultiplied
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, Vegetable>?

    override func viewDidLoad() {
        super.viewDidLoad()
        createAndConfigureCollectionView()
    }
}

// MARK: - CollectionView and Cell Creation
extension HomeViewController {
    func createAndConfigureCollectionView() {
        let layout = createAnimatedLayout()
        collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: layout
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)

        collectionView.register(
            VegetableCell.self,
            forCellWithReuseIdentifier: VegetableCell.reuseIdentifier
        )

        createDataSource()
        reloadData()
    }

    func configure<T: SelfConfiguringCell>(
        _ cellType: T.Type,
        with vegetable: Vegetable,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: cellType.reuseIdentifier,
            for: indexPath
        ) as? T else {
            fatalError("Unable to dequeue \(cellType). Should never fail.")
        }

        cell.configure(with: vegetable)
        return cell
    }
}

// MARK: - CollectionView Data Source
extension HomeViewController {
    func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Vegetable>(
            collectionView: collectionView,
            cellProvider: { collectionView, indexPath, vegetable in
                return self.configure(VegetableCell.self, with: vegetable, for: indexPath)
            }
        )
    }

    func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Vegetable>()
        snapshot.appendSections(sections)

        for section in sections {
            snapshot.appendItems(section.items, toSection: section)
        }

        dataSource?.apply(snapshot)
    }
}


// MARK: - CollectionView Layout Delegate
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func createAnimatedLayout() -> MagicCollectionViewFlowLayout {
        let layout = MagicCollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        return layout
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWeightInGrams = getWeightOfItem(at: indexPath)
        let desiredItemSize = itemWeightInGrams * 1.2
        return CGSize(width: desiredItemSize, height: desiredItemSize)
    }

    func getWeightOfItem(at indexPath: IndexPath) -> Double {
        let sectionIndex = indexPath.section
        let section = sections[sectionIndex]
        let itemIndex = indexPath.item
        let item = section.items[itemIndex]
        return item.weight
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - CollectionView Delegate
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("tapped item at indexPath: \(indexPath)")
        let selectedCell = collectionView.cellForItem(at: indexPath) as? VegetableCell
        guard let selectedVegetable = selectedCell?.vegetable else { return }
        let detailViewController = DetailViewController(vegetable: selectedVegetable)
        detailViewController.modalPresentationStyle = .overCurrentContext
        present(detailViewController, animated: true, completion: nil)
    }
}
