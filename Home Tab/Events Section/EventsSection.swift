//
//  EventsSection.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout
import Kingfisher

protocol EventsSectionDelegate {
    func viewAllBtnTapped()
    func cellTapped(eventId: String)
}

class EventsSection: UICollectionViewCell {
    
    var delegate: EventsSectionDelegate?
    
    static let reuseIdentifier: String = "eventsSection"
    
    private typealias `Self` = EventsSection
    
    static let height: CGFloat = 163 //equals to xib frame height
    
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var eventsLabel: UILabel!
    @IBOutlet weak var viewAllBtn: UIButton!
    
    var randomImgUrl: [URL] = []
    var upcomingEvents: [Event] = [] {
        didSet {
            for event in upcomingEvents {
                if let url = event.images.randomElement()?.secureUrl {
                    randomImgUrl.append(URL(string: url)!)
                }
            }
            
            eventsCollectionView.isUserInteractionEnabled = true
            eventsCollectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .darkGray()
        
        eventsLabel.text = "Upcoming Events"
        eventsLabel.textColor = .whiteText()
        
        viewAllBtn.setTitle("VIEW ALL", for: .normal)
        viewAllBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
        viewAllBtn.backgroundColor = UIColor.darkGray
        viewAllBtn.layer.cornerRadius = 13.5
        
        if let layout = eventsCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        eventsCollectionView.isUserInteractionEnabled = false
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
        
        eventsCollectionView.showsVerticalScrollIndicator = false
        eventsCollectionView.showsHorizontalScrollIndicator = false
        
        eventsCollectionView.backgroundColor = .darkGray()
        eventsCollectionView.register(UINib.init(nibName: "EventsCell", bundle: nil), forCellWithReuseIdentifier: EventsCell.reuseIdentifier)
        
        getUpcomingEvents()
    }
    
    @IBAction func viewAllBtnTapped(_ sender: Any) {
        delegate?.viewAllBtnTapped()
    }
    
    //get upcoming events list
    private func getUpcomingEvents() {
        EventService.getUpcomingEvents().done { response -> () in
            self.upcomingEvents = response.list.reversed()
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
}

// MARK: UICollectionView Data Source
extension EventsSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = upcomingEvents.isEmpty ? 2 : upcomingEvents.count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = eventsCollectionView.dequeueReusableCell(withReuseIdentifier: EventsCell.reuseIdentifier, for: indexPath) as! EventsCell
        
        if !upcomingEvents.isEmpty {
            
            for view in cell.skeletonViews { //hide all skeleton views
                view.hideSkeleton()
            }
            
            cell.backgroundColor = .white
//            cell.bgView.layer.insertSublayer(GradientLayer.create(frame: cell.bgView!.bounds, colors: [.lightPurple(), .darkPurple()], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true), at: 0)
            
            cell.bgView.layer.insertSublayer(GradientLayer.create(frame: cell.bgView!.bounds, colors: [.random, .random], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true), at: 0)

            cell.bgView.alpha = 0.7
            cell.imgOverlay.isHidden = false

            cell.bgImgView.kf.setImage(with: randomImgUrl[indexPath.row], options: [.transition(.fade(0.4))])
            
            //decoding the date to "dd MMM"
            let dateResponse = upcomingEvents[indexPath.row].dateTime
            let date = dateResponse?.components(separatedBy: "T") //the response contains "T" between date and time
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd MMM"
            
            if let date = dateFormatterGet.date(from: (date?.first)!) {
                cell.dateLabel.text = dateFormatterPrint.string(from: date)
            } else {
                print("There was an error decoding the string")
            }
            
            cell.eventLabel.text = upcomingEvents[indexPath.row].title
            cell.performerLabel.text = upcomingEvents[indexPath.row].organizerProfile?.name
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: EventsCell.width, height: EventsCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cellTapped(eventId: upcomingEvents[indexPath.row].id ?? "")
    }
}
