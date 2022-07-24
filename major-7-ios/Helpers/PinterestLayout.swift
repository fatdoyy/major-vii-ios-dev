//
//  PinterestLayout.swift
//  major-7-ios
//
//  Created by jason on 19/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewFlowLayout {
    // Keeps reference to the delegate
    weak var delegate: PinterestLayoutDelegate?
    
    // Configures the layout: column number & cell padding
    fileprivate var numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 10
    
    // Array to store calculated attributes, more efficient to query than calling it multiple times when prepare() is called
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    // Store the content size, height and width
    fileprivate var contentHeight: CGFloat = 0
    
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.contentInset
        
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // Override default content width & height with calculated values above
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        // calculate layout attributes if cache is empty and CV exists
        guard let collectionView = collectionView else { return }
        
        // Declare & fill xOffset array for every column based on widths
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset = [CGFloat]()
        
        for column in 0 ..< numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        
        //yOffset array tracks y-position for every column.
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        // Loops through all items in first section
        for item in 0 ..< collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)

            /* Perform frame calculation, width is the previously calculated cellWidth, with the padding between cells removed. You ask the delegate for the height of the photo and calculate the frame height based on this height and the predefined cellPaddingfor the top and bottom. You then combine this with the x and y offsets of the current column to create the insetFrame used by the attribute.
             */
            
            let photoHeight = delegate?.collectionView(collectionView, heightForPhotoAtIndexPath: indexPath)
            let height = cellPadding * 2 + photoHeight!
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            // Creates instance of UICollectionViewLayoutAttribues, sets its frame & appends attributes to cache
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            // Expand content height to account for frame of newly calculated item and advances yOffset for current column based on frame.
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            // Advance column so that next item will be placed in next column
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
        
        // Add Attributes for section footer
//        let footerAtrributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, with: IndexPath(item: 0, section: 0))
//        footerAtrributes.frame = CGRect(x: 0, y: collectionView.bounds.maxY, width: UIScreen.main.bounds.width, height: NewsSectionFooter.height)
//        cache.append(footerAtrributes)
    }
    
    // MARK: Override Attribute Methods
    // Override layoutAttributesForElements(in:), wich CV calls after prepare() to determine which items are visible in a given rect
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
//    }
    
    // Retrieve and return from cache the layout attributes which correspond to requested indexPath
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
