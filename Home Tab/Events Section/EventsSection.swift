//
//  EventsSection.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout

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
    
    var upcomingEvents: [UpcomingEvent] = [] {
        didSet {
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
        
        if let layout = eventsCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
        
        eventsCollectionView.showsVerticalScrollIndicator = false
        eventsCollectionView.showsHorizontalScrollIndicator = false
        
        eventsCollectionView.backgroundColor = .darkGray()
        eventsCollectionView.register(UINib.init(nibName: "EventsCell", bundle: nil), forCellWithReuseIdentifier: EventsCell.reuseIdentifier)
        
        fetchUpcomingEvents()
    }
    
    @IBAction func viewAllBtnTapped(_ sender: Any) {
        delegate?.viewAllBtnTapped()
    }
    
    //get upcoming events list
    private func fetchUpcomingEvents(){
        EventsService.fetchUpcomingEvents().done { events -> () in
            self.upcomingEvents = events.list
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
            
            cell.bgView.layer.insertSublayer(GradientLayer.create(frame: cell.bgView!.bounds, colors: [.lightPurple(), .darkPurple()], cornerRadius: true), at: 0)
            //cell.bgImgView.image = UIImage(named: "cat")

            
            //decoding the date to "dd MMM"
            let dateResponse = upcomingEvents[indexPath.row].dateTime
            let date = dateResponse?.components(separatedBy: "T") //the response contains "T" between date and time
            
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = "yyyy-MM-dd"
            
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd MMM"
            
            if let date = dateFormatterGet.date(from: (date?.first)!) {
                print(dateFormatterPrint.string(from: date))
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
//        let detailsVc = EventDetailsViewController()
//        detailsVc.eventsId = upcomingEvents[indexPath.row].id ?? ""
        //print(upcomingEvents[indexPath.row].id ?? "")
        delegate?.cellTapped(eventId: upcomingEvents[indexPath.row].id ?? "")
    }
}
