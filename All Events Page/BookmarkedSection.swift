//
//  BookmarkSection.swift
//  major-7-ios
//
//  Created by jason on 7/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout
import NVActivityIndicatorView
import Pastel

protocol BookmarkSectionDelegate{
    func bookmarkedCellTapped(eventId: String)
}

class BookmarkedSection: UICollectionViewCell {
    
    static let reuseIdentifier = "bookmarkSection"
    
    var delegate: BookmarkSectionDelegate?
    
    static let height: CGFloat = 247
    
    @IBOutlet weak var bookmarkSectionTitle: UILabel!
    @IBOutlet weak var bookmarksCountLabel: UILabel!
    @IBOutlet weak var bookmarksCollectionView: UICollectionView!
    
    var bgView = UIView()
    var gradientBg = PastelView()
    var emptyShadowView = UIView()
    
    var bookmarkedEventIdArray: [String] = [] //to refresh TrendingCell bookmakrBtn state
    
    var bookmarkedEvents: [BookmarkedEvent] = [] {
        didSet {
            if bookmarksCountLabel.alpha == 0 {
                UIView.animate(withDuration: 0.2) {
                    self.bookmarksCountLabel.alpha = 1
                }
            }
            let count = bookmarkedEvents.count
            let isCountEqualsToOne = count == 1
            bookmarksCountLabel.text = isCountEqualsToOne ? "1 Event" : "\(count) Events"
            
            bookmarksCollectionView.reloadData()
            
            if bookmarksCollectionView.alpha == 0 && bookmarkedEvents.count != 0 {
                UIView.animate(withDuration: 0.2) {
                    self.bookmarksCollectionView.alpha = 1
                    self.emptyShadowView.alpha = 0
                }
            } else if bookmarksCollectionView.alpha == 0 && (oldValue.count == 0 || bookmarkedEvents.count == 0) { //show empty view
                gradientBg.startAnimation()
                UIView.animate(withDuration: 0.2) {
                    self.emptyShadowView.alpha = 1
                }
            } else if bookmarksCollectionView.alpha != 0 && bookmarkedEvents.count == 0 {
                UIView.animate(withDuration: 0.2) {
                    self.bookmarksCollectionView.alpha = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    self.gradientBg.startAnimation()
                    UIView.animate(withDuration: 0.2) {
                        self.emptyShadowView.alpha = 1
                    }
                }

            }
            
        }
    }
    
    var reloadIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)), type: .lineScale)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.setObserver(self, selector: #selector(refreshBookmarkedSection(_:)), name: .refreshBookmarkedSection, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(refreshBookmarkedSectionFromDetails(_:)), name: .refreshBookmarkedSectionFromDetails, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(removeAllObservers), name: .removeBookmarkedSectionObservers, object: nil)
        
        bookmarkSectionTitle.textColor = .whiteText()
        bookmarkSectionTitle.text = "Your Bookmarks"
        
        bookmarksCountLabel.textColor = .purpleText()
        bookmarksCountLabel.text = "4 Events"
        bookmarksCountLabel.alpha = 0
        
        if let layout = bookmarksCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        bookmarksCollectionView.dataSource = self
        bookmarksCollectionView.delegate = self
        
        bookmarksCollectionView.showsVerticalScrollIndicator = false
        bookmarksCollectionView.showsHorizontalScrollIndicator = false
        
        bookmarksCollectionView.backgroundColor = .darkGray()
        bookmarksCollectionView.register(UINib.init(nibName: "BookmarkedCell", bundle: nil), forCellWithReuseIdentifier: BookmarkedCell.reuseIdentifier)
        
        reloadIndicator.alpha = 0
        addSubview(reloadIndicator)
        reloadIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(bookmarksCollectionView.snp.centerX)
            make.centerY.equalTo(bookmarksCollectionView.snp.centerY)
        }
        
        //empty view's drop shadow
        emptyShadowView.alpha = 0
        emptyShadowView.frame = CGRect(x: 20, y: 78, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        emptyShadowView.clipsToBounds = false
        emptyShadowView.layer.shadowOpacity = 0.5
        emptyShadowView.layer.shadowOffset = CGSize(width: -1, height: -1)
        emptyShadowView.layer.shadowRadius = GlobalCornerRadius.value
        emptyShadowView.layer.shadowPath = UIBezierPath(roundedRect: emptyShadowView.bounds, cornerRadius: GlobalCornerRadius.value).cgPath
        
        //empty view
        //bgView.alpha = 0
        bgView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        bgView.layer.cornerRadius = GlobalCornerRadius.value
        bgView.clipsToBounds = true
        bgView.backgroundColor = .darkGray
        
        //gradient bg
        gradientBg.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: bookmarksCollectionView.frame.height - 20)
        gradientBg.animationDuration = 2.5
        if UserService.User.isLoggedIn() {
            gradientBg.setColors([UIColor(hexString: "#C06C84"), UIColor(hexString: "#6C5B7B"), UIColor(hexString: "#355C7D")])
            emptyShadowView.layer.shadowColor = UIColor(hexString: "#6C5B7B").cgColor
        } else {
            gradientBg.setColors([UIColor(hexString: "#FDC830"), UIColor(hexString: "#F37335")])
            setupLoginView()
            emptyShadowView.layer.shadowColor = UIColor(hexString: "#FDC830").cgColor
        }
        gradientBg.startAnimation()
        
        bgView.insertSubview(gradientBg, at: 0)
        emptyShadowView.addSubview(bgView)
        addSubview(emptyShadowView)

        if UserService.User.isLoggedIn() {
            getBookmarkedEvents()
        } else {
            bookmarksCollectionView.alpha = 0
            emptyShadowView.alpha = 1
        }
    }
    
    private func setupLoginView() {
        let loginImgView = UIImageView()
        loginImgView.image = UIImage(named: "login")
        bgView.addSubview(loginImgView)
        loginImgView.snp.makeConstraints { (make) in
            make.topMargin.equalTo(15)
            make.leftMargin.equalTo(15)
            make.size.equalTo(40)
        }
        
        let loginTitle = UILabel()
        loginTitle.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        loginTitle.text = "Log-in now!"
        loginTitle.textColor = .white
        bgView.addSubview(loginTitle)
        loginTitle.snp.makeConstraints { (make) in
            make.topMargin.equalTo(20)
            make.leftMargin.equalTo(loginImgView.snp.right).offset(12)
            make.width.equalTo(200)
            make.height.equalTo(30)
        }

        let loginDesc = UILabel()
        loginDesc.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        loginDesc.text = "Enjoy full experience with your Major VII account."
        loginDesc.textColor = .white
        loginDesc.numberOfLines = 2
        bgView.addSubview(loginDesc)
        loginDesc.snp.makeConstraints { (make) in
            make.topMargin.equalTo(loginTitle.snp.bottom).offset(10)
            make.leftMargin.equalTo(25)
            make.width.equalTo(200)
            make.height.equalTo(60)
        }
        
        let loginBtn = UIButton()
        loginBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        loginBtn.layer.cornerRadius = GlobalCornerRadius.value / 2
        loginBtn.setTitle("Sure!", for: .normal)
        loginBtn.setTitleColor(UIColor(hexString: "#F37335"), for: .normal)
        loginBtn.backgroundColor = .white
        bgView.addSubview(loginBtn)
        loginBtn.snp.makeConstraints { (make) in 
            make.bottomMargin.equalTo(bgView.snp.bottom).offset(-25)
            make.rightMargin.equalTo(bgView.snp.right).offset(-25)
            make.width.equalTo(60)
            make.height.equalTo(28)
        }
    }
    
    
    func getBookmarkedEvents(completion: (() -> Void)? = nil) {
        EventService.getBookmarkedEvents().done { response in
            self.bookmarkedEvents = response.bookmarkedEventsList.reversed()
            
            for event in response.bookmarkedEventsList {
                if let eventId = event.targetEvent!.id {
                    if !self.bookmarkedEventIdArray.contains(eventId) {
                        self.bookmarkedEventIdArray.append(eventId)
                    }
                }
            }
            
            print("Bookmarked events list count: \(response.bookmarkedEventsList.count)")
            print("Initial bookmarkedEventIdArray: \(self.bookmarkedEventIdArray)")
            }.ensure {
                if self.reloadIndicator.alpha != 0 {
                    UIView.animate(withDuration: 0.2) {
                        self.reloadIndicator.alpha = 0
                    }
                }
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                if let completion = completion { completion() }
            }.catch { error in }
        
    }
    
    @objc private func refreshBookmarkedSection(_ notification: Notification) {
        reloadIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) {
            if self.emptyShadowView.alpha != 0 {
                self.emptyShadowView.alpha = 0
            }
            self.bookmarksCollectionView.alpha = 0
            self.reloadIndicator.alpha = 1
        }
        
        if let data = notification.userInfo {
            if let eventId = data["add_id"] as? String {
                print("Recieved event id: \(eventId), double checking BookmarkedSection's bookmarkedEventIdArray...")
                if !self.bookmarkedEventIdArray.contains(eventId) {
                    self.bookmarkedEventIdArray.append(eventId)
                    print("\(eventId) is added to bookmarkedEventIdArray - bookmarkedEventIdArray: \(self.bookmarkedEventIdArray)\n")
                }
            } else if let eventId = data["remove_id"] as? String {
                if self.bookmarkedEventIdArray.contains(eventId) {
                    self.bookmarkedEventIdArray.remove(object: eventId)
                    print("Recieved remove id: \(eventId) - bookmarkedEventIdArray: \(self.bookmarkedEventIdArray)\n")
                }
            }
        }
        
        getBookmarkedEvents()
    }
    
    @objc private func refreshBookmarkedSectionFromDetails(_ notification: Notification) {
        //        getBookmarkedEvents {
        //            if let data = notification.userInfo {
        //                if let eventId = data["check_id"] as? String {
        //                    if !self.bookmarkedEventIdArray.contains(eventId) {
        //
        //                        self.reloadIndicator.startAnimating()
        //                        UIView.animate(withDuration: 0.2) {
        //                            self.reloadIndicator.alpha = 1
        //                            self.bookmarksCollectionView.alpha = 0
        //                        }
        //
        //                        self.bookmarksCollectionView.reloadData()
        //
        //                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //                            UIView.animate(withDuration: 0.2) {
        //                                self.reloadIndicator.alpha = 0
        //                                self.bookmarksCollectionView.alpha = 1
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        }
        
        getBookmarkedEvents()
    }
    
    @objc private func removeAllObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension BookmarkedSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if UserService.User.isLoggedIn() && !bookmarkedEvents.isEmpty {
            return bookmarkedEvents.count
        } else {
            return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = bookmarksCollectionView.dequeueReusableCell(withReuseIdentifier: BookmarkedCell.reuseIdentifier, for: indexPath) as! BookmarkedCell
        if !bookmarkedEvents.isEmpty {
            if let event = bookmarkedEvents[indexPath.row].targetEvent {
                cell.delegate = self
                cell.myIndexPath = indexPath
                cell.eventTitle.text = event.title
                cell.dateLabel.text = event.dateTime
                cell.performerLabel.text = event.organizerProfile?.name
                cell.bookmarkBtn.backgroundColor = .mintGreen()
                if let url = URL(string: event.images[0].secureUrl!) {
                    cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.75))])
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: BookmarkedCell.width, height: BookmarkedCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let eventId = bookmarkedEvents[indexPath.row].targetEvent?.id {
            delegate?.bookmarkedCellTapped(eventId: eventId)
        }
    }
}

extension BookmarkedSection: BookmarkedCellDelegate {
    func bookmarkBtnTapped(cell: BookmarkedCell, tappedIndex: IndexPath) {
        if let eventId = bookmarkedEvents[tappedIndex.row].targetEvent?.id {
            if (cell.bookmarkBtn.backgroundColor?.isEqual(UIColor.clear))! { //do bookmark action
                HapticFeedback.createImpact(style: .light)
                cell.bookmarkBtn.isUserInteractionEnabled = false
                
                //animate button state
                UIView.animate(withDuration: 0.2) {
                    cell.bookmarkBtnIndicator.alpha = 1
                }
                
                UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    cell.bookmarkBtn.setImage(nil, for: .normal)
                }, completion: nil)
                
                //create bookmark action
                EventService.createBookmark(eventId: eventId).done { _ in
                    print("Event with ID (\(eventId)) bookmarked")
                    }.ensure {
                        self.bookmarkedEventIdArray.append(eventId) //the cell is now hold by this array and will not have cell reuse issues
                        UIView.animate(withDuration: 0.2) {
                            cell.bookmarkBtn.backgroundColor = .mintGreen()
                            cell.bookmarkBtnIndicator.alpha = 0
                        }
                        
                        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                        }, completion: nil)
                        
                        cell.bookmarkBtn.isUserInteractionEnabled = true
                        NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil) //reload collection view in BookmarkedSection
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        HapticFeedback.createNotificationFeedback(style: .success)
                    }.catch { error in }
                
            } else { //remove bookmark
                HapticFeedback.createImpact(style: .light)
                cell.bookmarkBtn.isUserInteractionEnabled = false
                
                //animate button state
                UIView.animate(withDuration: 0.2) {
                    cell.bookmarkBtnIndicator.alpha = 1
                }
                
                UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    cell.bookmarkBtn.setImage(nil, for: .normal)
                }, completion: nil)
                
                //remove bookmark action
                EventService.removeBookmark(eventId: eventId).done { response in
                    //print(response)
                    }.ensure {
                        UIView.animate(withDuration: 0.2) {
                            cell.bookmarkBtn.backgroundColor = .clear
                            cell.bookmarkBtnIndicator.alpha = 0
                        }
                        
                        UIView.transition(with: cell.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            cell.bookmarkBtn.setImage(UIImage(named: "bookmark"), for: .normal)
                        }, completion: nil)
                        
                        cell.bookmarkBtn.isUserInteractionEnabled = true
                        
                        if let eventId = self.bookmarkedEvents[tappedIndex.row].targetEvent?.id {
                            print("Sending id \(eventId) from BookmarkedSection to TrendingSection for removal\n")
                            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["remove_id": eventId])
                            self.bookmarkedEventIdArray.remove(object: eventId)
                            print("bookmarkedEventIdArray : \(self.bookmarkedEventIdArray)")
                        }
                        
                        NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil) //reload collection view in this view
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        HapticFeedback.createNotificationFeedback(style: .success)
                    }.catch { error in }
            }
            
        } else {
            print("Can't get bookamrk section event id")
        }
        
    }
}
