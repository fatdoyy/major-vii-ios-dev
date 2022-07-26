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

protocol EventsSectionDelegate: AnyObject {
    func viewAllBtnTapped()
    func cellTapped(eventID: String)
}

class EventsSection: UICollectionViewCell {
    weak var delegate: EventsSectionDelegate?
    
    static let reuseIdentifier: String = "eventsSection"
    
    //set delegate with HomeVC instance. (For refreshing)
    var homeVCInstance: HomeViewController? {
        didSet {
            if let instance = homeVCInstance {
                instance.delegate = self
            }
        }
    }
    
    private typealias `Self` = EventsSection
    
    static let height: CGFloat = 163 //equals to xib frame height
    
    @IBOutlet weak var eventsCollectionView: UICollectionView!
    @IBOutlet weak var eventsLabel: UILabel!
    @IBOutlet weak var viewAllBtn: UIButton!
    @IBOutlet weak var emptyEventsLabel: UILabel!
    
    var randomImgUrl = [URL]()
    var upcomingEvents = [Event]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = .m7DarkGray()
        
        setupUI()
        getUpcomingEvents()
    }
    
    @IBAction func viewAllBtnTapped(_ sender: Any) {
        delegate?.viewAllBtnTapped()
    }
    
}

//MARK: - UI related
extension EventsSection {
    private func setupUI() {
        eventsLabel.text = "Upcoming Events"
        eventsLabel.textColor = .whiteText()
        
        viewAllBtn.setTitle("VIEW ALL", for: .normal)
        viewAllBtn.setTitleColor(.purpleText(), for: .normal)
        viewAllBtn.backgroundColor = UIColor(hexString: "#7e7ecf").withAlphaComponent(0.2)
        viewAllBtn.layer.cornerRadius = 13.5
        
        if let layout = eventsCollectionView.collectionViewLayout as? BouncyLayout {
            layout.scrollDirection = .horizontal
            layout.minimumLineSpacing = 15
            layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        }
        
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
        
        eventsCollectionView.showsVerticalScrollIndicator = false
        eventsCollectionView.showsHorizontalScrollIndicator = false
        
        eventsCollectionView.backgroundColor = .m7DarkGray()
        eventsCollectionView.register(UINib.init(nibName: "EventsCell", bundle: nil), forCellWithReuseIdentifier: EventsCell.reuseIdentifier)
        
        emptyEventsLabel.text = "No events?? Really?"
        emptyEventsLabel.alpha = 0
        
        let overlayLeft = UIImageView(image: UIImage(named: "collectionview_overlay_left_to_right"))
        addSubview(overlayLeft)
        overlayLeft.snp.makeConstraints { (make) in
            make.height.equalTo(eventsCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(eventsCollectionView.snp.top)
            make.left.equalTo(eventsCollectionView.snp.left)
        }
        
        let overlayRight = UIImageView(image: UIImage(named: "collectionview_overlay_right_to_left"))
        addSubview(overlayRight)
        overlayRight.snp.makeConstraints { (make) in
            make.height.equalTo(eventsCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(eventsCollectionView.snp.top)
            make.right.equalTo(eventsCollectionView.snp.right)
        }
    }
    
}

//MARK: - API Calls | Home VC Delegate
extension EventsSection: HomeViewControllerDelegate {
    //get upcoming events list
    func getUpcomingEvents() {
        eventsCollectionView.isUserInteractionEnabled = false
        EventService.getUpcomingEvents().done { response -> () in
            self.upcomingEvents = response.list //.reversed()
            
            if !self.upcomingEvents.isEmpty {
                for event in self.upcomingEvents {
                    if let url = event.images.randomElement()?.url {
                        self.randomImgUrl.append(URL(string: url)!)
                    }
                }
                
                self.eventsCollectionView.isUserInteractionEnabled = true
                self.eventsCollectionView.reloadData()
            } else {
                self.eventsCollectionView.alpha = 0
                self.emptyEventsLabel.alpha = 1
            }
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    func refreshUpcomingEvents() {
        //first clear data model
        randomImgUrl.removeAll()
        upcomingEvents.removeAll()
        eventsCollectionView.setContentOffset(CGPoint.zero, animated: false)
        eventsCollectionView.reloadData()
        
        getUpcomingEvents()
    }
}

//MARK: - UICollectionView Data Source
extension EventsSection: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
            
            //cell.bgView.layer.insertSublayer(GradientLayer.create(frame: cell.bgView!.bounds, colors: [.lightPurple(), .darkPurple()], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true), at: 0)
            let colorGradientLayer = GradientLayer.create(frame: cell.bgView!.bounds, colors: [.random, .random], startPoint: CGPoint(x: 0, y: 0.5), endPoint: CGPoint(x: 1, y: 0.5), cornerRadius: true)
            colorGradientLayer.name = "colorGradientLayer"
            cell.bgView.layer.insertSublayer(colorGradientLayer, at: 0)

            cell.bgView.alpha = 0.7
            cell.imgOverlay.isHidden = false

            cell.bgImgView.kf.setImage(with: randomImgUrl[indexPath.row], options: [.transition(.fade(0.3))])
            
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
            UIView.animate(withDuration: 0.4) {
                cell.verifiedIcon.alpha = self.upcomingEvents[indexPath.row].organizerProfile?.verified ?? true ? 1 : 0
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: EventsCell.width, height: EventsCell.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.cellTapped(eventID: upcomingEvents[indexPath.row].id ?? "")
    }
}
