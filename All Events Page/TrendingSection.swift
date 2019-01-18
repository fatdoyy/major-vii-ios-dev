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
    
    var bookmarkedEventArray: [Int] = []
    
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
        
        getTrendingEvents()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //fix big/small screen ratio issue
        //trendingCollectionView.frame.size.height = TrendingCell.height
    }
    
    //get trending events list
    private func getTrendingEvents(){
        EventService.getTrendingEvents().done { response in
            self.trendingEvents = response.eventsList
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
            cell.myIndexPath = indexPath
            
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
            
            //detemine bookmarkBtn bg color
            if UserService.User.isLoggedIn() {
                if bookmarkedEventArray.contains(indexPath.row) {
                    UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                        cell.bookmarkBtn.backgroundColor = .mintGreen()
                    }, completion: nil)
                    
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.bookmarkBtnIndicator.alpha = 0
                        cell.bookmarkBtnIndicator.stopAnimating()
                    })


                } else {
                    EventService.getBookmarkedEvents().done { response in
                        for event in response.bookmarkedEventsList {
                            //check if bookmarked list contains id
                            let isBookmarked = event.targetEvent?.id == self.trendingEvents[indexPath.row].id
                            if isBookmarked {
                                self.bookmarkedEventArray.append(indexPath.row)
                                
                                UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                    cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                                }, completion: nil)

                                UIView.animate(withDuration: 0.1, animations: {
                                    cell.bookmarkBtn.backgroundColor = .mintGreen()
                                })
                                
                                UIView.animate(withDuration: 0.2, animations: {
                                    cell.bookmarkBtnIndicator.alpha = 0
                                    cell.bookmarkBtnIndicator.stopAnimating()
                                    
                                })
                            } else {
                                UIView.animate(withDuration: 0.2, animations: {
                                    cell.bookmarkBtnIndicator.alpha = 0
                                    cell.bookmarkBtnIndicator.stopAnimating()
                                })
                                
                                UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                    cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                                }, completion: nil)
                            }
                        }
                        }.ensure {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }.catch { error in }
                }
            }
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        delegate?.trendingCellTapped(eventId: trendingEvents[indexPath.row].id ?? "")
    }
}

//Bookmark action
extension TrendingSection: TrendingCellDelegate {
    func bookmarkBtnTapped(cell: TrendingCell, tappedIndex: IndexPath) {
        if UserService.User.isLoggedIn() {
            if let eventId = trendingEvents[tappedIndex.row].id {
                if (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //bookmark action
                    HapticFeedback.createImpact(style: .heavy)
                    
                    //animate button state
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.bookmarkBtn.backgroundColor = .mintGreen()
                    })
                    
                    //create bookmark action
                    EventService.createBookmark(eventId: eventId).done { response in
                        print("Event with ID \(eventId) bookmarked")
                        self.bookmarkedEventArray.append(tappedIndex.row)
                        EventService.getBookmarkedEvents().done { response in
                            print("bookmarked events list count: \(response.bookmarkedEventsList.count)")
                            }.ensure {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }.catch { error in }
                        
                        }.ensure {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }.catch { error in }
                } else { //remove bookmark
                    HapticFeedback.createImpact(style: .light)
                    
                    //animate button state
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.bookmarkBtn.backgroundColor = .clear
                    })
                    
                    //remove bookmark action
                    EventService.removeBookmark(eventId: eventId).done { response in
                        print(response)
                        self.bookmarkedEventArray.remove(object: tappedIndex.row)
                        EventService.getBookmarkedEvents().done { response in
                            print("bookmarked events list count: \(response.bookmarkedEventsList.count)")
                            }.ensure {
                                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                            }.catch { error in }
                        
                        }.ensure {
                            UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        }.catch { error in }
                }

            } else {
                print("Can't get trending section event id")
            }
            
            
            
        } else { // not logged in
            print("please login first")
        }
        
    }
    

}

extension Array where Element: Equatable {
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
