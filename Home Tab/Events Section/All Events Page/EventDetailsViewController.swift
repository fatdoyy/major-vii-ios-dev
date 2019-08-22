//
//  EventDetailsViewController.swift
//  major-7-ios
//
//  Created by jason on 13/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Hero
import ImageViewer
import Floaty

//rounded view in header's bottom (i.e. the red view in IB)
class roundedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.topLeft, .topRight], radius: GlobalCornerRadius.value + 4)
    }
}

//Image viewer item
struct ImgViewerItem {
    let imageView: UIImageView
    let galleryItem: GalleryItem
}

class EventDetailsViewController: UIViewController {
    static let storyboardID = "eventDetails"
    
    var isFromBookmarkedSection = false //no need to check bookmarkBtn's state if true (i.e. from Bookmarked section, state must be bookmarked)
    var didChangeBookmarkBtnState = false //only refresh bookmarkBtn's state when this is true
    
    //determine didChangeBookmarkBtnState is true/false by comparing bookmarkBtn's initial and final state
    var bookmarkBtnInitialState = false
    var bookmarkBtnNewState: Bool?
    
    @IBOutlet weak var headerImg: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    @IBOutlet weak var bgView: EventDetailsView!
    
    @IBOutlet weak var roundedView: UIView!
    
    //img viewer
    var imgUrlArray: [String] = []
    var imgViewerItems: [ImgViewerItem] = []
    var displaceableImgView: UIImageView?
    
    //floaty btn
    var floatyBtn = Floaty()
    
    //gesture for swipe-pop
    var gesture: UIGestureRecognizer?
    
    //eventID
    var eventID = "" {
        didSet {
            getDetails(eventID: eventID)
        }
    }
    
    var allBoomarkedEventId : [String] = []
    
    //event details
    var eventDetails: EventDetails? {
        didSet {
            loadDetails()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        gesture?.delegate = self
        self.hero.isEnabled = true
        view.backgroundColor = .m7DarkGray()
        roundedView.backgroundColor = .m7DarkGray()
        mainScrollView.delegate = self
        
        createHeroTransitions()
        
        setupLeftBarItems()
        FloatyBtn.create(btn: floatyBtn, toVC: self)
        floatyBtn.fabDelegate = self
        
        mainScrollView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //transparent navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.barTintColor = .darkGray()
        navigationController?.navigationBar.isTranslucent = true
        
        if !isModal {
            TabBar.hide(from: self)
        } else {
            setupCloseBtn()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let parentVC = self.parent {
            if let _ = parentVC as? HomeViewController {
                print("parentVC is HomeView")
            } else {

            }
        }

        //check if need to refresh EventListVC after dismissing this VC
        if UserService.User.isLoggedIn() {
            NotificationCenter.default.post(name: .refreshTrendingSectionCell, object: nil, userInfo: ["check_id": eventID])
            NotificationCenter.default.post(name: .refreshFollowingSectionCell, object: nil, userInfo: ["check_id": eventID])
            
            if didChangeBookmarkBtnState { //only refresh Bookmarked Section if true
                NotificationCenter.default.post(name: .refreshBookmarkedSection, object: nil, userInfo: ["check_id": eventID])
                isFromBookmarkedSection = false
                didChangeBookmarkBtnState = false
            }
        }
            
        if !isModal { TabBar.show(from: self) }
    }
    
    private func getDetails(eventID: String) {
        EventService.getEventDetails(eventID: eventID).done { details -> () in
            self.eventDetails = details
            self.loadImgIntoImgViewer()

            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func loadDetails() {
        if let url = URL(string: (eventDetails!.item?.images.first?.secureUrl)!) {
            headerImg.kf.setImage(with: url, options: [.transition(.fade(0.3))])
        }
        
        bgView.delegate = self
        
        //check bookmarkBtn state
        if UserService.User.isLoggedIn() {
            if !isFromBookmarkedSection { //do checking when not from bookmarked section
                UserService.getBookmarkedEvents().done { response in
                    if !response.list.isEmpty {
                        for event in response.list {
                            if let targetEvent = event.targetEvent {
                                if let eventID = targetEvent.id {
                                    self.allBoomarkedEventId.append(eventID)
                                }
                            }
                        }
                        
                        if self.allBoomarkedEventId.contains(self.eventID) { //is bookmarked
                            UIView.transition(with: self.bgView.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                self.bgView.bookmarkBtn.setImage(UIImage(named: "eventdetails_bookmarked_1"), for: .normal)
                            }, completion: nil)
                            self.bookmarkBtnInitialState = true
                            
                            self.hideIndicator()
                        } else { //not bookmarked
                            UIView.transition(with: self.bgView.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                                self.bgView.bookmarkBtn.setImage(UIImage(named: "eventdetails_bookmarked_0"), for: .normal)
                            }, completion: nil)
                            
                            self.hideIndicator()
                        }
                        
                    } else { //list is empty
                        UIView.transition(with: self.bgView.bookmarkBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                            self.bgView.bookmarkBtn.setImage(UIImage(named: "eventdetails_bookmarked_0"), for: .normal)
                        }, completion: nil)
                        
                        self.hideIndicator()
                    }
                    }.catch { error in }
            } else { //from bookmarked section, no need to do check (i.e. bookmarked = true)
                hideIndicator()
                bgView.bookmarkBtn.setImage(UIImage(named: "eventdetails_bookmarked_1"), for: .normal)
                bookmarkBtnInitialState = true
            }
            
        }

        bgView.titleLabel.text = eventDetails!.item?.title
        bgView.performerLabel.text = eventDetails!.item?.organizerProfile?.name
        
        bgView.hashtagsArray = (eventDetails?.item?.hashtags)!
        bgView.hashtagsCollectionView.reloadData()
        
        if let eventDate = eventDetails?.item?.dateTime?.toDate(), let currentDate = Date().toISO().toDate() {
            let difference = DateTimeHelper.getEventInterval(from: currentDate, to: eventDate)
            let formattedDate = eventDate.toFormat("yyyy-MM-dd")
            bgView.dateLabel.text = "\(formattedDate) (\(difference))"
        }

        bgView.venueLabel.text = eventDetails?.item?.venue
        
        // setup attributes for string
        let descString = eventDetails!.item?.desc
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.whiteText(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        // create attributed string
        let descAttrString = NSAttributedString(string: descString!, attributes: myAttribute)

        // set attributed text on a UILabel
        bgView.descLabel.attributedText = descAttrString
        
        //only load imgCollectionView if device is not iPhone SE
        if UIDevice.current.type != .iPhone_5_5S_5C_SE {
            for img in (eventDetails?.item?.images)! {
                imgUrlArray.append(img.secureUrl ?? "")
            }
            
            bgView.imgUrlArray = self.imgUrlArray
            bgView.imgCollectionView.reloadData()
        }
        
        bgView.remarksLabel.text = eventDetails?.item?.remarks
        bgView.webLabel.text = eventDetails?.item?.webUrl
        
        bgView.layoutIfNeeded()
        
        for view in bgView.skeletonViews {
            if view.tag == 2 { //remove dummyTagLabel
                view.removeFromSuperview()
            }
            view.hideSkeleton()
        }
        
        for view in bgView.viewsToShowLater {
            if view.tag == 111 { //not fading hashtagsCollectionView for better exp.
                view.alpha = 1.0
            } else {
                UIView.animate(withDuration: 0.75) {
                    view.alpha = 1.0
                }
            }
        }
    }
    
    private func createHeroTransitions() {
        bgView.hero.modifiers = [.delay(0.1), .translate(y: 500)]
        bgView.bookmarkBtn.hero.modifiers = [.delay(0.3), .translate(y: 500)]
        bgView.bookmarkCountImg.hero.modifiers = [.delay(0.35), .translate(y: 500)]
        bgView.bookmarkCountLabel.hero.modifiers = [.delay(0.4), .translate(y: 500)]
        self.floatyBtn.hero.modifiers = [.fade]
    }
    
    private func setupLeftBarItems() {
        let customView = UIView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        customView.backgroundColor = .clear
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        menuBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        customView.addSubview(menuBtn)
        
        customView.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(30)
        }
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    private func setupCloseBtn() {
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "icon_close"), for: .normal)
        closeBtn.setTitle("", for: .normal)
        closeBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        mainScrollView.addSubview(closeBtn)
        mainScrollView.bringSubviewToFront(closeBtn)
        closeBtn.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(32)
            make.left.equalTo(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    private func loadImgIntoImgViewer() {
        
        if imgUrlArray.count != 0 {
            
            for i in 0 ..< imgUrlArray.count {
                let imgView = UIImageView() //create imgView for each web url
                let galleryItem = GalleryItem.image { imageCompletion in
                    let url = URL(string: self.imgUrlArray[i])
                    imgView.kf.setImage(with: url) { result in
                        switch result {
                        case .success(let value):
                            //print(value.image)
                            imageCompletion(value.image)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
                
                imgViewerItems.append(ImgViewerItem(imageView: imgView, galleryItem: galleryItem))
            }
        }
        
    }
    
    private func showIndicator() {
        UIView.animate(withDuration: 0.2) {
            self.bgView.loadingIndicator.alpha = 1
        }
    }
    
    private func hideIndicator() {
        UIView.animate(withDuration: 0.2) {
            self.bgView.loadingIndicator.alpha = 0
        }
    }
    
    @objc private func popView() {
        navigationController?.hero.navigationAnimationType = .zoomOut
        navigationController?.popViewController(animated: true)
    }
}

//MARK: Scrollview delegate
extension EventDetailsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}

//MARK: Events Details View Delegate
extension EventDetailsViewController: EventsDetailsViewDelegate {
    func bookmarkBtnTapped(sender: UIButton) {
        if UserService.User.isLoggedIn() {
            sender.isUserInteractionEnabled = false
            
            let bookmarkedImg = UIImage(named: "eventdetails_bookmarked_1")
            let notBookmarkedImg = UIImage(named: "eventdetails_bookmarked_0")
            
            if (sender.currentImage?.isEqual(notBookmarkedImg))! { //if the image is notBookmarkedImg, then do bookmark action
                HapticFeedback.createImpact(style: .light)
                
                showIndicator()
                
                UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    sender.setImage(nil, for: .normal)
                }, completion: nil)
                
                EventService.createBookmark(eventID: eventID).done { _ in
                    self.hideIndicator()
                    
                    UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        sender.setImage(bookmarkedImg, for: .normal)
                    }, completion: nil)
                    print("Event(\(self.eventID)) bookmarked")
                    sender.isUserInteractionEnabled = true
                    self.bookmarkBtnNewState = true
                    }.ensure {
                        self.didChangeBookmarkBtnState = self.bookmarkBtnInitialState == self.bookmarkBtnNewState ? false : true
                        HapticFeedback.createNotificationFeedback(style: .success)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }.catch { error in }
                
            } else { //remove bookmark
                HapticFeedback.createImpact(style: .light)
                
                showIndicator()
                
                UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    sender.setImage(nil, for: .normal)
                }, completion: nil)
                
                EventService.removeBookmark(eventID: eventID).done { _ in
                    self.hideIndicator()
                    
                    UIView.transition(with: sender, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        sender.setImage(notBookmarkedImg, for: .normal)
                    }, completion: nil)
                    print("Event(\(self.eventID)) bookmark removed")
                    sender.isUserInteractionEnabled = true
                    self.bookmarkBtnNewState = false
                    }.ensure {
                        self.didChangeBookmarkBtnState = self.bookmarkBtnInitialState == self.bookmarkBtnNewState ? false : true
                        HapticFeedback.createNotificationFeedback(style: .success)
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    }.catch { error in }
            }
            
        } else { // not logged in action
            print("not logged in")
        }
    }
    
    func imageCellTapped(index: Int, displacementItem: UIImageView) {
        showImageViewer(atIndex: index)
        displaceableImgView = displacementItem
    }
    
    func performerLabelTapped(sender: Any) {
        if !isModal {
            BuskerProfileViewController.push(from: self, buskerName: eventDetails!.item?.organizerProfile?.name ?? "", buskerID: eventDetails!.item?.organizerProfile?.id ?? "")
        } else {
            BuskerProfileViewController.present(from: self, buskerName: eventDetails!.item?.organizerProfile?.name ?? "", buskerID: eventDetails!.item?.organizerProfile?.id ?? "")
        }
    }
}

//MARK: ImageViewer Section (i.e. present image viewer when imgCollectionView cell is tapped)
extension EventDetailsViewController {
    func showImageViewer(atIndex: Int) {
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let footerView = CounterView(frame: frame, currentIndex: atIndex, count: imgViewerItems.count)
        
        let galleryViewController = GalleryViewController(startIndex: atIndex, itemsDataSource: self, displacedViewsDataSource: self, configuration: ImageViewerHelper.config())
        //galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        galleryViewController.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT INDEX: \(index)")
            
            footerView.count = self.imgViewerItems.count
            footerView.currentIndex = index
        }
        
        self.presentImageGallery(galleryViewController)
    }
}

//MARK: (ImageViewer) Extend UIImageView to subclass displaceableview
extension UIImageView: DisplaceableView {}

//MARK: Image viewer data source
extension EventDetailsViewController: GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        //print(index)
        return index < imgViewerItems.count ? displaceableImgView : nil
    }
}

extension EventDetailsViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return imgViewerItems.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return imgViewerItems[index].galleryItem
    }
}

//MARK: Floating Button Delegate
extension EventDetailsViewController: FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        print("Floaty Will Open")
    }
    
    func floatyDidOpen(_ floaty: Floaty) {
        print("Floaty Did Open")
    }
    
    func floatyWillClose(_ floaty: Floaty) {
        print("Floaty Will Close")
    }
    
    func floatyDidClose(_ floaty: Floaty) {
        print("Floaty Did Close")
    }
}


//MARK: swipe pop gesture
extension EventDetailsViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: function to push this view controller
extension EventDetailsViewController {
    static func push(from view: UIViewController, eventID: String, isFromBookmarkedSection: Bool? = nil) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: EventDetailsViewController.storyboardID) as! EventDetailsViewController
        
        detailsVC.eventID = eventID
        
        if let isFromBookmarkedSection = isFromBookmarkedSection {
            detailsVC.isFromBookmarkedSection = isFromBookmarkedSection
        }
        
        view.navigationItem.title = ""
        view.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .zoom)
        view.navigationController?.pushViewController(detailsVC, animated: true)
    }
    
    static func present(from view: UIViewController, eventID: String, isFromBookmarkedSection: Bool? = nil) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: EventDetailsViewController.storyboardID) as! EventDetailsViewController
        
        detailsVC.eventID = eventID
        
        detailsVC.hero.isEnabled = true
        detailsVC.hero.modalAnimationType = .autoReverse(presenting: .zoom)
        view.present(detailsVC, animated: true, completion: nil)
    }
}
