//
//  BuskerProfileViewController.swift
//  major-7-ios
//
//  Created by jason on 27/2/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import AVKit
import PIPKit
import XCDYouTubeKit
import CHIPageControl
import BouncyLayout
import Pastel
import SkeletonView
import NVActivityIndicatorView
import InfiniteLayout

//MARK: isFollowingBusker Enum
enum isFollowingBusker {
    case Yes
    case No
}

class BuskerProfileViewController: UIViewController {
    static let storyboardID = "buskerProfileVC"
    
    var buskerName = ""
    
    var buskerID = "" {
        didSet {
            checkIsFollowing(buskerID: buskerID)
            getProfileDetails(buskerID: buskerID)
            getBuskerFollowings(buskerID: buskerID)
            getBuskerEvents(buskerID: buskerID)
            getBuskerPosts(buskerID: buskerID)
        }
    }
    
    var buskerDetails: BuskerProfile? {
        didSet {
            imgCollectionView.infiniteLayout.isEnabled = (buskerDetails?.item?.coverImages.count)! > 1
            loadProfileDetails()
        }
    }
    
    var hashtagsArray = [String]()
    
    var buskerEvents: BuskerEventsList?
    
    var buskerPosts: BuskerPostsList?
    
    //gesture for swipe-pop
    var gesture: UIGestureRecognizer?
    
    var followBtnLoadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
    var statsLoadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
    var profileLoadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var imgContainerView = UIView()
    var imgCollectionView: InfiniteCollectionView!
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let imgCollectionViewHeight: CGFloat = (UIScreen.main.bounds.height / 5) * 2
    let imgOverlay = UIView()
    
    let pageControl = CHIPageControlJaloro(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
    
    var buskerTaglineLabel = UILabel()
    var buskerLabel = UILabel()
    
    var verifiedBg = UIView()
    var verifiedIcon = UIImageView()
    var verifiedText = UIImageView()
    
    var hashtagsCollectionView: UICollectionView!
    var hashtagsCollecitonViewHeightWithTopPadding: CGFloat = 43
    
    var followBtn = UIButton()
    var isFollowing = isFollowingBusker.No //default no
    var btnHeightWithTopPadding: CGFloat = 60
    
    //stats section
    var statsBgView = UIView()
    var statsGradientBg = PastelView()
    var statsFollowersCount = UILabel()
    var statsFollowersLabel = UILabel()
    var statsPostsCount = UILabel()
    var statsPostsLabel = UILabel()
    var statsEventsCount = UILabel()
    var statsEventsLabel = UILabel()
    var statsSectionHeightWithTopPadding: CGFloat = 100
    
    //profile section
    var profileBgView = UIView()
    var profileLineView = UIView()
    var profileLabel = UILabel()
    var profileDesc = UITextView()
    var profileBgViewHeight: CGFloat = 0
    var descString = ""

    //members section
    var membersBgView = UIView()
    var membersLabel = UILabel()
    var membersLineView = UIView()
    var membersCollectionView: UICollectionView!
    var membersSectionHeightWithTopPadding: CGFloat = 213
   
    //live/works section
    var liveBgView = UIView()
    var liveLabel = UILabel()
    var liveLineView = UIView()
    var liveCollectionView: UICollectionView!
    var liveSectionHeightWithTopPadding: CGFloat = 140
    
    //events section
    var eventsBgView = UIView()
    var eventsLabel = UILabel()
    var eventsLineView = UIView()
    var eventsCollectionView: UICollectionView!
    var eventsSectionHeightWithTopPadding: CGFloat = 294
    
    //posts section
    var postsBgView = UIView()
    var postsLabel = UILabel()
    var postsLineView = UIView()
    var postsCollectionView: UICollectionView!
    var postsSectionHeightWithTopPadding: CGFloat = 520
    
    //footer section
    var copyrightLabel = UILabel()
    var sepLine = UIView()
    var footerSectionHeight: CGFloat = 86
    
    //views to show later array
    var viewsToShowLater = [UIView]()
    var delayedViewsToShowLater = [UIView]()
    
    let animation = SkeletonAnimationBuilder().makeSlidingAnimation(withDirection: .leftRight, duration: 2)
    
    //MARK: — Status Bar Appearance
    private var previousStatusBarHidden = false
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        //** We use the slide animation because it works well with scrolling
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return shouldHideStatusBar
    }
    
    private var shouldHideStatusBar: Bool {
        //** Here’s where we calculate if our text container
        // is going to hit the top safe area
        //let frame = buskerTaglineLabel.convert(buskerTaglineLabel.bounds, to: nil)
        return imgCollectionViewHeight / 2 < view.safeAreaInsets.top
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gesture?.delegate = self
        
        updatesStatusBarAppearanceAutomatically = true
        view.backgroundColor = .m7DarkGray()
        
        setupImgCollectionView()
        setupOverlay()
        setupBuskerLabels()
        setupPageControl()
        setupHashtagsCollectionView()
        
        setupFollowBtn()
        
        setupStatsView()
        setupProfileSection()
        setupMembersSection()
        setupPerformancesSection()
        setupEventsSection()
        setupPostSection()
        
        setupFooter()
        
        setupLeftBarItems()
        
        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        followBtnLoadingIndicator.startAnimating()
        statsLoadingIndicator.startAnimating()
        profileLoadingIndicator.startAnimating()
        
        if !isModal {
            TabBar.hide(from: self)
        } else {
            setupCloseBtn()
        }
        //TabBar.hide(from: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !isModal { TabBar.show(from: self) }
        //TabBar.show(from: self)
    }
    
}

//MARK: - API Calling
extension BuskerProfileViewController {
    private func getProfileDetails(buskerID: String) {
        BuskerService.getProfileDetails(buskerID: buskerID).done { details -> () in
            self.buskerDetails = details
            
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func checkIsFollowing(buskerID: String) {
        UserService.getUserFollowings().done { response -> () in
            if !response.list.isEmpty {
                for object in response.list {
                    if object.targetProfile?.id == self.buskerID {
                        self.isFollowing = .Yes
                        self.followBtn.backgroundColor = .mintGreen()
                        self.followBtn.setTitle("Following", for: .normal)
                        
                        UIView.animate(withDuration: 0.3, animations: {
                            self.followBtnLoadingIndicator.alpha = 0
                        })
                    }
                }
            }
            }.ensure {
                if self.isFollowing == .No {
                    self.followBtn.setTitle("Follow", for: .normal)
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        self.followBtnLoadingIndicator.alpha = 0
                    })
                }
                self.followBtn.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }

    private func getBuskerFollowings(buskerID: String) {
        BuskerService.getBuskerFollowings(buskerID: buskerID).done { response -> () in
                self.statsFollowersCount.text = "\(response.list.count)"
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func getBuskerEvents(buskerID: String) {
        BuskerService.getBuskerEvents(buskerID: buskerID).done { events -> () in
            if !events.list.isEmpty {
                self.buskerEvents = events
                self.eventsCollectionView.reloadData()
            } else {
                self.eventsCollectionView.alpha = 0
                let emptyLabel = UILabel()
                emptyLabel.text = "No Events"
                emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                emptyLabel.textColor = .darkGray
                self.eventsBgView.addSubview(emptyLabel)
                emptyLabel.snp.makeConstraints({ (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(15)
                })
                self.eventsSectionHeightWithTopPadding = 120
                
                self.eventsBgView.snp.updateConstraints({ (make) in
                    make.height.equalTo(100)
                })
            }
            self.statsEventsCount.text = String(describing: events.list.count)
            self.eventsLabel.text = "Events (\(events.list.count))"
            
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func getBuskerPosts(buskerID: String) {
        BuskerService.getBuskerPosts(buskerID: buskerID).done { posts -> () in
            if !posts.list.isEmpty {
                self.buskerPosts = posts
                self.postsCollectionView.reloadData()
            } else {
                self.postsCollectionView.alpha = 0
                let emptyLabel = UILabel()
                emptyLabel.text = "No Posts"
                emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
                emptyLabel.textColor = .darkGray
                self.postsBgView.addSubview(emptyLabel)
                emptyLabel.snp.makeConstraints({ (make) in
                    make.centerX.equalToSuperview()
                    make.centerY.equalToSuperview().offset(15)
                })
                self.postsSectionHeightWithTopPadding = 120
                
                self.postsBgView.snp.updateConstraints({ (make) in
                    make.height.equalTo(100)
                })
            }
            self.statsPostsCount.text = String(describing: posts.list.count)
            self.postsLabel.text = "Posts (\(posts.list.count))"
            
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func loadProfileDetails() {
        if let details = buskerDetails {
            if let profile = details.item {
                //load images
                imgCollectionView.reloadData()
                
                //setup img page control
                pageControl.numberOfPages = profile.coverImages.count
                
                //tagline
                buskerTaglineLabel.text = profile.tagline
                
                //verified state
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    UIView.animate(withDuration: 0.3) {
                        self.verifiedBg.alpha = profile.verified ?? true ? 1 : 0
                    }
                }

                //hashtags
                hashtagsCollectionView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(28)
                }
                for genre in profile.genres { hashtagsArray.append(genre) }
                for hashtag in profile.hashtags { hashtagsArray.append(hashtag) }
                hashtagsCollectionView.reloadData()
                
                //stats TODO
                
                //busker description
                descString = profile.desc!
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 8
                //paragraphStyle.lineBreakMode = .byTruncatingTail
                
                let myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.whiteText(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
                
                // create attributed string
                let descAttrString = NSAttributedString(string: descString, attributes: myAttribute)
                
                //set attributed text to UITextView
                profileDesc.alpha = 0
                profileDesc.backgroundColor = .clear
                profileDesc.isEditable = false
                profileDesc.isSelectable = false
                profileDesc.attributedText = descAttrString
                profileDesc.isScrollEnabled = false
                profileDesc.sizeToFit()
                profileDesc.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                profileBgView.addSubview(profileDesc)
                profileDesc.snp.makeConstraints { (make) -> Void in
                    make.top.equalTo(profileLineView.snp.bottom).offset(16)
                    make.left.equalToSuperview().offset(20)
                    make.right.equalToSuperview().offset(-20)
                }
                profileDesc.layoutIfNeeded()
                viewsToShowLater.append(profileDesc)
                
                let sizeThatFitsTextView = profileDesc.sizeThatFits(CGSize(width: profileDesc.frame.size.width, height: CGFloat(MAXFLOAT)))
                let heightOfText = sizeThatFitsTextView.height
                profileBgViewHeight = heightOfText + 54 + 20 ///textHeight + topPadding(including "Profile" label) + bottomPadding
                
                profileBgView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(profileBgViewHeight)
                }
                
                //show desc edit button
                if details.requestUserIsAdmin ?? false {
                    self.setupRightBarItems()
                }
                
                //members section
                if !profile.members.isEmpty {
                    membersLabel.text = "Members (\(profile.members.count))"
                    membersCollectionView.reloadData()
                } else {
                    membersBgView.removeFromSuperview()
                    membersLabel.removeFromSuperview()
                    membersLineView.removeFromSuperview()
                    membersCollectionView.removeFromSuperview()
                    liveBgView.snp.remakeConstraints { make in
                        make.top.equalTo(profileBgView.snp.bottom).offset(20)
                        make.centerX.equalToSuperview()
                        make.width.equalTo(screenWidth - 40)
                        make.height.equalTo(120)
                    }
                }
                
                profileLoadingIndicator.alpha = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    for view in self.delayedViewsToShowLater {
                        UIView.animate(withDuration: 0.3) {
                            self.statsLoadingIndicator.alpha = 0

                            view.alpha = 1
                        }
                    }
                }
                
                //adjust mainScrollView height on different screen size
                /**  height =    imgCollectionViewHeight + hashtagsCollecitonViewHeight (with top padding) +
                                actionBtnHeight (with top padding) + statsHeight (with top padding) +
                                profileHeight (with top padding) + membersSectionHeight (with top padding) +
                                liveHeight (with top padding) + eventsHeight (with top padding) +
                                postsHeight (with top padding) + footerHeight (with top padding) + bottom padding   */
                if UIDevice.current.hasHomeButton {
                    if profile.members.isEmpty {
                        let height = imgCollectionViewHeight + hashtagsCollecitonViewHeightWithTopPadding + btnHeightWithTopPadding + statsSectionHeightWithTopPadding + (profileBgViewHeight + 20) + liveSectionHeightWithTopPadding + eventsSectionHeightWithTopPadding + postsSectionHeightWithTopPadding + footerSectionHeight
                        mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
                    } else {
                        let height = imgCollectionViewHeight + hashtagsCollecitonViewHeightWithTopPadding + btnHeightWithTopPadding + statsSectionHeightWithTopPadding + (profileBgViewHeight + 20) + membersSectionHeightWithTopPadding + liveSectionHeightWithTopPadding + eventsSectionHeightWithTopPadding + postsSectionHeightWithTopPadding + footerSectionHeight
                        mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
                    }
                } else { //add extra 20 padding if device is iPhone X/XR/XS/XS Max
                    if profile.members.isEmpty {
                        let height = imgCollectionViewHeight + hashtagsCollecitonViewHeightWithTopPadding + btnHeightWithTopPadding + statsSectionHeightWithTopPadding + (profileBgViewHeight + 20) + liveSectionHeightWithTopPadding + eventsSectionHeightWithTopPadding + postsSectionHeightWithTopPadding + footerSectionHeight + 20
                        mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
                    } else {
                        let height = imgCollectionViewHeight + hashtagsCollecitonViewHeightWithTopPadding + btnHeightWithTopPadding + statsSectionHeightWithTopPadding + (profileBgViewHeight + 20) + membersSectionHeightWithTopPadding + liveSectionHeightWithTopPadding + eventsSectionHeightWithTopPadding + postsSectionHeightWithTopPadding + footerSectionHeight + 20
                        mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
                    }
                }
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                
                for view in viewsToShowLater {
                    UIView.animate(withDuration: 0.3) {
                        view.alpha = 1
                    }
                }
            }
        }
    }
}

//MARK: - UI related
extension BuskerProfileViewController {
    private func setupImgCollectionView() {

        //image collection view
        let layout: UICollectionViewFlowLayout = PagedCollectionViewLayout()
        layout.itemSize = CGSize(width: screenWidth, height: imgCollectionViewHeight)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        imgCollectionView = InfiniteCollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: imgCollectionViewHeight)), collectionViewLayout: layout)
        imgCollectionView.backgroundColor = .m7DarkGray()
        imgCollectionView.isItemPagingEnabled = true
        imgCollectionView.dataSource = self
        imgCollectionView.delegate = self
        imgCollectionView.showsHorizontalScrollIndicator = false
        imgCollectionView.register(UINib.init(nibName: "BuskerProfileImgCell", bundle: nil), forCellWithReuseIdentifier: BuskerProfileImgCell.reuseIdentifier)
        
        let imgOverlay = ImageOverlayRevert()
        imgCollectionView.addSubview(imgOverlay)
        imgOverlay.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.width.equalTo(screenWidth)
            make.height.equalTo(100)
        }
        
//        imgContainerView.backgroundColor = .darkGray
//        mainScrollView.addSubview(imgContainerView)
//        imgContainerView.snp.makeConstraints { (make) -> Void in
//            make.top.equalToSuperview()
//            make.width.equalTo(screenWidth)
//            make.height.equalTo(imgCollectionViewHeight)
//        }
        
        mainScrollView.addSubview(imgCollectionView)
//        imgCollectionView.snp.makeConstraints { (make) -> Void in
//            make.top.equalTo(view)
//            make.width.equalTo(screenWidth)
//            make.height.equalTo(imgCollectionViewHeight)
//            make.bottom.equalTo(imgContainerView.snp.bottom)
//        }
        
    }
    
    private func setupOverlay() {
        imgOverlay.isUserInteractionEnabled = false
        imgOverlay.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: imgCollectionViewHeight))
        imgOverlay.backgroundColor = .clear
        imgOverlay.layer.insertSublayer(GradientLayer.create(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: (imgCollectionViewHeight / 3) * 2)), colors: [.m7DarkGray(), .clear], startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0)), at: 0)
        mainScrollView.insertSubview(imgOverlay, aboveSubview: imgCollectionView)
        imgOverlay.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(imgCollectionView.snp.top).offset(imgCollectionViewHeight / 3)
            //make.size.equalTo(imgCollectionView)
        }
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
    
    @objc private func popView() {
        navigationController?.hero.navigationAnimationType = .zoomOut
        navigationController?.popViewController(animated: true)
    }
    
    private func setupRightBarItems() {
        let customView = UIView(frame: CGRect(x: 15, y: 10, width: 30, height: 30))
        customView.backgroundColor = .clear
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        menuBtn.setImage(UIImage(named: "icon_edit"), for: .normal)
        menuBtn.addTarget(self, action: #selector(presentEditView), for: .touchUpInside)
        customView.addSubview(menuBtn)
        
        customView.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(30)
        }
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        self.navigationItem.rightBarButtonItem = menuBarItem
    }
    
    @objc private func presentEditView() {
        BuskerProfileEditViewController.present(from: self, buskerName: "", buskerID: "")
    }
    
    private func setupCloseBtn() {
        let closeBtn = UIButton()
        closeBtn.setImage(UIImage(named: "icon_close"), for: .normal)
        closeBtn.setTitle("", for: .normal)
        closeBtn.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        mainScrollView.addSubview(closeBtn)
        mainScrollView.bringSubviewToFront(closeBtn)
        closeBtn.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(30)
            make.left.equalTo(20)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupBuskerLabels() {
        buskerLabel.textAlignment = .left
        buskerLabel.numberOfLines = 1
        buskerLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        buskerLabel.textColor = .white
        buskerLabel.text = buskerName.isEmpty ? "(Error)" : buskerName
        mainScrollView.insertSubview(buskerLabel, aboveSubview: imgOverlay)
        buskerLabel.snp.makeConstraints { (make) -> Void in
            //make.width.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(imgCollectionView.snp.bottom)
        }
        
        buskerTaglineLabel.alpha = 0
        buskerTaglineLabel.textAlignment = .left
        buskerTaglineLabel.numberOfLines = 1
        buskerTaglineLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        buskerTaglineLabel.textColor = .lightGrayText()
        mainScrollView.insertSubview(buskerTaglineLabel, aboveSubview: imgOverlay)
        buskerTaglineLabel.snp.makeConstraints { (make) -> Void in
            //make.width.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.width.equalTo(UIScreen.main.bounds.width - 40)
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(buskerLabel.snp.top).offset(-5)
        }
        viewsToShowLater.append(buskerTaglineLabel)
        
        verifiedIcon.image = UIImage(named: "icon_verified")
        verifiedBg.addSubview(verifiedIcon)
        verifiedIcon.snp.makeConstraints { (make) in
            make.size.equalTo(18)
            make.centerY.equalToSuperview()
            make.left.equalTo(5)
        }

        verifiedText.image = UIImage(named: "icon_verified_text")
        verifiedBg.addSubview(verifiedText)
        verifiedText.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.width.equalTo(51)
            make.height.equalTo(11)
            make.left.equalTo(verifiedIcon.snp.right).offset(6)
        }
        
        verifiedBg.alpha = 0
        verifiedBg.layer.cornerRadius = 14
        verifiedBg.backgroundColor = UIColor(hexString: "#6aab39")
        mainScrollView.insertSubview(verifiedBg, aboveSubview: imgOverlay)
        verifiedBg.snp.makeConstraints { (make) in
            make.centerY.equalTo(buskerLabel)
            make.width.equalTo(86)
            make.height.equalTo(28)
            make.left.equalTo(buskerLabel.snp.right).offset(6)
        }
    }
    
    private func setupPageControl() {
        pageControl.alpha = 0
        pageControl.numberOfPages = 4
        pageControl.radius = 2
        pageControl.tintColor = .lightGrayText()
        pageControl.currentPageTintColor = .lightGrayText()
        pageControl.padding = 6
        mainScrollView.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) -> Void in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(buskerTaglineLabel.snp.top).offset(-12)
        }
        viewsToShowLater.append(pageControl)
    }
    
    private func setupHashtagsCollectionView() {
        let layout: UICollectionViewFlowLayout = HashtagsFlowLayout()
        layout.scrollDirection = .horizontal
        
        hashtagsCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: 28)), collectionViewLayout: layout)
        hashtagsCollectionView.backgroundColor = .m7DarkGray()
        hashtagsCollectionView.collectionViewLayout = layout
        hashtagsCollectionView.dataSource = self
        hashtagsCollectionView.delegate = self
        hashtagsCollectionView.showsHorizontalScrollIndicator = false
        hashtagsCollectionView.register(UINib.init(nibName: "HashtagCell", bundle: nil), forCellWithReuseIdentifier: HashtagCell.reuseIdentifier)
        mainScrollView.addSubview(hashtagsCollectionView)
        hashtagsCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(buskerLabel.snp.bottom).offset(15)
            make.width.equalTo(screenWidth)
            make.height.equalTo(0)
        }
    }
    
    private func setupFollowBtn() {
        followBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        followBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        followBtn.setTitleColor(.white, for: .normal)
        followBtn.layer.cornerRadius = GlobalCornerRadius.value
        
        if UserService.User.isLoggedIn() {
            followBtn.isUserInteractionEnabled = false
            followBtn.addTarget(self, action: #selector(didTapFollowBtn), for: .touchUpInside)
            followBtn.addSubview(followBtnLoadingIndicator)
            followBtnLoadingIndicator.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        } else {
            followBtn.addTarget(self, action: #selector(showLoginView), for: .touchUpInside)
        }
        
        mainScrollView.addSubview(followBtn)
        followBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(40)
            make.top.equalTo(hashtagsCollectionView.snp.bottom).offset(20)
        }
    }
    
    @objc private func didTapFollowBtn(_ sender: UIButton) {
        if UserService.User.isLoggedIn() {
            self.followBtn.setTitle("", for: .normal)
            UIView.animate(withDuration: 0.2) {
                self.followBtnLoadingIndicator.alpha = 1
            }
            self.followBtn.isUserInteractionEnabled = false
            
            switch isFollowing {
            case .Yes:
                BuskerService.unfollowBusker(buskerID: buskerID).done { _ in
                    print("Busker with ID (\(self.buskerID)) unfollowed")
                    UIView.transition(with: self.followBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.followBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
                    }, completion: nil)
                    self.followBtn.setTitle("Follow", for: .normal)
                    }.ensure {
                        self.isFollowing = .No
                        self.followBtn.isUserInteractionEnabled = true
                        
                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        HapticFeedback.createNotificationFeedback(style: .success)
                        Animations.btnBounce(sender: sender)
                        UIView.animate(withDuration: 0.2) {
                            self.followBtnLoadingIndicator.alpha = 0
                        }
                    }.catch { error in }
                
            case .No:
                BuskerService.followBusker(buskerID: buskerID).done { _ in
                    print("Busker with ID (\(self.buskerID)) followed")
                    UIView.transition(with: self.followBtn, duration: 0.2, options: .transitionCrossDissolve, animations: {
                        self.followBtn.backgroundColor = .mintGreen()
                    }, completion: nil)
                    self.followBtn.setTitle("Following", for: .normal)
                    }.ensure {
                        self.isFollowing = .Yes
                        self.followBtn.isUserInteractionEnabled = true

                        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                        HapticFeedback.createNotificationFeedback(style: .success)
                        Animations.btnBounce(sender: sender)
                        UIView.animate(withDuration: 0.2) {
                            self.followBtnLoadingIndicator.alpha = 0
                        }
                    }.catch { error in }
            }
        } else {
            showLoginView()
        }
    }
    
    @objc private func showLoginView() {
        let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        self.present(loginVC, animated: true, completion: nil)
    }
    
    private func setupStatsView() {
        statsBgView.layer.cornerRadius = GlobalCornerRadius.value
        statsBgView.clipsToBounds = true
        statsBgView.backgroundColor = .darkGray
        
        statsGradientBg.frame = CGRect(x: 0, y: 0, width: screenWidth - 40, height: 80)
        statsGradientBg.animationDuration = 2.5
        statsGradientBg.setColors([UIColor(hexString:"#3c1053"), UIColor(hexString:"#c94b4b")])
        statsGradientBg.startAnimation()
        
        statsBgView.insertSubview(statsGradientBg, at: 0)
        statsBgView.addSubview(statsLoadingIndicator)
        statsLoadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        mainScrollView.addSubview(statsBgView)
        statsBgView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(followBtn.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(80)
        }
        
        statsFollowersCount.alpha = 0
        statsFollowersCount.textColor = .white
        statsFollowersCount.text = "0"
        statsFollowersCount.textAlignment = .center
        statsFollowersCount.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        statsBgView.addSubview(statsFollowersCount)
        statsFollowersCount.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(10)
            make.centerY.equalToSuperview().offset(-10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.height.equalTo(24)
        }
        delayedViewsToShowLater.append(statsFollowersCount)
        
        statsFollowersLabel.alpha = 0
        statsFollowersLabel.textColor = .lightGray
        statsFollowersLabel.text = "Followers"
        statsFollowersLabel.textAlignment = .center
        statsFollowersLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        statsBgView.addSubview(statsFollowersLabel)
        statsFollowersLabel.snp.makeConstraints { (make) -> Void in
            make.left.equalTo(10)
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.height.equalTo(12)
        }
        delayedViewsToShowLater.append(statsFollowersLabel)
        
        statsPostsCount.alpha = 0
        statsPostsCount.textColor = .white
        statsPostsCount.text = "0"
        statsPostsCount.textAlignment = .center
        statsPostsCount.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        statsBgView.addSubview(statsPostsCount)
        statsPostsCount.snp.makeConstraints { (make) -> Void in
            make.width.equalTo((screenWidth - 40) / 3)
            make.centerY.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        delayedViewsToShowLater.append(statsPostsCount)

        statsPostsLabel.alpha = 0
        statsPostsLabel.textColor = .lightGray
        statsPostsLabel.text = "Posts"
        statsPostsLabel.textAlignment = .center
        statsPostsLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        statsBgView.addSubview(statsPostsLabel)
        statsPostsLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo((screenWidth - 40) / 3)
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(12)
        }
        delayedViewsToShowLater.append(statsPostsLabel)

        statsEventsCount.alpha = 0
        statsEventsCount.textColor = .white
        statsEventsCount.text = "0"
        statsEventsCount.textAlignment = .center
        statsEventsCount.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        statsBgView.addSubview(statsEventsCount)
        statsEventsCount.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(-10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.centerY.equalToSuperview().offset(-10)
            make.height.equalTo(24)
        }
        delayedViewsToShowLater.append(statsEventsCount)

        statsEventsLabel.alpha = 0
        statsEventsLabel.textColor = .lightGray
        statsEventsLabel.text = "Events"
        statsEventsLabel.textAlignment = .center
        statsEventsLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        statsBgView.addSubview(statsEventsLabel)
        statsEventsLabel.snp.makeConstraints { (make) -> Void in
            make.right.equalTo(-10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.centerY.equalToSuperview().offset(10)
            make.height.equalTo(12)
        }
        delayedViewsToShowLater.append(statsEventsLabel)
        
    }
}

//MARK: - Profile section
extension BuskerProfileViewController {
    private func setupProfileSection() {
        profileBgView.layer.cornerRadius = GlobalCornerRadius.value
        profileBgView.clipsToBounds = true
        profileBgView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        mainScrollView.addSubview(profileBgView)
        profileBgView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(statsBgView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(110)
        }
        
        profileBgView.addSubview(profileLoadingIndicator)
        profileLoadingIndicator.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
        }
        
        profileLineView.isUserInteractionEnabled = false
        profileLineView.backgroundColor = .mintGreen()
        profileLineView.layer.cornerRadius = 2
        profileBgView.addSubview(profileLineView)
        profileLineView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        
        profileLabel.textColor = .white
        profileLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        profileLabel.text = "Profile"
        profileBgView.addSubview(profileLabel)
        profileLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(profileLineView.snp.right).offset(10)
            make.height.equalTo(25)
        }
    }
    
    @objc func editDesc() {
        //TODO
    }
}

//MARK: - Members Section
extension BuskerProfileViewController {
    private func setupMembersSection() {
        membersBgView.layer.cornerRadius = GlobalCornerRadius.value
        membersBgView.clipsToBounds = true
        membersBgView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        mainScrollView.addSubview(membersBgView)
        membersBgView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(profileBgView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(193)
        }
        
        membersLineView.backgroundColor = .orange
        membersLineView.layer.cornerRadius = 2
        membersBgView.addSubview(membersLineView)
        membersLineView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        
        membersLabel.textColor = .white
        membersLabel.text = "Members"
        membersLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        membersBgView.addSubview(membersLabel)
        membersLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(membersLineView.snp.right).offset(10)
            make.width.equalTo(300)
            make.height.equalTo(25)
        }
        
        setupMembersCollectionView()
    }
    
    private func setupMembersCollectionView() {
        let layout: UICollectionViewFlowLayout = BouncyLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        
        membersCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth - 40, height: 120)), collectionViewLayout: layout)
        membersCollectionView.backgroundColor = .clear
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        membersCollectionView.showsHorizontalScrollIndicator = false
        membersCollectionView.register(UINib.init(nibName: "BuskerProfileMemberCell", bundle: nil), forCellWithReuseIdentifier: BuskerProfileMemberCell.reuseIdentifier)
        membersBgView.addSubview(membersCollectionView)
        membersCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(membersLineView.snp.bottom).offset(16)
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(120)
        }
    }
}

//MARK: - Perfomrnace/Songs section
extension BuskerProfileViewController {
    private func setupPerformancesSection() {
        liveBgView.layer.cornerRadius = GlobalCornerRadius.value
        liveBgView.clipsToBounds = true
        liveBgView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        mainScrollView.addSubview(liveBgView)
        liveBgView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(membersBgView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(120)
        }
        
        liveLineView.backgroundColor = .yellow
        liveLineView.layer.cornerRadius = 2
        liveBgView.addSubview(liveLineView)
        liveLineView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        
        liveLabel.textColor = .white
        liveLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        liveLabel.text = "Live Performances"
        liveBgView.addSubview(liveLabel)
        liveLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(liveLineView.snp.right).offset(10)
            make.width.equalTo(300)
            make.height.equalTo(25)
        }
        
//        let btn = VidButton()
//        btn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
//        btn.setTitle("TEST", for: .normal)
//        btn.setTitleColor(.white, for: .normal)
//        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
//        btn.layer.cornerRadius = GlobalCornerRadius.value / 2
//        btn.videoIdentifier = "NdLZ76bYNy8"
//        btn.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
//        liveBgView.addSubview(btn)
//        btn.snp.makeConstraints { (make) -> Void in
//            make.bottom.equalToSuperview().offset(-20)
//            make.width.equalTo(screenWidth - 80)
//            make.height.equalTo(40)
//            make.centerX.equalToSuperview()
//        }
        
        let emptyLabel = UILabel()
        emptyLabel.text = "Coming Soon"
        emptyLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        emptyLabel.textColor = .darkGray
        liveBgView.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints({ (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(15)
        })
    }
    
    struct YouTubeVideoQuality {
        static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
        static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
        static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
    }
    
    @objc func playVideo(_ sender: VidButton) {
        let playerViewController = VideoView()
        PIPKit.show(with: playerViewController)

        //self.present(playerViewController, animated: true, completion: nil)
        
        XCDYouTubeClient.default().getVideoWithIdentifier(sender.videoIdentifier) { [weak playerViewController] (video: XCDYouTubeVideo?, error: Error?) in
            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                playerViewController?.player = AVPlayer(url: streamURL)
                playerViewController?.player?.play()
            } else {
                PIPKit.dismiss(animated: true)
            }
        }
    }
    
}

//MARK: - Events Section
extension BuskerProfileViewController {
    private func setupEventsSection() {
        eventsBgView.layer.cornerRadius = GlobalCornerRadius.value
        eventsBgView.clipsToBounds = true
        eventsBgView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        mainScrollView.addSubview(eventsBgView)
        eventsBgView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(liveBgView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(274)
        }
        
        eventsLineView.backgroundColor = .purple
        eventsLineView.layer.cornerRadius = 2
        eventsBgView.addSubview(eventsLineView)
        eventsLineView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        
        eventsLabel.textColor = .white
        eventsLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        eventsLabel.text = "Events"
        eventsBgView.addSubview(eventsLabel)
        eventsLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(eventsLineView.snp.right).offset(10)
            make.width.equalTo(300)
            make.height.equalTo(25)
        }
        
        setupEventsCollectionView()
    }
    
    private func setupEventsCollectionView() {
        let layout: UICollectionViewFlowLayout = PagedCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: BuskerProfileEventCell.width, height: BuskerProfileEventCell.height)
        layout.minimumLineSpacing = 10
        
        eventsCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth - 40, height: BuskerProfileEventCell.height)), collectionViewLayout: layout)
        eventsCollectionView.backgroundColor = .clear
        eventsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        eventsCollectionView.dataSource = self
        eventsCollectionView.delegate = self
        eventsCollectionView.showsHorizontalScrollIndicator = false
        eventsCollectionView.register(UINib.init(nibName: "BuskerProfileEventCell", bundle: nil), forCellWithReuseIdentifier: BuskerProfileEventCell.reuseIdentifier)
        eventsBgView.addSubview(eventsCollectionView)
        eventsCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(eventsLineView.snp.bottom).offset(16)
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(BuskerProfileEventCell.height)
        }
    }
}

//MARK: - Posts Section
extension BuskerProfileViewController {
    private func setupPostSection() {
        postsBgView.layer.cornerRadius = GlobalCornerRadius.value
        postsBgView.clipsToBounds = true
        postsBgView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        mainScrollView.addSubview(postsBgView)
        postsBgView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(eventsBgView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(500)
        }
        
        postsLineView.backgroundColor = .blue
        postsLineView.layer.cornerRadius = 2
        postsBgView.addSubview(postsLineView)
        postsLineView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        
        postsLabel.textColor = .white
        postsLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        postsLabel.text = "Posts"
        postsBgView.addSubview(postsLabel)
        postsLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.left.equalTo(postsLineView.snp.right).offset(10)
            make.width.equalTo(500)
            make.height.equalTo(25)
        }
        
        setupPostsCollectionView()
    }
    
    private func setupPostsCollectionView() {
        let layout: UICollectionViewFlowLayout = PagedCollectionViewLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: BuskerProfilePostCell.width, height: BuskerProfilePostCell.height)
        layout.minimumLineSpacing = 10
        
        postsCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth - 40, height: BuskerProfilePostCell.height)), collectionViewLayout: layout)
        postsCollectionView.backgroundColor = .clear
        postsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        postsCollectionView.dataSource = self
        postsCollectionView.delegate = self
        postsCollectionView.showsHorizontalScrollIndicator = false
        postsCollectionView.register(UINib.init(nibName: "BuskerProfilePostCell", bundle: nil), forCellWithReuseIdentifier: BuskerProfilePostCell.reuseIdentifier)
        postsBgView.addSubview(postsCollectionView)
        postsCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(postsLineView.snp.bottom).offset(16)
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(BuskerProfilePostCell.height)
        }
    }
}

//MARK: - Footer Section
extension BuskerProfileViewController {
    private func setupFooter() {
        sepLine.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        sepLine.layer.cornerRadius = 0.2
        mainScrollView.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.top.equalTo(postsBgView.snp.bottom).offset(20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(2)
        }
        
        copyrightLabel.textAlignment = .center
        copyrightLabel.numberOfLines = 1
        copyrightLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        copyrightLabel.textColor = .lightGrayText()
        copyrightLabel.text = "Copyright © 2019 | Major VII | ALL RIGHTS RESERVED"
        mainScrollView.addSubview(copyrightLabel)
        copyrightLabel.snp.makeConstraints { (make) -> Void in
            make.height.equalTo(14)
            make.top.equalTo(sepLine.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
        }
        
    }
}

//MARK: - Collection View Delegate
extension BuskerProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case imgCollectionView:
            let count = (buskerDetails != nil) ? (buskerDetails?.item?.coverImages.count)! : 3
            return count
            
        case hashtagsCollectionView:
            //let count = (buskerDetails != nil) ? (buskerDetails?.item?.hashtags.count)! : hashtagsArray.count
            return hashtagsArray.count
            
        case membersCollectionView:
            let count = (buskerDetails != nil) ? (buskerDetails?.item?.members.count)! : 3
            return count
            
        case eventsCollectionView:
            let count = (buskerEvents != nil) ? (buskerEvents?.list.count)! : 3
            return count
            
        case postsCollectionView:
            let count = (buskerPosts != nil) ? (buskerPosts?.list.count)! : 3
            return count
            
        default:
            return 4
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case imgCollectionView:
            let cell = imgCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileImgCell.reuseIdentifier, for: indexPath) as! BuskerProfileImgCell
            if let profile = buskerDetails?.item {
                let realIndexPath = self.imgCollectionView.indexPath(from: indexPath) //InfiniteLayout indexPath
                if let url = URL(string: profile.coverImages[realIndexPath.row].secureUrl!) {
                    cell.imgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                }
            }
            return cell
            
        case hashtagsCollectionView:
            let cell = hashtagsCollectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.reuseIdentifier, for: indexPath) as! HashtagCell
            cell.hashtag.alpha = 1
            cell.hashtag.text = "#\(hashtagsArray[indexPath.row])"
    
            return cell
            
        case membersCollectionView:
            let cell = membersCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileMemberCell.reuseIdentifier, for: indexPath) as! BuskerProfileMemberCell
            if let profile = buskerDetails?.item {
                if let url = URL(string: profile.members[indexPath.row].icon!.secureUrl!) {
                    let urlArr = url.absoluteString.components(separatedBy: "upload/")
                    let faceUrl = URL(string: "\(urlArr[0])upload/w_200,h_200,c_thumb,g_face/\(urlArr[1])") //apply crop and detect face by Cloudinary
                    cell.icon.kf.setImage(with: faceUrl, options: [.transition(.fade(0.3))])
                }
                cell.nameLabel.text = profile.members[indexPath.row].name
                cell.roleLabel.text = profile.members[indexPath.row].role
                
                cell.nameLabel.hideSkeleton()
                UIView.animate(withDuration: 0.2) {
                    cell.roleLabel  .alpha = 1
                }
            }

            return cell
            
        case eventsCollectionView:
            let cell = eventsCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileEventCell.reuseIdentifier, for: indexPath) as! BuskerProfileEventCell
            if let events = buskerEvents?.list {
                if let url = URL(string: events[indexPath.row].images[0].secureUrl!) {
                    cell.eventImg.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                }
                cell.eventLabel.text = events[indexPath.row].title
                cell.locationLabel.text = events[indexPath.row].address
                cell.bookmarkCount.text = "123"
                
                if let eventDate = events[indexPath.row].dateTime?.toDate(), let currentDate = Date().toISO().toDate() {
                    let difference = DateTimeHelper.getEventInterval(from: currentDate, to: eventDate)
                    cell.dateLabel.text = difference
                }
            }
            
            return cell
            
        case postsCollectionView:
            let cell = postsCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfilePostCell.reuseIdentifier, for: indexPath) as! BuskerProfilePostCell
            
            if let posts = buskerPosts?.list {
//                if let url = URL(string: posts[indexPath.row].images[0].secureUrl!) {
//                    cell.buskerIcon.kf.setImage(with: url, options: [.transition(.fade(0.3))])
//                }
                cell.buskerIcon.image = UIImage(named: "cat")
                cell.buskerLabel.text = posts[indexPath.row].authorProfile?.name
                if let postDate = posts[indexPath.row].publishTime?.toDate(), let currentDate = Date().toISO().toDate() {
                    let difference = DateTimeHelper.getNewsOrPostInterval(from: currentDate, to: postDate)
                    cell.dateLabel.text = difference
                }
                
                if let content = posts[indexPath.row].content {
                    cell.contentLabel.text = content
                } else {
                    cell.contentLabel.text = ""
                    cell.contentLabel.snp.remakeConstraints { (make) -> Void in
                        make.top.equalTo(cell.buskerLabel.snp.bottom)
                        make.width.equalTo(UIScreen.main.bounds.width - 120)
                        make.height.lessThanOrEqualTo(100)
                        make.centerX.equalToSuperview()
                    }
                }
                
                cell.statsLabel.text = "200個拍手 · 10個留言"
            }

            return cell
            
        default:
            let cell = hashtagsCollectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.reuseIdentifier, for: indexPath) as! HashtagCell
            cell.hashtag.text = "#\(hashtagsArray[indexPath.row])"
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case imgCollectionView:
            print("Img \(indexPath.row) tapped")
            
        case hashtagsCollectionView:
            print("Hashtag \(indexPath.row) tapped")
            
        case membersCollectionView:
            print("Member \(indexPath.row) tapped")

        case eventsCollectionView:
            //EventDetailsViewController.push(from: self, eventID: (buskerEvents?.list[indexPath.row].id)!)

            if !isModal {
                EventDetailsViewController.push(from: self, eventID: (buskerEvents?.list[indexPath.row].id)!)
            } else {
                EventDetailsViewController.present(from: self, eventID: (buskerEvents?.list[indexPath.row].id)!)
            }
            
        case postsCollectionView:
            print("Post \(indexPath.row) tapped")

        default:
            print("not collection view")

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case imgCollectionView:
            return CGSize(width: screenWidth, height: imgCollectionViewHeight)
            
        case hashtagsCollectionView:
            let size = (hashtagsArray[indexPath.row] as NSString).size(withAttributes: nil)
            return CGSize(width: size.width + 32, height: HashtagCell.height)
            
        case membersCollectionView:
            return CGSize(width: BuskerProfileMemberCell.width, height: BuskerProfileMemberCell.height)
            
        case eventsCollectionView:
            return CGSize(width: BuskerProfileEventCell.width, height: BuskerProfileEventCell.height)
            
        case postsCollectionView:
            return CGSize(width: BuskerProfilePostCell.width, height: BuskerProfilePostCell.height)
            
        default:
            let size = (hashtagsArray[indexPath.row] as NSString).size(withAttributes: nil)
            return CGSize(width: size.width + 32, height: HashtagCell.height)
        }
    }
}

//MARK: - UIScrollView Delegate
extension BuskerProfileViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
        }
        
        if scrollView == imgCollectionView {
            HapticFeedback.createImpact(style: .medium)
        }
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == imgCollectionView { //UICollectionView
            let indexPath = imgCollectionView.indexPath(from: imgCollectionView.indexPathsForVisibleItems.first!)
            pageControl.set(progress: indexPath.row, animated: true)
            //pageControl.set(progress: Int(scrollView.contentOffset.x) / Int(scrollView.frame.width), animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //** We keep the previous status bar hidden state so that
        // we’re not triggering an implicit animation block for every frame
        // in which the scroll view scrolls
        
//        let frame = pageControl.convert(pageControl.bounds, to: view)
//        print(frame.minY)
//        print(view.safeAreaInsets.top)
        
        if previousStatusBarHidden != shouldHideStatusBar {
            UIView.animate(withDuration: 0.2, animations: {
                self.setNeedsStatusBarAppearanceUpdate()
            })
            previousStatusBarHidden = shouldHideStatusBar
        }
    }
}

//MARK: - Function to push/present this view controller
extension BuskerProfileViewController {
    static func push(from view: UIViewController, buskerName: String, buskerID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: BuskerProfileViewController.storyboardID) as! BuskerProfileViewController
        
        profileVC.buskerID = buskerID
        profileVC.buskerName = buskerName
        
        view.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .zoom)
        view.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    static func present(from view: UIViewController, buskerName: String, buskerID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: BuskerProfileViewController.storyboardID) as! BuskerProfileViewController
        
        profileVC.buskerID = buskerID
        profileVC.buskerName = buskerName
        profileVC.modalPresentationStyle = .fullScreen /// iOS 13 modal default is card view, so we need to change to .fullscreen (old behaviour) here to prevent conflict with Hero library
        
        profileVC.hero.isEnabled = true
        profileVC.hero.modalAnimationType = .autoReverse(presenting: .zoom)
        view.present(profileVC, animated: true, completion: nil)
    }
}

//MARK: - Swipe pop gesture
extension BuskerProfileViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//UIButton subclass to get youtube id
class VidButton: UIButton {
    var videoIdentifier: String?
}
