//
//  TrendingSection.swift
//  major-7-ios
//
//  Created by jason on 6/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

protocol TrendingSectionDelegate{
    func trendingCellTapped(eventId: String)
}

class TrendingSection: UICollectionViewCell {

    static let reuseIdentifier = "trendingSection"
    
    var delegate: TrendingSectionDelegate?
    
    static let aspectRatio: CGFloat = 335.0 / 297.0 //ratio according to zeplin
    static let width = NewsCellType1.width
    static let height: CGFloat = width / aspectRatio
    
    @IBOutlet weak var trendingSectionLabel: UILabel!
    @IBOutlet weak var trendingCollectionView: UICollectionView!
    
    var trendingEvents: [Event] = [] {
        didSet {
            trendingCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        trendingSectionLabel.textColor = .whiteText()
        trendingSectionLabel.text = "Trending"
        
        if let layout = trendingCollectionView.collectionViewLayout as? PagedCollectionViewLayout {
            layout.scrollDirection = .horizontal
            layout.itemSize = CGSize(width: TrendingCell.width, height: TrendingCell.height)
            layout.minimumLineSpacing = 10
        }
        
        trendingCollectionView.dataSource = self
        trendingCollectionView.delegate = self
        
        trendingCollectionView.showsVerticalScrollIndicator = false
        trendingCollectionView.showsHorizontalScrollIndicator = false
        trendingCollectionView.isPagingEnabled = false
        
        trendingCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
 
        trendingCollectionView.backgroundColor = .darkGray()
        trendingCollectionView.register(UINib.init(nibName: "TrendingCell", bundle: nil), forCellWithReuseIdentifier: TrendingCell.reuseIdentifier)
        
        fetchTrendingEvents()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //fix big/small screen ratio issue
        //trendingCollectionView.frame.size.height = TrendingCell.height
    }
    
    //get trending events list
    private func fetchTrendingEvents(){
        EventsService.fetchTrendingEvents().done { events -> () in
            self.trendingEvents = events.list
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
}

// MARK: UICollectionView Data Source
extension TrendingSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = trendingEvents.isEmpty ? 2 : trendingEvents.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = trendingCollectionView.dequeueReusableCell(withReuseIdentifier: TrendingCell.reuseIdentifier, for: indexPath) as! TrendingCell
        
        if !trendingEvents.isEmpty {
            cell.delegate = self
            
            for view in cell.skeletonViews { //hide all skeleton views
                view.hideSkeleton()
            }
            
            for view in cell.viewsToShowLater { //show hidden view
                UIView.animate(withDuration: 0.75){
                    view.alpha = 1.0
                }
            }
            
            if let imgUrl = URL(string: (trendingEvents[indexPath.row].images.first?.secureUrl)!) {
                cell.bgImgView.kf.setImage(with: imgUrl, options: [.transition(.fade(0.75))])
            }
            
            cell.eventTitle.text = trendingEvents[indexPath.row].title
            cell.performerLabel.text = trendingEvents[indexPath.row].organizerProfile?.name
            cell.dateLabel.text = trendingEvents[indexPath.row].dateTime

        }
    
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.trendingCellTapped(eventId: trendingEvents[indexPath.row].id ?? "")
    }
}

extension TrendingSection: TrendingCellDelegate {
    func bookmarkBtnTapped() {
        print("tapped")
    }
}
