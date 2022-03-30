//
//  UIHelper.swift
//  TestTaskMobileUP
//
//  Created by Илья Андреев on 26.03.2022.
//

import UIKit

// MARK: - Enum UIHelper
/// Helps create some specific interfaces
enum UIHelper {
    
    /// Creates two columns layout for collection view
    /// - Parameter view: superview
    /// - Returns: created layout
    static func createTwoColumnFlowLayout(in view: UIView) -> UICollectionViewFlowLayout {
        let width = view.bounds.width
        let minimumItemSpacing: CGFloat = 1
        let availableWidth = width - minimumItemSpacing
        let itemWidth = availableWidth / 2

        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: itemWidth, height: itemWidth)
        flowLayout.minimumInteritemSpacing = minimumItemSpacing
        flowLayout.minimumLineSpacing = minimumItemSpacing

        return flowLayout
    }
    
    /// Creates one row horizantal layout for collection view
    /// - Returns: created layout
    static func createHorizontalFlowLayout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalHeight(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalHeight(1),
            heightDimension: .fractionalHeight(1)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize, subitem: item, count: 1
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 2
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal
        
        let layout = UICollectionViewCompositionalLayout(
            section: section, configuration: config)
        return layout
    }
}
