//
//  StretchyHeaderLayout.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/10/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit



/**
 Abstract: Custom collection view flow layout used to implement the stretchy header for the collection view. NOTE: This class should only be used if the cells in a collection view are fixed.
 */
class StretchyHeaderLayout: UICollectionViewFlowLayout {

    // MARK: - Class Vars
    
    /// Initialized Boolean used to determine if we're updating the UICollectionViewLayoutAttributes for the section header
    var isUpdatingAttributeForHeader: Bool = false

    // - Tag
    override func prepare() {
        super.prepare()
        // Configure the layout
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
        scrollDirection = .vertical
        sectionInset = UIEdgeInsets.zero
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }

    // - Tag
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        // Iterate through each attribute
        layoutAttributes?.forEach({ (attributes: UICollectionViewLayoutAttributes) in
            // Implement the stretchy header for the first collection view header resuable view
            if let collectionView = collectionView, attributes.representedElementKind == UICollectionView.elementKindSectionHeader, attributes.indexPath.section == 0, collectionView.contentOffset.y < 0.0 {
                // Update the frame of the attribute
                let width = collectionView.frame.width
                let height = attributes.frame.height - collectionView.contentOffset.y
                attributes.frame = CGRect(x: 0.0, y: collectionView.contentOffset.y, width: width, height: height)
                
                // Update the Boolean
                self.isUpdatingAttributeForHeader = true
            } else {
                // Update the Boolean
                self.isUpdatingAttributeForHeader = false
            }
        })
        return layoutAttributes
    }

    // - Tag
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Return the layout attributes for the header based on whether it should be invalidated
        return isUpdatingAttributeForHeader
    }
}
