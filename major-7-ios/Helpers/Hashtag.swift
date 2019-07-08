//
//  Hashtags.swift
//  major-7-ios
//
//  Created by jason on 1/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Foundation
import UIKit

class Hashtag {
    
    //tag padding in BG view
    static let labelTopBottomPaddingInBgView: CGFloat = 5
    static let labelLeftRightPaddingInBgView: CGFloat = 8
    static let paddingBetweenTags: CGFloat = 10
    
    //create hashtags at cell (DEPRECATED)
    static func createAtCell(cell: UICollectionViewCell, position: Hashtag.Position, dataSource: [String], multiLines: Bool? = false, solidColor: Bool? = false) {
        //cell paddings
        var leftPaddingToCell: CGFloat = 20
        let rightPaddingToCell: CGFloat = 20
        
        var topPaddingToCell: CGFloat = 20
        let bottomPaddingToCell: CGFloat = 55
        
        let allLabels = cell.allSubViewsOf(type: TagLabel.self)
        
        if allLabels.isEmpty { // avoid adding the same hashtags multiple times
            if !dataSource.isEmpty{
                for tag in dataSource{
                    let tagLabel = TagLabel()
                    
                    if position == .cellTop {
                        tagLabel.frame = CGRect(x: cell.contentView.frame.minX + leftPaddingToCell + labelLeftRightPaddingInBgView,
                                                y: cell.contentView.frame.minY + topPaddingToCell + labelTopBottomPaddingInBgView,
                                                width: tagLabel.intrinsicContentSize.width,
                                                height: 14)
                    } else {
                        tagLabel.frame = CGRect(x: cell.contentView.frame.minX + leftPaddingToCell + labelLeftRightPaddingInBgView,
                                                y: cell.frame.height - bottomPaddingToCell - labelTopBottomPaddingInBgView,
                                                width: tagLabel.intrinsicContentSize.width,
                                                height: 14)
                    }
                    
                    if !tagLabel.isHidden { //if the next hashtag is not out of bounds
                        tagLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
                        tagLabel.textAlignment = .center
                        tagLabel.text = "#\(tag)"
                        tagLabel.sizeToFit()
                        
                        if let isMultiLine = multiLines{ //breaking to next line if hashtag is out of bounds
                            if isMultiLine {
                                if tagLabel.frame.maxX >= cell.contentView.frame.width {
                                    topPaddingToCell += 30
                                    leftPaddingToCell = 20
                                    
                                    var newFrame = tagLabel.frame
                                    newFrame.origin.x = cell.contentView.frame.minX + leftPaddingToCell + labelLeftRightPaddingInBgView
                                    newFrame.origin.y = cell.contentView.frame.minY + topPaddingToCell + labelTopBottomPaddingInBgView
                                    tagLabel.frame = newFrame
                                }
                            } else {
                                if tagLabel.frame.maxX >= (cell.contentView.frame.width - rightPaddingToCell) {
                                    tagLabel.isHidden = true //not showing all hashtags due to cell width
                                }
                            }
                        }
                        
                        if !tagLabel.isHidden{ //only add bgView under tagLabel when it's not set hidden
                            //background view under UILabel
                            let bgView = UIView(frame: CGRect(x: tagLabel.frame.minX - labelLeftRightPaddingInBgView,
                                                              y: tagLabel.frame.minY - labelTopBottomPaddingInBgView,
                                                              width: tagLabel.frame.width + (labelLeftRightPaddingInBgView * 2),
                                                              height: tagLabel.frame.height + (labelTopBottomPaddingInBgView * 2)))
                            bgView.layer.cornerRadius = 8
                            
                            if let isSolidColor = solidColor{
                                if isSolidColor{
                                    bgView.backgroundColor = .mintGreen()
                                    tagLabel.textColor = .whiteText()
                                } else {
                                    bgView.backgroundColor = .white15Alpha()
                                    tagLabel.textColor = .whiteText75Alpha()
                                }
                            }
                            
                            leftPaddingToCell += (tagLabel.frame.width + paddingBetweenTags + (labelLeftRightPaddingInBgView * 2)) //calculate new x for next hashtag
                            
                            cell.addSubview(tagLabel)
                            cell.insertSubview(bgView, belowSubview: tagLabel)
                        }
                    }
                }
            } else {
                print("Hashtag array is empty")
            }
        } else {
            //print("Hashtags already created!")
        }
    }
}

//create taglabel class to idetify them in all subviews
class TagLabel: UILabel {
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

//Hashtag positions
extension Hashtag {
    enum Position {
        case cellTop
        case cellBottom
        case detailsView
    }
}

extension UIView {
    /** This is the function to get subViews of a view of a particular type
     */
    func subViews<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        for view in self.subviews {
            if let aView = view as? T{
                all.append(aView)
            }
        }
        return all
    }
    
    /** This is a function to get subViews of a particular type from view recursively. It would look recursively in all subviews and return back the subviews of the type T */
    func allSubViewsOf<T : UIView>(type : T.Type) -> [T]{
        var all = [T]()
        func getSubview(view: UIView) {
            if let aView = view as? T{
                all.append(aView)
            }
            guard view.subviews.count>0 else { return }
            view.subviews.forEach{ getSubview(view: $0) }
        }
        getSubview(view: self)
        return all
    }
}

class HashtagsFlowLayout: UICollectionViewFlowLayout {
    
    let cellSpacing: CGFloat = 8
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 4.0
        self.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        return attributes
    }
}
