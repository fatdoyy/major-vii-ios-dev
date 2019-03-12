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

class BuskerProfileViewController: UIViewController {
    static let storyboardId = "buskerProfileVC"
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var contentView = UIView()
    var imgCollectionView: UICollectionView!
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let imgCollectionViewHeight: CGFloat = (UIScreen.main.bounds.height / 5) * 2
    let imgOverlay = UIView()
    
    let pageControl = CHIPageControlJaloro(frame: CGRect(x: 0, y: 0, width: 100, height: 10))
    var buskerLabel = UILabel()
    var buskerTaglineLabel = UILabel()
    
    var hashtagsCollectionView: UICollectionView!
    let hashtagsArray = ["123", "456", "789", "asdfgghh", "hkbusking", "guitarbusking", "cajon123", "abc555", "00000000", "#1452fa", "1234567890"]
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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

        if #available(iOS 11.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProfileDetails()
        mainScrollView.contentSize = CGSize(width: screenWidth, height: UIScreen.main.bounds.height + 1600)
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
        mainScrollView.addSubview(imgCollectionView)
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
    
    private func setupLabels() {
        buskerLabel.textAlignment = .left
        buskerLabel.numberOfLines = 1
        buskerLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        buskerLabel.textColor = .white
        buskerLabel.text = "jamistry"
        mainScrollView.insertSubview(buskerLabel, aboveSubview: imgOverlay)
        buskerLabel.snp.makeConstraints { (make) -> Void in
            //make.width.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.leftMargin.equalTo(20)
            make.bottom.equalTo(imgCollectionView.snp.bottom)
        }
        
        buskerTaglineLabel.textAlignment = .left
        buskerTaglineLabel.numberOfLines = 1
        buskerTaglineLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        buskerTaglineLabel.textColor = .lightGrayText()
        buskerTaglineLabel.text = "Two men and a guitar?"
        mainScrollView.insertSubview(buskerTaglineLabel, aboveSubview: imgOverlay)
        buskerTaglineLabel.snp.makeConstraints { (make) -> Void in
            //make.width.equalToSuperview().inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            make.leftMargin.equalTo(20)
            make.bottom.equalTo(buskerLabel.snp.top).offset(-5)
        }
    }
    
    private func setupPageControl() {
        //pageControl.alpha = 0
        pageControl.numberOfPages = 4
        pageControl.radius = 2
        pageControl.tintColor = .lightGrayText()
        pageControl.currentPageTintColor = .lightGrayText()
        pageControl.padding = 6
        mainScrollView.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) -> Void in
            make.leftMargin.equalTo(20)
            make.bottom.equalTo(buskerTaglineLabel.snp.top).offset(-12)
        }
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
            make.height.equalTo(28)
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
        //statsGradientBg.setColors([UIColor(hexString: "#FF5F6D"), UIColor(hexString: "#FFC371")])
        statsGradientBg.setColors([UIColor(red: 156/255, green: 39/255, blue: 176/255, alpha: 1.0),
                              UIColor(red: 255/255, green: 64/255, blue: 129/255, alpha: 1.0),
                              UIColor(red: 123/255, green: 31/255, blue: 162/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 76/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 32/255, green: 158/255, blue: 255/255, alpha: 1.0),
                              UIColor(red: 90/255, green: 120/255, blue: 127/255, alpha: 1.0),
                              UIColor(red: 58/255, green: 255/255, blue: 217/255, alpha: 1.0)])
        //statsGradientBg.layer.shadowColor = UIColor(hexString: "#FDC830").cgColor
        
        statsGradientBg.startAnimation()
        
        statsBgView.insertSubview(statsGradientBg, at: 0)
        mainScrollView.addSubview(statsBgView)
        statsBgView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(actionBtn.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(80)
        }
        
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
            make.height.equalTo(100)
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
    
    private func loadProfileDetails() {
        descString = "RubberBand is a Cantopop band formed in Hong Kong in 2004. They signed with Gold Typhoon label in 2006. They started as a 5-man band but after keyboard player Ngai Sum's departure in October 2010, comprise 4 members."
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        let myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.whiteText(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        // create attributed string
        let descAttrString = NSAttributedString(string: descString, attributes: myAttribute)
        
        // set attributed text on a UILabel
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

        print(profileDesc.attributedTextHeight(withWidth: screenWidth - 40))
        print(profileDesc.textHeight(withWidth: screenWidth - 40))
        
        let bgViewHeight = profileDesc.attributedTextHeight(withWidth: screenWidth - 80) + 54 + 20 //textHeight + topPadding(including "Profile" label) + bottomPadding
        
        profileBgView.snp.remakeConstraints { (make) -> Void in
            make.top.equalTo(statsBgView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(screenWidth - 40)
            make.height.equalTo(bgViewHeight)
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
            make.height.equalTo(600)
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

//MARK: Collection View Delegate
extension BuskerProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case imgCollectionView:
            //        let count = (details != nil) ? (details?.item?.coverImages.count)! : 3
            //        return count //number of images
            return 4
            
        case hashtagsCollectionView:
            return hashtagsArray.count
            
        case membersCollectionView:
            return 6 //members.count
            
        case eventsCollectionView:
            return 3
            
        case postsCollectionView:
            return 3
            
        default:
            return 4
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case imgCollectionView:
            let cell = imgCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileImgCell.reuseIdentifier, for: indexPath) as! BuskerProfileImgCell
            //        if let newsDetails = self.details?.item {
            //            if let url = URL(string: newsDetails.coverImages[indexPath.row].secureUrl!) {
            //                cell.imgView.kf.setImage(with: url, options: [.transition(.fade(0.75))])
            //            }
            //        }
            cell.imgView.image = UIImage(named: "cat")
            return cell
            
        case hashtagsCollectionView:
            let cell = hashtagsCollectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.reuseIdentifier, for: indexPath) as! HashtagCell
            cell.hashtag.text = "#\(hashtagsArray[indexPath.row])"
            return cell
            
        case membersCollectionView:
            let cell = membersCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileMemberCell.reuseIdentifier, for: indexPath) as! BuskerProfileMemberCell
            cell.icon.image = UIImage(named: "cat")
            cell.nameLabel.text = "Alex"
            cell.roleLabel.text = "Vocal"
            return cell
            
        case eventsCollectionView:
            let cell = eventsCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileEventCell.reuseIdentifier, for: indexPath) as! BuskerProfileEventCell
            cell.eventImg.image = UIImage(named: "cat")
            cell.eventLabel.text = "維港夜景Live"
            cell.locationLabel.text = "尖沙咀"
            cell.bookmarkCount.text = "32"
            cell.timeLabel.text = "3日後"
            return cell
            
        case postsCollectionView:
            let cell = postsCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfilePostCell.reuseIdentifier, for: indexPath) as! BuskerProfilePostCell
            cell.buskerIcon.image = UIImage(named: "cat")
            cell.buskerLabel.text = "RubberBand"
            cell.timeLabel.text = "10 min"
            cell.contentLabel.text = "黎緊嘅星期日，下午6點，記得準時黎到我地係西九搞嘅露天音樂會！盡情hi爆！！"
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
}

class VidButton: UIButton {
    var videoIdentifier: String?
}
