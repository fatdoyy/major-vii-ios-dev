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

class BuskerProfileViewController: UIViewController {
    static let storyboardId = "buskerProfileVC"
    
    var buskerName = "" {
        didSet {
            print("buskerName is set! \(buskerName)")
        }
    }
    
    var buskerId = "" {
        didSet {
            getProfileDetails(buskerId: buskerId)
            getBuskerEvents(buskerId: buskerId)
            getBuskerPosts(buskerId: buskerId)
        }
    }
    
    var buskerDetails: BuskerProfile? {
        didSet {
            print("Details arrived!!!\n\(String(describing: buskerDetails?.item?.name))")
            loadProfileDetails()
        }
    }
    
    var hashtagsArray = [String]()
    
    var buskerEvents: BuskerEventsList? {
        didSet {
            eventsCollectionView.reloadData()
        }
    }
    
    var buskerPosts: BuskerPostsList?  {
        didSet {
            postsCollectionView.reloadData()
        }
    }
    
    //gesture for swipe-pop
    var gesture: UIGestureRecognizer?
    
    var loadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var imgContainerView = UIView()
    var imgCollectionView: UICollectionView!
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let imgCollectionViewHeight: CGFloat = (UIScreen.main.bounds.height / 5) * 2
    let imgOverlay = UIView()
    
    let pageControl = CHIPageControlJaloro(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
    var buskerLabel = UILabel()
    var buskerTaglineLabel = UILabel()
    
    var hashtagsCollectionView: UICollectionView!
    
    var actionBtn = UIButton()
    var statsBgView = UIView()
    var statsGradientBg = PastelView()
    var statsFollowersCount = UILabel()
    var statsFollowersLabel = UILabel()
    var statsPostsCount = UILabel()
    var statsPostsLabel = UILabel()
    var statsEventsCount = UILabel()
    var statsEventsLabel = UILabel()
    
    //profile section
    var profileBgView = UIView()
    var profileLabel = UILabel()
    var profileLineView = UIView()
    var profileDesc = UILabel()
    var profileBgViewHeight: CGFloat = 0
    var descString = ""

    //members section
    var membersBgView = UIView()
    var membersLabel = UILabel()
    var membersLineView = UIView()
    var membersCollectionView: UICollectionView!
   
    //live/works section
    var liveBgView = UIView()
    var liveLabel = UILabel()
    var liveLineView = UIView()
    var liveCollectionView: UICollectionView!
    
    //events section
    var eventsBgView = UIView()
    var eventsLabel = UILabel()
    var eventsLineView = UIView()
    var eventsCollectionView: UICollectionView!
    
    //posts section
    var postsBgView = UIView()
    var postsLabel = UILabel()
    var postsLineView = UIView()
    var postsCollectionView: UICollectionView!
    
    //footer section
    var copyrightLabel = UILabel()
    var sepLine = UIView()
    
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
        
        setupLeftBarItems()
        updatesStatusBarAppearanceAutomatically = true
        view.backgroundColor = .darkGray()
        
        setupImgCollectionView()
        setupOverlay()
        setupLabels()
        setupPageControl()
        setupHashtagsCollectionView()
        
        setupActionBtn()
        
        setupStatsView()
        setupProfileSection()
        setupMembersSection()
        setupPerformancesSection()
        setupEventsSection()
        setupPostSection()

        setupFooter()
        
        print(imgCollectionViewHeight)
        print(imgCollectionViewHeight / 2)

        mainScrollView.contentInsetAdjustmentBehavior = .never
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TabBar.hide(rootView: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBar.show(rootView: self)
    }
    
}

//MARK: API Calling
extension BuskerProfileViewController {
    private func getProfileDetails(buskerId: String) {
        BuskerService.getProfileDetails(buskerId: buskerId).done { details -> () in
            self.buskerDetails = details
            
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func getBuskerEvents(buskerId: String) {
        BuskerService.getBuskerEvents(buskerId: buskerId).done { events -> () in
            self.buskerEvents = events
            
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func getBuskerPosts(buskerId: String) {
        BuskerService.getBuskerPosts(buskerId: buskerId).done{ posts -> () in
            self.buskerPosts = posts
            
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    private func loadProfileDetails() {
        if let details = buskerDetails {
            if let profile = details.item {
                imgCollectionView.reloadData()
                
                pageControl.numberOfPages = profile.coverImages.count
                
                self.hashtagsCollectionView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(28)
                }

                for hashtag in profile.hashtags {
                    hashtagsArray.append(hashtag)
                }
                hashtagsCollectionView.reloadData()
                
                descString = profile.desc!
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 8
                paragraphStyle.lineBreakMode = .byTruncatingTail
                
                let myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.whiteText(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
                
                // create attributed string
                let descAttrString = NSAttributedString(string: descString, attributes: myAttribute)
                
                // set attributed text on a UILabel
                profileDesc.alpha = 0
                profileDesc.attributedText = descAttrString
                profileDesc.sizeToFit()
                profileDesc.font = UIFont.systemFont(ofSize: 14, weight: .regular)
                profileDesc.numberOfLines = 0
                profileDesc.lineBreakMode = .byWordWrapping
                profileBgView.addSubview(profileDesc)
                profileDesc.snp.makeConstraints { (make) -> Void in
                    make.top.equalTo(profileLineView.snp.bottom).offset(16)
                    make.leftMargin.equalToSuperview().offset(20)
                    make.rightMargin.equalToSuperview().offset(-20)
                }
                viewsToShowLater.append(profileDesc)
                
                profileBgViewHeight = profileDesc.attributedTextHeight(withWidth: screenWidth - 80) + 54 + 20 //textHeight + topPadding(including "Profile" label) + bottomPadding
                
                profileBgView.snp.updateConstraints { (make) -> Void in
                    make.height.equalTo(profileBgViewHeight)
                }
                
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
                
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
                
                for view in viewsToShowLater {
                    UIView.animate(withDuration: 0.3) {
                        view.alpha = 1
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    for view in self.delayedViewsToShowLater {
                        UIView.animate(withDuration: 0.3) {
                            self.loadingIndicator.alpha = 0
                            view.alpha = 1
                        }
                    }
                }
                
                
                //adjust mainScrollView height
                if UIDevice().userInterfaceIdiom == .phone {
                    switch UIScreen.main.nativeBounds.height {
                        
                        /*
                         height =   imgCollectionViewHeight + hashtagsCollecitonViewHeight (with top padding) +
                         actionBtnHeight (with top padding) + statsHeight (with top padding) +
                         profileHeight (with top padding) + membersSectionHeight (with top padding) +
                         liveHeight (with top padding) + eventsHeight (with top padding) +
                         postsHeight (with top padding) + footerHeight (with top padding) + bottom padding
                         */
                        
                    case 1136, 1334:
                        if profile.members.isEmpty {
                            let height = imgCollectionViewHeight + 43 + 60 + 100 + (profileBgViewHeight + 20) + 140 + 294 + 520 + 86
                            mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
                        } else {
                            let height = imgCollectionViewHeight + 43 + 60 + 100 + (profileBgViewHeight + 20) + 213 + 140 + 294 + 520 + 86
                            mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
                        }
                    case 1920, 2208, 2436, 2688, 1792:
                        if profile.members.isEmpty {
                            let height = imgCollectionViewHeight + 43 + 60 + 100 + (profileBgViewHeight + 20) + 140 + 294 + 520 + 106
                            mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
                        } else {
                            let height = imgCollectionViewHeight + 43 + 60 + 100 + (profileBgViewHeight + 20) + 213 + 140 + 294 + 520 + 106
                            mainScrollView.contentSize = CGSize(width: screenWidth, height: height)
                        }
                        
                    default:
                        print("unknown")
                    }
                }
                
            }
        }
    }
}

//MARK: UI functions
extension BuskerProfileViewController {
    private func setupImgCollectionView() {

        //image collection view
        let layout: UICollectionViewFlowLayout = PagedCollectionViewLayout()
        layout.itemSize = CGSize(width: screenWidth, height: imgCollectionViewHeight)
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        imgCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: imgCollectionViewHeight)), collectionViewLayout: layout)
        imgCollectionView.backgroundColor = .darkGray()
        imgCollectionView.collectionViewLayout = layout
        imgCollectionView.dataSource = self
        imgCollectionView.delegate = self
        imgCollectionView.showsHorizontalScrollIndicator = false
        imgCollectionView.register(UINib.init(nibName: "BuskerProfileImgCell", bundle: nil), forCellWithReuseIdentifier: BuskerProfileImgCell.reuseIdentifier)
        
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
        imgOverlay.layer.insertSublayer(GradientLayer.create(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: (imgCollectionViewHeight / 3) * 2)), colors: [.darkGray(), .clear], startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0)), at: 0)
        mainScrollView.insertSubview(imgOverlay, aboveSubview: imgCollectionView)
        imgOverlay.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(imgCollectionView.snp.top).offset(imgCollectionViewHeight / 3)
            //make.size.equalTo(imgCollectionView)
        }
    }
    
    private func setupLeftBarItems() {
        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20, height: 44.0))
        customView.backgroundColor = .clear
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 5, y: 10, width: 14.13, height: 24)
        menuBtn.setImage(UIImage(named: "back"), for: .normal)
        menuBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        customView.addSubview(menuBtn)
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
        self.navigationItem.leftBarButtonItem = menuBarItem
    }
    
    @objc private func popView(){
        navigationController?.hero.navigationAnimationType = .zoomOut
        navigationController?.popViewController(animated: true)
    }
    
    private func setupLabels() {
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
        buskerTaglineLabel.text = "Two men and a guitar?"
        mainScrollView.insertSubview(buskerTaglineLabel, aboveSubview: imgOverlay)
        buskerTaglineLabel.snp.makeConstraints { (make) -> Void in
            //make.width.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(buskerLabel.snp.top).offset(-5)
        }
        viewsToShowLater.append(buskerTaglineLabel)
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
        hashtagsCollectionView.backgroundColor = .darkGray()
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
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
    }
    
    private func setupActionBtn() {
        actionBtn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        actionBtn.setTitle("Follow", for: .normal)
        actionBtn.setTitleColor(.white, for: .normal)
        actionBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        actionBtn.layer.cornerRadius = GlobalCornerRadius.value
        actionBtn.addTarget(self, action: #selector(didTapActionBtn), for: .touchUpInside)
        mainScrollView.addSubview(actionBtn)
        actionBtn.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(40)
            make.top.equalTo(hashtagsCollectionView.snp.bottom).offset(20)
        }
    }
    
    @objc private func didTapActionBtn(_ sender: UIButton) {
        Animations.btnBounce(sender: sender)
        print("action btn tapped")
    }
    
    private func setupStatsView() {
        statsBgView.layer.cornerRadius = GlobalCornerRadius.value
        statsBgView.clipsToBounds = true
        statsBgView.backgroundColor = .darkGray
        
        statsGradientBg.frame = CGRect(x: 0, y: 0, width: screenWidth - 40, height: 80)
        statsGradientBg.animationDuration = 2.5
        statsGradientBg.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        
        statsGradientBg.startAnimation()
        
        statsBgView.insertSubview(statsGradientBg, at: 0)
        loadingIndicator.startAnimating()
        statsBgView.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        mainScrollView.addSubview(statsBgView)
        statsBgView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(actionBtn.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(80)
        }
        
        statsFollowersCount.alpha = 0
        statsFollowersCount.textColor = .white
        statsFollowersCount.text = "12k+"
        statsFollowersCount.textAlignment = .center
        statsFollowersCount.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        statsBgView.addSubview(statsFollowersCount)
        statsFollowersCount.snp.makeConstraints { (make) -> Void in
            make.leftMargin.equalTo(10)
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
            make.leftMargin.equalTo(10)
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.height.equalTo(12)
        }
        delayedViewsToShowLater.append(statsFollowersLabel)
        
        statsPostsCount.alpha = 0
        statsPostsCount.textColor = .white
        statsPostsCount.text = "65"
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
        statsEventsCount.text = "10"
        statsEventsCount.textAlignment = .center
        statsEventsCount.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        statsBgView.addSubview(statsEventsCount)
        statsEventsCount.snp.makeConstraints { (make) -> Void in
            make.rightMargin.equalTo(-10)
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
            make.rightMargin.equalTo(-10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.centerY.equalToSuperview().offset(10)
            make.height.equalTo(12)
        }
        delayedViewsToShowLater.append(statsEventsLabel)
        
    }
}

//MARK: Profile section
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
            make.height.equalTo(90)
        }
        
        profileLineView.isUserInteractionEnabled = false
        profileLineView.backgroundColor = .mintGreen()
        profileLineView.layer.cornerRadius = 2
        profileBgView.addSubview(profileLineView)
        profileLineView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(14)
            make.leftMargin.equalTo(16)
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
            make.width.equalTo(100)
            make.height.equalTo(25)
        }
        
    }
 
}

//MARK: Members Section
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
            make.leftMargin.equalTo(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        
        membersLabel.textColor = .white
        membersLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        membersLabel.text = "Members (6)"
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
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
    }
}

//MARK: Perfomrnace/Songs section
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
            make.leftMargin.equalTo(16)
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
        
        let btn = VidButton()
        btn.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        btn.setTitle("TEST", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        btn.layer.cornerRadius = GlobalCornerRadius.value / 2
        btn.videoIdentifier = "NdLZ76bYNy8"
        btn.addTarget(self, action: #selector(playVideo), for: .touchUpInside)
        liveBgView.addSubview(btn)
        btn.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalTo(screenWidth - 80)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
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

//MARK: Events Section
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
            make.leftMargin.equalTo(16)
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
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
    }
    
}

//MARK: Posts Section
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
            make.leftMargin.equalTo(16)
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
            make.leftMargin.equalTo(0)
            make.rightMargin.equalTo(0)
        }
    }
}

//MARK: Footer Section
extension BuskerProfileViewController {
    private func setupFooter(){
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

//MARK: Collection View Delegate
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
                if let url = URL(string: profile.coverImages[indexPath.row].secureUrl!) {
                    cell.imgView.kf.setImage(with: url, options: [.transition(.fade(0.75))])
                }
            }
            return cell
            
        case hashtagsCollectionView:
            let cell = hashtagsCollectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.reuseIdentifier, for: indexPath) as! HashtagCell
            cell.hashtag.alpha = 1
            if let profile = buskerDetails?.item {
                for hashtag in profile.hashtags {
                    print("cellforitemat \(hashtag)")
                }
                //cell.hashtag.text = "#\(profile.hashtags[indexPath.row])"
                cell.hashtag.text = "#\(hashtagsArray[indexPath.row])"

            } else {
                cell.hashtag.text = "(error))"
            }
            return cell
            
        case membersCollectionView:
            let cell = membersCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileMemberCell.reuseIdentifier, for: indexPath) as! BuskerProfileMemberCell
            if let profile = buskerDetails?.item {
                if let url = URL(string: profile.members[indexPath.row].icon!.secureUrl!) {
                    cell.icon.kf.setImage(with: url, options: [.transition(.fade(0.75))])
                }
                cell.nameLabel.text = profile.members[indexPath.row].name
                cell.roleLabel.text = profile.members[indexPath.row].role
            }

            return cell
            
        case eventsCollectionView:
            let cell = eventsCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileEventCell.reuseIdentifier, for: indexPath) as! BuskerProfileEventCell
            if let events = buskerEvents?.list {
                if let url = URL(string: events[indexPath.row].images[0].secureUrl!) {
                    cell.eventImg.kf.setImage(with: url, options: [.transition(.fade(0.75))])
                }
                cell.eventLabel.text = events[indexPath.row].title
                cell.locationLabel.text = events[indexPath.row].address
                cell.bookmarkCount.text = "123"
                cell.timeLabel.text = events[indexPath.row].dateTime
            }
            
            return cell
            
        case postsCollectionView:
            let cell = postsCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfilePostCell.reuseIdentifier, for: indexPath) as! BuskerProfilePostCell
            
            if let posts = buskerPosts?.list {
//                if let url = URL(string: posts[indexPath.row].images[0].secureUrl!) {
//                    cell.buskerIcon.kf.setImage(with: url, options: [.transition(.fade(0.75))])
//                }
                cell.buskerIcon.image = UIImage(named: "cat")
                cell.buskerLabel.text = posts[indexPath.row].createrProfile?.name
                cell.timeLabel.text = posts[indexPath.row].publishTime
                
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case imgCollectionView:
            return CGSize(width: screenWidth, height: imgCollectionViewHeight)
            
        case hashtagsCollectionView:
            if let profile = buskerDetails?.item {
                //let size = (profile.hashtags[indexPath.row] as NSString).size(withAttributes: nil)
                let size = (hashtagsArray[indexPath.row] as NSString).size(withAttributes: nil)
                return CGSize(width: size.width + 32, height: HashtagCell.height)
            } else {
                let size = (hashtagsArray[indexPath.row] as NSString).size(withAttributes: nil)
                return CGSize(width: size.width + 32, height: HashtagCell.height)
            }
            
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

//MARK: UIScrollView Delegate
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
            pageControl.set(progress: Int(scrollView.contentOffset.x) / Int(scrollView.frame.width), animated: true)
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

// MARK: function to push this view controller
extension BuskerProfileViewController {
    static func push(fromView: UIViewController, buskerName: String, buskerId: String){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let profileVC = storyboard.instantiateViewController(withIdentifier: BuskerProfileViewController.storyboardId) as! BuskerProfileViewController
        
        profileVC.buskerId = buskerId
        profileVC.buskerName = buskerName
        
        fromView.navigationItem.title = ""
        fromView.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .zoom)
        fromView.navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: swipe pop gesture
extension BuskerProfileViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//uibutton subclass to get youtube id
class VidButton: UIButton {
    var videoIdentifier: String?
}
