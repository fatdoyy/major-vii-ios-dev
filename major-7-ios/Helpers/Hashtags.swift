//
//  Hashtags.swift
//  major-7-ios
//
//  Created by jason on 1/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import Foundation
import UIKit

class Hashtags {
    
    static func create(position: Hashtags.Position, dataSource: [String], toCell: UICollectionViewCell, multiLines: Bool? = false, solidColor: Bool? = false){
        let allLabels = toCell.allSubViewsOf(type: TagLabel.self)

        var leftPaddingToCell: CGFloat = 20
        let rightPaddingToCell: CGFloat = 20
        
        var topPaddingToCell: CGFloat = 20
        let bottomPaddingToCell: CGFloat = 55
        
        let labelTopBottomPaddingInBgView: CGFloat = 5
        let labelLeftRightPaddingInBgView: CGFloat = 8
        let paddingBetweenTags: CGFloat = 10
        
        if allLabels.isEmpty { // avoid adding the same hashtags multiple times
            if !dataSource.isEmpty{
                for tag in dataSource{
                    let tagLabel = TagLabel()
                    
                    if position == .top {
                        tagLabel.frame = CGRect(x: toCell.contentView.frame.minX + leftPaddingToCell + labelLeftRightPaddingInBgView,
                                                y: toCell.contentView.frame.minY + topPaddingToCell + labelTopBottomPaddingInBgView,
                                                width: tagLabel.intrinsicContentSize.width,
                                                height: 14)
                    } else {
                        tagLabel.frame = CGRect(x: toCell.contentView.frame.minX + leftPaddingToCell + labelLeftRightPaddingInBgView,
                                                y: toCell.frame.height - bottomPaddingToCell - labelTopBottomPaddingInBgView,
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
                                if tagLabel.frame.maxX >= toCell.contentView.frame.width {
                                    topPaddingToCell += 30
                                    leftPaddingToCell = 20
                                    
                                    var newFrame = tagLabel.frame
                                    newFrame.origin.x = toCell.contentView.frame.minX + leftPaddingToCell + labelLeftRightPaddingInBgView
                                    newFrame.origin.y = toCell.contentView.frame.minY + topPaddingToCell + labelTopBottomPaddingInBgView
                                    tagLabel.frame = newFrame
                                }
                            } else {
                                if tagLabel.frame.maxX >= (toCell.contentView.frame.width - rightPaddingToCell){
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
                            
                            toCell.addSubview(tagLabel)
                            toCell.insertSubview(bgView, belowSubview: tagLabel)
                        }
                    }
                }
            } else {
                print("Hashtag array is empty")
            }
        } else {
            print("Hashtags already created for that cell!")
        }
    }
}

class TagLabel: UILabel {
    init() {
        super.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension Hashtags {
    enum Position {
        case top
        case bottom
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
