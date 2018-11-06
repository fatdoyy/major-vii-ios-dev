//
//  TrendingSection.swift
//  major-7-ios
//
//  Created by jason on 6/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class TrendingSection: UICollectionViewCell {

    static let reuseIdentifier = "tredingSection"
    
    static let aspectRatio: CGFloat = 335.0 / 293.0 //ratio according to zeplin
    static let width = NewsCellType1.width
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    @IBOutlet weak var trendingLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        trendingLabel.textColor = .whiteText()
        trendingLabel.text = "Trending"
        
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        
        trendingCollectionView.showsVerticalScrollIndicator = false
        trendingCollectionView.showsHorizontalScrollIndicator = false
        
        trendingCollectionView.backgroundColor = .darkGray()
        trendingCollectionView.register(UINib.init(nibName: "TrendingCell", bundle: nil), forCellWithReuseIdentifier: TrendingCell.reuseIdentifier)
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("TrendingSection.height = \(self.frame.size.height)")
        print("trendingCollectionView.frame.height = \(trendingCollectionView.frame.height)")
        trendingCollectionView.frame.size.height = TrendingCell.height
    }
}

// MARK: UICollectionView Data Source
extension TrendingSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: TrendingCell.reuseIdentifier, for: indexPath) as! TrendingCell
        cell.eventTitle.text = "This is a good event"
        cell.performerLabel.text = "Billy Fung"
        cell.bgImgView.image = UIImage(named: "music-studio-12")
        cell.bgImgView.backgroundColor = .lightGray
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: TrendingCell.width, height: TrendingCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("\(indexPath.row)")
    }
}
