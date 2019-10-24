//
//  HomeViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Kingfisher
import Localize_Swift
import NVActivityIndicatorView

protocol HomeViewControllerDelegate: class {
    func refreshUpcomingEvents()
}

class HomeViewController: UIViewController {
    weak var delegate: HomeViewControllerDelegate?
    let network = NetworkManager.sharedInstance
    weak var previousController: UIViewController? //for tabbar scroll to top

    // Remove when comments and image section API in Post are done
    var haveComments = [true, false, true]
    var username = ["fatdoyy", "John Mayer", "ronniefieg"]
    var comments = ["呢個畫面真係好魔幻", "親眼見到居民對遊行支持 感謝", "Great show!"]
    var haveImages = [true, true, false]
    
    //Custom refresh control
    var refreshView: RefreshView!
    var refreshIndicator: NVActivityIndicatorView?
    var customRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        return refreshControl
    }()

    var coverImagesUrl = [String]()
    
    var selectedSection = HomeSelectedSection.News //default section is "News"
    
    var news = [News]()
    var newsLimit = 5 //news limit per request
    var gotMoreNews = true //lazy loading, "true" because default section is News
    
    var posts = [Post]()
    var attrContentArr = [NSAttributedString]() //attributed string array
    var postsLimit = 3 //post limit per request
    var gotMorePosts = false //lazy loading, should be set to true when Posts section is selected
    var isPostCellExpanded = [Bool]()
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NetworkManager.isUnreachable { _ in
            self.mainCollectionView.alpha = 0
            print("unreachable!!")
        }
        
        network.reachability.whenReachable = { _ in
            self.mainCollectionView.alpha = 1
            print("reachable now")
        }
        
        //check if we need to present loginVC
        if !UserService.User.isLoggedIn() {
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            //            loginVC.hero.isEnabled = true
            //            loginVC.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
            self.present(loginVC, animated: true, completion: nil)
        }
        
        setupUI()
        getNews(limit: newsLimit)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = ""
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (navigationController?.topViewController != self) {
            let bounds = self.navigationController!.navigationBar.bounds
            navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height + 100)
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
}

//MARK: - UI related
extension HomeViewController {
    func setupUI() {
        view.backgroundColor = .m7DarkGray()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        tabBarController?.delegate = self
        mainCollectionView.refreshControl = customRefreshControl
        
        setupMainCollectionView()
    }
    
    func setupMainCollectionView() {
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        
        mainCollectionView.backgroundColor = .m7DarkGray()
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        
        mainCollectionView.register(UINib.init(nibName: "HomeHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeHeaderView.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "EventsSection", bundle: nil), forCellWithReuseIdentifier: EventsSection.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "NewsSectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NewsSectionHeader.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "NewsCellType1", bundle: nil), forCellWithReuseIdentifier: NewsCellType1.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType2", bundle: nil), forCellWithReuseIdentifier: NewsCellType2.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType3", bundle: nil), forCellWithReuseIdentifier: NewsCellType3.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType4", bundle: nil), forCellWithReuseIdentifier: NewsCellType4.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType5", bundle: nil), forCellWithReuseIdentifier: NewsCellType5.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "HomePostCell", bundle: nil), forCellWithReuseIdentifier: HomePostCell.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "NewsSectionFooter", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NewsSectionFooter.reuseIdentifier)
    }
}

//MARK: - Custom refresh control
extension HomeViewController {
    func setupRefreshView() {
        if let objOfRefreshView = Bundle.main.loadNibNamed("RefreshView", owner: self, options: nil)?.first as? RefreshView {
            // Initializing the 'refreshView'
            refreshView = objOfRefreshView
            // Giving the frame as per 'tableViewRefreshControl'
            refreshView.frame = customRefreshControl.frame
            // Adding the 'refreshView' to 'tableViewRefreshControl'
            refreshView.setupUI()
            customRefreshControl.addSubview(refreshView)
        }
    }
    
    @objc func refreshCollectionView() {
        // Start animation here.
        refreshView.startAnimation()
        print("refreshing")
        
        //First refresh upcoming events section
        delegate?.refreshUpcomingEvents()
        
        //Then refresh based on selected section
        switch selectedSection {
        case .News:
            news.removeAll()
            mainCollectionView.reloadData()
            gotMoreNews = true
            getNews(limit: newsLimit)
            
        case .Posts:
            posts.removeAll()
            mainCollectionView.reloadData()
            gotMorePosts = true
            getPosts(limit: postsLimit)
            
        }
    }
}

//MARK: - API Calls
extension HomeViewController {
    private func getNews(skip: Int? = nil, limit: Int? = nil) {
        mainCollectionView.isUserInteractionEnabled = false
        NewsService.getList(skip: skip, limit: limit).done { response -> () in
            //self.newsList = response.list
            self.news.append(contentsOf: response.list)
            self.gotMoreNews = response.list.count < self.newsLimit || response.list.count == 0 ? false : true
            self.mainCollectionView.reloadData()
            }.ensure {
                self.mainCollectionView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                //pull to refresh
                if let refreshView = self.refreshView {
                    refreshView.stopAnimation()
                    self.customRefreshControl.endRefreshing()
                    //HapticFeedback.createNotificationFeedback(style: .success)
                } else {
                    self.setupRefreshView() //setup pull to refresh view
                }
                
            }.catch { error in }
    }
    
    private func getPosts(skip: Int? = nil, limit: Int? = nil) {
        mainCollectionView.isUserInteractionEnabled = false
        PostService.getList(skip: skip, limit: limit).done { response -> () in
            self.posts.append(contentsOf: response.list)
            self.gotMorePosts = response.list.count < self.postsLimit || response.list.count == 0 ? false : true
            
            //set text attributes to content and add them to new array (i.e. attrContentArr)
            for post in self.posts {
                if let content = post.content {
                    let contentAttrString = NSAttributedString(string: content, attributes: TextAttributes.postContentConfig())
                    self.attrContentArr.append(contentAttrString)
                }
            }
            
            self.isPostCellExpanded = Array(repeating: false, count: self.posts.count)
            self.mainCollectionView.reloadData()
            }.ensure {
                self.mainCollectionView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                self.refreshView.stopAnimation()
                self.customRefreshControl.endRefreshing()
                //HapticFeedback.createNotificationFeedback(style: .success)
            }.catch { error in }
    }
}

// MARK: UICollectionView Delegate
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 } else { // News|Posts section
            switch selectedSection {
            case .News:     return news.isEmpty ? 3 : news.count
            case .Posts:    return posts.isEmpty ? 3 : posts.count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 { //events section
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: EventsSection.reuseIdentifier, for: indexPath) as! EventsSection
            cell.delegate = self
            cell.homeVCInstance = self //passed the correct instance for delegate
            
            return cell
        } else { // news|posts section
            switch selectedSection {
            case .News:
                if !news.isEmpty {
                    switch news[indexPath.row].cellType! {
                    case 1:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType1.reuseIdentifier, for: indexPath) as! NewsCellType1
                        
                        //Hashtag.createAtCell(cell: cell, position: .cellTop, dataSource: newsList[indexPath.row].hashtags, multiLines: true, solidColor: true)
                        let hashtagsArr = news[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr }
                        
                        cell.newsTitle.text = news[indexPath.row].title
                        //cell.bgImgView.sd_imageTransition = .fade
                        if let url = URL(string: news[indexPath.row].coverImages[0].secureUrl!) {
                            cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                        }
                        
                        if let newsDate = news[indexPath.row].publishTime?.toDate(), let currentDate = Date().toISO().toDate() {
                            let difference = DateTimeHelper.getNewsOrPostInterval(from: currentDate, to: newsDate)
                            cell.dateLabel.text = difference
                        }
                        
                        return cell
                    case 2:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType2.reuseIdentifier, for: indexPath) as! NewsCellType2
                        
                        let hashtagsArr = news[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr }
                        
                        cell.newsTitle.text = news[indexPath.row].title
                        
                        if let url = URL(string: news[indexPath.row].coverImages[0].secureUrl!) {
                            cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                        }
                        
                        if let newsDate = news[indexPath.row].publishTime?.toDate(), let currentDate = Date().toISO().toDate() {
                            let difference = DateTimeHelper.getNewsOrPostInterval(from: currentDate, to: newsDate)
                            cell.dateLabel.text = difference
                        }
                        
                        return cell
                    case 3:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType3.reuseIdentifier, for: indexPath) as! NewsCellType3
                        
                        let hashtagsArr = news[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr } else {
                            cell.newsTitleTopConstraint.isActive = false
                            cell.newsTitle.snp.remakeConstraints { (make) in
                                make.top.equalTo(25)
                            }
                        }
                        cell.newsTitle.text = news[indexPath.row].title
                        cell.subTitle.text = news[indexPath.row].subTitle
                        
                        if let url = URL(string: news[indexPath.row].coverImages[0].secureUrl!) {
                            cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                        }
                        
                        if let newsDate = news[indexPath.row].publishTime?.toDate(), let currentDate = Date().toISO().toDate() {
                            let difference = DateTimeHelper.getNewsOrPostInterval(from: currentDate, to: newsDate)
                            cell.dateLabel.text = difference
                        }
                        
                        return cell
                    case 4:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType4.reuseIdentifier, for: indexPath) as! NewsCellType4
                        
                        for view in cell.skeletonViews{ //hide all skeleton views because template 4 is the default template
                            if view.tag == 2 { //remove dummyTagLabel
                                view.isHidden = true
                            }
                            view.hideSkeleton()
                        }
                        
                        for view in cell.viewsToShowlater {
                            view.isHidden = false
                        }
                        
                        cell.gradientBg.isHidden = false
                        cell.gradientBg.startAnimation()
                        
                        let hashtagsArr = news[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr } else {
                            cell.newsTitleTopConstraint.isActive = false
                            cell.newsTitle.snp.remakeConstraints { (make) in
                                make.top.equalTo(25)
                            }
                        }
                        cell.newsTitle.text = news[indexPath.row].title
                        cell.subTitle.text = news[indexPath.row].subTitle
                        
                        if let newsDate = news[indexPath.row].publishTime?.toDate(), let currentDate = Date().toISO().toDate() {
                            let difference = DateTimeHelper.getNewsOrPostInterval(from: currentDate, to: newsDate)
                            cell.dateLabel.text = difference
                        }
                        
                        return cell
                    case 5:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType5.reuseIdentifier, for: indexPath) as! NewsCellType5
                        
                        let hashtagsArr = news[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr }
                        
                        cell.newsTitle.text = news[indexPath.row].title
                        cell.subTitle.text = news[indexPath.row].subTitle
                        
                        if let newsDate = news[indexPath.row].publishTime?.toDate(), let currentDate = Date().toISO().toDate() {
                            let difference = DateTimeHelper.getNewsOrPostInterval(from: currentDate, to: newsDate)
                            cell.dateLabel.text = difference
                        }
                        
                        return cell
                    default: //loading template
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType4.reuseIdentifier, for: indexPath) as! NewsCellType4
                        return cell
                    }
                } else { // news list is empty
                    let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType4.reuseIdentifier, for: indexPath) as! NewsCellType4
                    return cell
                }
                
            case .Posts:
                if !posts.isEmpty {
                    let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.reuseIdentifier, for: indexPath) as! HomePostCell
                    cell.delegate = self
                    
                    if let url = URL(string: posts[indexPath.row].authorProfile?.coverImages[0].secureUrl! ?? "") {
                        cell.buskerIcon.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                    }
                    
                    for view in cell.skeletonViews { view.hideSkeleton() }
                    for view in cell.viewsToShowLater { view.alpha = 1 }
                    
                    if let postDate = posts[indexPath.row].publishTime?.toDate(), let currentDate = Date().toISO().toDate() {
                        let difference = DateTimeHelper.getNewsOrPostInterval(from: currentDate, to: postDate)
                        cell.dateLabel.text = difference
                    }
                    
                    cell.contentLabel.snp.removeConstraints()
                    cell.statsLabel.snp.removeConstraints()
                    for constraint in cell.tempConstraints { constraint.isActive = true }
                    
                    cell.indexPath = indexPath
                    cell.buskerName.text = posts[indexPath.row].authorProfile?.name
                    cell.contentLabel.numberOfLines = isPostCellExpanded[indexPath.row] == true ? 0 : 2
                    cell.contentLabel.attributedText = attrContentArr[indexPath.row] //not getting from postsList because we need attributed text
                    cell.contentLabel.sizeToFit()
                    //                    print("contentLabelHeight = \(cell.contentLabel.bounds.size.height)")
                    //                    print("Is cell \(indexPath.row) truncated? \(cell.contentLabel.isTruncated)")
                    
                    if cell.contentLabel.isTruncated { //add custom truncated text
                        //DispatchQueue.main.async {
                        cell.contentLabel.addTrailing(with: "... ", moreText: "more", moreTextFont: UIFont.systemFont(ofSize: 13, weight: .bold), moreTextColor: .lightPurple())
                        //}
                    }
                    
                    if haveImages[indexPath.row] == true && haveComments[indexPath.row] == true {
                        
                        cell.username.text = username[indexPath.row]
                        cell.userComment.text = comments[indexPath.row]
                        cell.userIcon.image = UIImage(named: "cat")
                        
                        //TODO
                        //cell.imgCollectionView.imgArray
                        
                    } else if haveImages[indexPath.row] == true { //hide comment section and update constraints
                        for view in cell.commentSection {
                            view.alpha = 0
                        }
                        
                        //update constraints
                        for constraint in cell.commentSectionConstraints { constraint.isActive = false }
                        cell.clapBtn.snp.makeConstraints { (make) in
                            make.bottom.equalToSuperview().offset(-20)
                        }
                    } else if haveComments[indexPath.row] == true { //hide imgCollectionView and update constraints
                        cell.username.text = username[indexPath.row]
                        cell.userComment.text = comments[indexPath.row]
                        cell.userIcon.image = UIImage(named: "cat")
                        
                        //hide imgCollectionView
                        cell.imgCollectionView.alpha = 0
                        
                        //update constraints
                        for constraint in cell.imgCollectionViewConstraints { constraint.isActive = false }
                        cell.statsLabel.snp.makeConstraints { (make) in
                            make.top.equalTo(cell.contentLabel.snp.bottom).offset(20)
                        }
                    }

                    return cell
                } else { // post list is empty
                    return mainCollectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.reuseIdentifier, for: indexPath) as! HomePostCell
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        switch selectedSection {
        case .News:
            if (indexPath.row == news.count - 1 ) {
                print("Fetching news...")
                gotMoreNews ? getNews(skip: news.count, limit: newsLimit) : print("No more news to fetch!")
            }
        case .Posts:
            if (indexPath.row == posts.count - 1 ) {
                print("Fetching posts...")
                gotMorePosts ? getPosts(skip: posts.count, limit: postsLimit) : print("No more posts to fetch!")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 /* Upcoming events section */ { return CGSize(width: view.frame.width, height: EventsSection.height) } else {
            switch selectedSection {
            case .News:
                if !news.isEmpty {
                    switch news[indexPath.row].cellType! {
                    case 1, 2:  return CGSize(width: NewsCellType1.width, height: NewsCellType1.height) //cell type 1,2 have same height
                    default:    return CGSize(width: NewsCellType3.width, height: NewsCellType3.height) //cell type 3,4,5 have same height
                    }
                } else { //news list is empty
                    return CGSize(width: NewsCellType3.width, height: NewsCellType3.height)
                }
                
            case .Posts: //dynamic cell height (i.e. attributed text height)
                if !posts.isEmpty {
                    let attrTextHeight = attrContentArr[indexPath.row].height(withWidth: HomePostCell.width)
                    
                    let sizeWithText = CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight - HomePostCell.commentSectionHeight - 188)
                    let sizeWithTextImg = CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight - HomePostCell.commentSectionHeight)
                    let sizeWithTextComment = CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight - 188)
                    let sizeWithTextImgComment = CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight)
                    
                    let sizeWithTextExpanded = CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight + attrTextHeight - HomePostCell.commentSectionHeight - 188)
                    let sizeWithTextImgExpanded = CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight + attrTextHeight - HomePostCell.commentSectionHeight)
                    let sizeWithTextCommentExpanded = CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight + attrTextHeight - 188)
                    let sizeWithTextImgCommentExpanded = CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight + attrTextHeight)
                    
                    if isPostCellExpanded[indexPath.row] == true {
                        if haveImages[indexPath.row] == true && haveComments[indexPath.row] == true {
                            return sizeWithTextImgCommentExpanded
                        } else if haveImages[indexPath.row] == true {
                            return sizeWithTextImgExpanded
                        } else if haveComments[indexPath.row] == true {
                            return sizeWithTextCommentExpanded
                        } else {
                            return sizeWithTextExpanded
                        }
                        
                    } else {
                        if haveImages[indexPath.row] == true && haveComments[indexPath.row] == true {
                            return sizeWithTextImgComment
                        } else if haveImages[indexPath.row] == true {
                            return sizeWithTextImg
                        } else if haveComments[indexPath.row] == true {
                            return sizeWithTextComment
                        } else {
                            return sizeWithText
                        }
                    }
                } else { //news list is empty
                    return CGSize(width: HomePostCell.width, height: HomePostCell.xibHeight - 140 - 188 /* imgCollectionView height */)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 { //news section
            switch selectedSection {
            case .News:
                print("News cell index: \(indexPath.row)")
                NewsDetailViewController.push(fromView: self, newsID: news[indexPath.row].id!)
                
            case .Posts:
                let currentCell = mainCollectionView.cellForItem(at: indexPath) as! HomePostCell
                print("Selected post cell's artist = \(currentCell.buskerName.text ?? "name's empty?")")
                
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
    
    //Header/footer view
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let section = indexPath.section
            switch section {
            case 1: //News/Post Section
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NewsSectionHeader.reuseIdentifier, for: indexPath) as! NewsSectionHeader
                headerView.delegate = self
                return headerView
                
            default: //case 0 i.e. App Title
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeHeaderView.reuseIdentifier, for: indexPath) as! HomeHeaderView
                return headerView
            }
            
        case UICollectionView.elementKindSectionFooter:
            switch indexPath.section {
            case 1: //News/Post Section
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NewsSectionFooter.reuseIdentifier, for: indexPath) as! NewsSectionFooter
                switch selectedSection {
                case .News:
                    footer.sepLine.alpha = gotMoreNews ? 0 : 1
                    footer.copyrightLabel.alpha = gotMoreNews ? 0 : 1
                    footer.loadingIndicator.alpha = gotMoreNews ? 1 : 0
                    
                    return footer
                    
                case .Posts:
                    footer.sepLine.alpha = gotMorePosts ? 0 : 1
                    footer.copyrightLabel.alpha = gotMorePosts ? 0 : 1
                    footer.loadingIndicator.alpha = gotMorePosts ? 1 : 0
                    
                    return footer
                }
            default: return UICollectionReusableView() //events section
            }
        default:  fatalError("Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 0:  return CGSize(width: mainCollectionView.bounds.width, height: HomeHeaderView.height)
        case 1:  return CGSize(width: mainCollectionView.bounds.width, height: NewsSectionHeader.height)
        default: return CGSize.zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        switch section {
        case 0:  return CGSize.zero
        case 1:  return CGSize(width: UIScreen.main.bounds.width, height: NewsSectionFooter.height)
        default: return CGSize.zero
        }
    }
}

//MARK: - Event sectopm view all btn/cell tapped
extension HomeViewController: EventsSectionDelegate {
    func viewAllBtnTapped() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let eventsVc = storyboard.instantiateViewController(withIdentifier: EventsListViewController.storyboardID)
        
        self.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .cover(direction: .up))
        self.navigationController?.pushViewController(eventsVc, animated: true)
    }
    
    func cellTapped(eventID: String) {
        EventDetailsViewController.push(from: self, eventID: eventID)
    }
}

//MARK: - NewsHeaderSection delegate
extension HomeViewController: NewsSectionHeaderDelegate {
    func newsBtnTapped(sender: UIButton) {
        print("news btn tapped")
        
        if selectedSection != .News {
            news.removeAll()
            mainCollectionView.reloadData()
            gotMoreNews = true
            getNews(limit: newsLimit)
            
            selectedSection = .News
        }
        
    }
    
    func postsBtnTapped(sender: UIButton) {
        print("post btn tapped")
        
        if selectedSection != .Posts {
            posts.removeAll()
            mainCollectionView.reloadData()
            gotMorePosts = true
            getPosts(limit: postsLimit)
            
            selectedSection = .Posts
        }
    }
}

//MARK: - HomePostCell delegate
extension HomeViewController: HomePostCellDelegate {
    func contentLabelTapped(indexPath: IndexPath) {
        isPostCellExpanded[indexPath.row] = !isPostCellExpanded[indexPath.row]
        UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.9, options: .curveEaseInOut, animations: {
            self.mainCollectionView.reloadItems(at: [indexPath])
        }, completion: nil)
        // mainCollectionView.performBatchUpdates(nil, completion: nil)
    }
}

//MARK: - UIScrollView Delegate {
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //toggle tab bar
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            TabBar.toggle(from: self, hidden: true, animated: true)
        } else {
            TabBar.toggle(from: self, hidden: false, animated: true)
        }
        
        if scrollView.contentOffset.y <= 100 {
            TabBar.toggle(from: self, hidden: false, animated: true)
        }
    }
}

//MARK: - Scroll to top when tabbar icon is tapped
extension HomeViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if previousController == viewController || previousController == nil {
            // the same tab was tapped a second time
            let nav = viewController as! UINavigationController
            
            // if in first level of navigation (table view) then and only then scroll to top
            if nav.viewControllers.count < 2 {
                //let vc = nav.topViewController as! HomeViewController
                //tableCont.tableView.setContentOffset(CGPoint(x: 0.0, y: -tableCont.tableView.contentInset.top), animated: true)
                //vc.mainCollectionView.setContentOffset(CGPoint.zero, animated: true)
                mainCollectionView.setContentOffset(CGPoint.zero, animated: true)
            }
        }
        previousController = viewController
        return true
    }
}

//avoid preferredStatusBarStyle not being called
extension UINavigationController {
    override open var childForStatusBarStyle: UIViewController? {
        return self.topViewController
    }
}

//reloadItemsInSection
extension UICollectionView {
    func reloadItems(inSection section: Int) {
        reloadItems(at: (0 ..< numberOfItems(inSection: section)).map {
            IndexPath(item: $0, section: section)
        })
    }
}

//MARK: - UIGestureRecognizerDelegate (i.e. swipe pop gesture)
extension HomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - Selected section enum
enum HomeSelectedSection {
    case News
    case Posts
}
