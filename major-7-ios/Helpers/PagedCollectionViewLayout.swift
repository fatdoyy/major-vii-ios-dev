//
//  PagedCollectionViewLayout.swift
//  major-7-ios
//
//  Created by jason on 8/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class PagedCollectionViewLayout: UICollectionViewFlowLayout {
    
    var previousOffset: CGFloat = 0
    var currentPage: CGFloat = 0
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        let sup = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        
        guard
            let validCollection = collectionView,
            let dataSource = validCollection.dataSource
            else { return sup }
        
        let itemsCount = dataSource.collectionView(validCollection, numberOfItemsInSection: 0)
        
        // Imitating paging behaviour
        // Check previous offset and scroll direction
        if  (previousOffset > validCollection.contentOffset.x) && (velocity.x < 0) {
            currentPage = max(currentPage - 1, 0)
        }
        else if (previousOffset < validCollection.contentOffset.x) && (velocity.x > 0) {
            currentPage = min(currentPage + 1, CGFloat(itemsCount - 1))
        }
        
        // Update offset by using item size + spacing
        let itemEdgeOffset: CGFloat = (validCollection.frame.width - itemSize.width -  minimumLineSpacing * 2) / 2
        let updatedOffset = ((itemSize.width + minimumLineSpacing) * currentPage) - (itemEdgeOffset + minimumLineSpacing)
        self.previousOffset = updatedOffset
        
        let updatedPoint = CGPoint(x: updatedOffset, y: proposedContentOffset.y)
        
        return updatedPoint
    }
}
