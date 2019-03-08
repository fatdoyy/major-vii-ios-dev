//
//  BuskerProfileViewController.swift
//  major-7-ios
//
//  Created by jason on 27/2/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import CHIPageControl
import Parchment
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
    var followersCount = UILabel()
    var followersLabel = UILabel()
    var postsCount = UILabel()
    var postsLabel = UILabel()
    var eventsCount = UILabel()
    var eventsLabel = UILabel()
    
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
        setupMembersCollectionView()

        if #available(iOS 11.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadProfileDetails()
        mainScrollView.contentSize = CGSize(width: screenWidth, height: UIScreen.main.bounds.height + 500)
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
        
        followersCount.textColor = .white
        followersCount.text = "12k+"
        followersCount.textAlignment = .center
        followersCount.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        statsBgView.addSubview(followersCount)
        followersCount.snp.makeConstraints { (make) -> Void in
            make.leftMargin.equalTo(10)
            make.centerY.equalToSuperview().offset(-10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.height.equalTo(24)
        }
        
        followersLabel.textColor = .lightGray
        followersLabel.text = "Followers"
        followersLabel.textAlignment = .center
        followersLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        statsBgView.addSubview(followersLabel)
        followersLabel.snp.makeConstraints { (make) -> Void in
            make.leftMargin.equalTo(10)
            make.centerY.equalToSuperview().offset(10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.height.equalTo(12)
        }
        
        postsCount.textColor = .white
        postsCount.text = "65"
        postsCount.textAlignment = .center
        postsCount.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        statsBgView.addSubview(postsCount)
        postsCount.snp.makeConstraints { (make) -> Void in
            make.width.equalTo((screenWidth - 40) / 3)
            make.centerY.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        
        postsLabel.textColor = .lightGray
        postsLabel.text = "Posts"
        postsLabel.textAlignment = .center
        postsLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        statsBgView.addSubview(postsLabel)
        postsLabel.snp.makeConstraints { (make) -> Void in
            make.width.equalTo((screenWidth - 40) / 3)
            make.centerY.equalToSuperview().offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(12)
        }
        
        eventsCount.textColor = .white
        eventsCount.text = "10"
        eventsCount.textAlignment = .center
        eventsCount.font = UIFont.systemFont(ofSize: 21, weight: .semibold)
        statsBgView.addSubview(eventsCount)
        eventsCount.snp.makeConstraints { (make) -> Void in
            make.rightMargin.equalTo(-10)
            make.width.equalTo((screenWidth - 40) / 3)
            make.centerY.equalToSuperview().offset(-10)
            make.height.equalTo(24)
        }
        
        eventsLabel.textColor = .lightGray
        eventsLabel.text = "Events"
        eventsLabel.textAlignment = .center
        eventsLabel.font = UIFont.systemFont(ofSize: 11, weight: .light)
        statsBgView.addSubview(eventsLabel)
        eventsLabel.snp.makeConstraints { (make) -> Void in
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
        
        profileLineView.backgroundColor = .mintGreen()
        profileLineView.layer.cornerRadius = 2
        profileBgView.addSubview(profileLineView)
        profileLineView.snp.makeConstraints { (make) -> Void in
            make.topMargin.equalTo(14)
            make.leftMargin.equalTo(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        
        profileLabel.textColor = .white
        profileLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        profileLabel.text = "Profile"
        profileBgView.addSubview(profileLabel)
        profileLabel.snp.makeConstraints { (make) -> Void in
            make.topMargin.equalTo(14)
            make.left.equalTo(profileLineView.snp.right).offset(10)
            make.width.equalTo(100)
            make.height.equalTo(25)
        }
        
    }
    
    private func loadProfileDetails() {
        descString = "RubberBand is a Cantopop band formed in Hong Kong in 2004. They signed with Gold Typhoon label in 2006. They started as a 5-man band but after keyboard player Ngai Sum's departure in October 2010, comprise 4 members. In 2013 they switched to ASIA LP (zh), signing with them in February that year."
        
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

//Members Section
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
        
        membersLineView.backgroundColor = .mintGreen()
        membersLineView.layer.cornerRadius = 2
        membersBgView.addSubview(membersLineView)
        membersLineView.snp.makeConstraints { (make) -> Void in
            make.topMargin.equalTo(14)
            make.leftMargin.equalTo(16)
            make.width.equalTo(4)
            make.height.equalTo(24)
        }
        
        membersLabel.textColor = .white
        membersLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        membersLabel.text = "Members (6)"
        membersBgView.addSubview(membersLabel)
        membersLabel.snp.makeConstraints { (make) -> Void in
            make.topMargin.equalTo(14)
            make.left.equalTo(membersLineView.snp.right).offset(10)
            make.width.equalTo(300)
            make.height.equalTo(25)
        }
    }
    
    
    private func setupMembersCollectionView() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        membersCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth - 40, height: 120)), collectionViewLayout: layout)
        membersCollectionView.backgroundColor = UIColor.white.withAlphaComponent(0.05)
        membersCollectionView.dataSource = self
        membersCollectionView.delegate = self
        membersCollectionView.showsHorizontalScrollIndicator = false
        membersCollectionView.register(UINib.init(nibName: "MemberCell", bundle: nil), forCellWithReuseIdentifier: MemberCell.reuseIdentifier)
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
            let cell = membersCollectionView.dequeueReusableCell(withReuseIdentifier: MemberCell.reuseIdentifier, for: indexPath) as! MemberCell
            cell.icon.image = UIImage(named: "cat")
            cell.nameLabel.text = "Alex"
            cell.roleLabel.text = "Vocal"
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
            return CGSize(width: MemberCell.width, height: MemberCell.height)
            
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
