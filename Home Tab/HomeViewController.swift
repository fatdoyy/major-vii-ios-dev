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

class HomeViewController: UIViewController {
    weak var previousController: UIViewController? //for tabbar scroll to top
    
    let stringArr: [String] = [ "【突發】聽朝9點 屯門區議會 要人！！！見到有巴打個post潛左突發】聽朝9點 屯門區議會 要人！！！ ", "distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like)."]
    
    var attrStringArr: [NSAttributedString] = []
    
    var customRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = .clear
        refreshControl.tintColor = .clear
        refreshControl.addTarget(self, action: #selector(refreshCollectionView), for: .valueChanged)
        return refreshControl
    }()
    
    var refreshView: RefreshView!
    var refreshIndicator: NVActivityIndicatorView?
    var coverImagesUrl: [String] = []
    
    var selectedSection = HomeSelectedSection.News //default section is "News"
    
    var newsList: [News] = []
    var numberOfNews = 8 //news limit per request
    var hasMoreNews = true //lazy loading
    var isNewsSelected = true
    
    var postsList: [Post] = []
    var numberOfPosts = 8 //news limit per request
    var hasMorePost = true //lazy loading
    var isPostsSelected = false
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        tabBarController?.delegate = self
        mainCollectionView.refreshControl = customRefreshControl
        
        //check if we need to present loginVC
        if UserService.User.isLoggedIn() == false {
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            //            loginVC.hero.isEnabled = true
            //            loginVC.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
            self.present(loginVC, animated: true, completion: nil)
        }
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        
        mainCollectionView.backgroundColor = .darkGray()
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
        
        getNews(limit: numberOfNews)
        getPosts(limit: numberOfPosts)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = ""
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
    
    private func getNews(skip: Int? = nil, limit: Int? = nil) {
        mainCollectionView.isUserInteractionEnabled = false
        NewsService.getList(skip: skip, limit: limit).done { response -> () in
            //self.newsList = response.list
            self.newsList.append(contentsOf: response.list)
            if response.list.count < self.numberOfNews || response.list.count == 0 {
                self.hasMoreNews = false
            }
            self.mainCollectionView.reloadData()
            }.ensure {
                self.mainCollectionView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
                //pull to refresh
                if let refreshView = self.refreshView {
                    refreshView.stopAnimation()
                    self.customRefreshControl.endRefreshing()
                    HapticFeedback.createNotificationFeedback(style: .success)
                } else {
                    self.getRefereshView() //setup pull to refresh view
                }
                
            }.catch { error in }
    }
    
    private func getPosts(skip: Int? = nil, limit: Int? = nil) {
        mainCollectionView.isUserInteractionEnabled = false
        PostService.getList(skip: skip, limit: limit).done { response -> () in
            self.postsList.append(contentsOf: response.list)
            
            for string in self.stringArr {
                let contentAttrString = NSAttributedString(string: string, attributes: TextAttributes.postContentConfig())
                self.attrStringArr.append(contentAttrString)
            }
            
            print(self.postsList[0].authorProfile?.name!)
            
            self.mainCollectionView.reloadData()
            }.ensure {
                self.mainCollectionView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    func getRefereshView() {
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
        
        //get events again
        
        //get news again
        newsList.removeAll()
        mainCollectionView.reloadData()
        hasMoreNews = true
        getNews(limit: numberOfNews)
        
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
            case .News:
                let count = newsList.isEmpty ? 2 : newsList.count
                return count
            case .Posts:
                let count = postsList.isEmpty ? 2 : postsList.count
                return count
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 { //events section
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: EventsSection.reuseIdentifier, for: indexPath) as! EventsSection
            cell.delegate = self
            cell.eventsCollectionView.reloadData()
            return cell
        } else { // news|posts section
            switch selectedSection {
            case .News:
                if !newsList.isEmpty {
                    switch newsList[indexPath.row].cellType! {
                    case 1:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType1.reuseIdentifier, for: indexPath) as! NewsCellType1
                        
                        //Hashtag.createAtCell(cell: cell, position: .cellTop, dataSource: newsList[indexPath.row].hashtags, multiLines: true, solidColor: true)
                        let hashtagsArr = newsList[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr }
                        
                        cell.newsTitle.text = newsList[indexPath.row].title
                        //cell.bgImgView.sd_imageTransition = .fade
                        if let url = URL(string: newsList[indexPath.row].coverImages[0].secureUrl!) {
                            cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                        }
                        
                        return cell
                    case 2:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType2.reuseIdentifier, for: indexPath) as! NewsCellType2
                        
                        let hashtagsArr = newsList[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr }
                        
                        cell.newsTitle.text = newsList[indexPath.row].title
                        
                        if let url = URL(string: newsList[indexPath.row].coverImages[0].secureUrl!) {
                            cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                        }
                        
                        return cell
                    case 3:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType3.reuseIdentifier, for: indexPath) as! NewsCellType3
                        
                        let hashtagsArr = newsList[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr } else {
                            cell.newsTitleTopConstraint.isActive = false
                            cell.newsTitle.snp.remakeConstraints { (make) in
                                make.top.equalTo(25)
                            }
                        }
                        cell.newsTitle.text = newsList[indexPath.row].title
                        cell.subTitle.text = newsList[indexPath.row].subTitle
                        
                        if let url = URL(string: newsList[indexPath.row].coverImages[0].secureUrl!) {
                            cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
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
                        
                        let hashtagsArr = newsList[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr } else {
                            cell.newsTitleTopConstraint.isActive = false
                            cell.newsTitle.snp.remakeConstraints { (make) in
                                make.top.equalTo(25)
                            }
                        }
                        cell.newsTitle.text = newsList[indexPath.row].title
                        cell.subTitle.text = newsList[indexPath.row].subTitle
                        
                        return cell
                    case 5:
                        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType5.reuseIdentifier, for: indexPath) as! NewsCellType5
                        
                        let hashtagsArr = newsList[indexPath.row].hashtags
                        if !hashtagsArr.isEmpty { cell.hashtagsArray = hashtagsArr }
                        
                        cell.newsTitle.text = newsList[indexPath.row].title
                        cell.subTitle.text = newsList[indexPath.row].subTitle
                        
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
                if !postsList.isEmpty {
                    let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.reuseIdentifier, for: indexPath) as! HomePostCell
                    
                    if let url = URL(string: postsList[indexPath.row].authorProfile?.coverImages[0].secureUrl! ?? "") {
                        cell.buskerIcon.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                    }
                    cell.buskerName.text = postsList[indexPath.row].authorProfile?.name
                    //cell.contentLabel.text = stringArr[indexPath.row]
                    cell.contentLabel.attributedText = attrStringArr[indexPath.row]
                    cell.contentLabel.sizeToFit()
                    print("cell height is \(cell.contentLabel.attributedTextHeight(withWidth: HomePostCell.width))")
                    
                    return cell
                } else { // post list is empty
                    let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: HomePostCell.reuseIdentifier, for: indexPath) as! HomePostCell
                    
                    return cell
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == newsList.count - 1 ) {
            print("need to fetch!")
            
            hasMoreNews ? getNews(skip: self.newsList.count, limit: numberOfNews) : print("fetched all news!")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.section == 0 /* Upcoming events section */ { return CGSize(width: view.frame.width, height: EventsSection.height) } else {
            switch selectedSection {
            case .News:
                if !newsList.isEmpty {
                    switch newsList[indexPath.row].cellType! {
                    case 1, 2:  return CGSize(width: NewsCellType1.width, height: NewsCellType1.height) //cell type 1,2 have same height
                    default:    return CGSize(width: NewsCellType3.width, height: NewsCellType3.height) //cell type 3,4,5 have same height
                    }
                } else { //news list is empty
                    return CGSize(width: NewsCellType3.width, height: NewsCellType3.height)
                }
                
            case .Posts: //dynamic cell height (i.e. attributed text height)
                if !postsList.isEmpty {
//                    if let content = postsList[indexPath.row].content {
//                        //let textHeight = content.height(withWidth: HomePostCell.width, font: UIFont())
//                        let attrTextHeight = attrStringArr[indexPath.row].height(withWidth: HomePostCell.width)
//                        print("attrTextHeight is \(attrTextHeight)")
//                        return CGSize(width: HomePostCell.width, height: HomePostCell.height + attrTextHeight + 40)
//                    } else {
//                        return CGSize(width: HomePostCell.width, height: HomePostCell.height)
//                    }
                    let attrTextHeight = attrStringArr[indexPath.row].height(withWidth: HomePostCell.width)
                    print("attrTextHeight is \(attrTextHeight)")
                    return CGSize(width: HomePostCell.width, height: HomePostCell.height + attrTextHeight + 40)
                } else { //news list is empty
                    return CGSize(width: HomePostCell.width, height: HomePostCell.height)
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1 { //news section
            print("News cell index: \(indexPath.row)")
            NewsDetailViewController.push(fromView: self, newsId: newsList[indexPath.row].id!)
            
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
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NewsSectionHeader.reuseIdentifier, for: indexPath) as! NewsSectionHeader
                reusableView.delegate = self
                return reusableView
                
            default: //case 0 i.e. App Title
                let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeHeaderView.reuseIdentifier, for: indexPath) as! HomeHeaderView
                return reusableView
            }
            
        case UICollectionView.elementKindSectionFooter:
            let section = indexPath.section
            switch section {
            case 1: //News/Post Section
                let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NewsSectionFooter.reuseIdentifier, for: indexPath) as! NewsSectionFooter
                
                footer.sepLine.alpha = hasMoreNews ? 0 : 1
                footer.copyrightLabel.alpha = hasMoreNews ? 0 : 1
                footer.loadingIndicator.alpha = hasMoreNews ? 1 : 0
                
                return footer
                
            default: return UICollectionReusableView()
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

//View all btn/cell tapped
extension HomeViewController: EventsSectionDelegate {
    
    func viewAllBtnTapped() {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let eventsVc = storyboard.instantiateViewController(withIdentifier: EventsListViewController.storyboardId)
        
        self.navigationItem.title = "Events"
        self.navigationController?.hero.navigationAnimationType = .cover(direction: .up)
        self.navigationController?.pushViewController(eventsVc, animated: true)
    }
    
    func cellTapped(eventId: String) {
        EventDetailsViewController.push(from: self, eventId: eventId)
    }
}

//NewsHeaderSection delegate
extension HomeViewController: NewsSectionHeaderDelegate {
    func newsBtnTapped(sender: UIButton) {
        print("news btn tapped")
        
        if selectedSection != .News {
            newsList.removeAll()
            mainCollectionView.reloadData()
            hasMoreNews = true
            getNews(limit: numberOfNews)
            
            selectedSection = .News
        }

    }
    
    func postsBtnTapped(sender: UIButton) {
        print("post btn tapped")
        
        if selectedSection != .Posts {
            postsList.removeAll()
            mainCollectionView.reloadData()
            hasMorePost = true
            getPosts(limit: numberOfPosts)
            
            selectedSection = .Posts
        }
    }
}

//MARK: UIScrollView Delegate {
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

//MARK: Scroll to top when tabbar icon is tapped
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
        previousController = viewController;
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

//MARK: UIGestureRecognizerDelegate (i.e. swipe pop gesture)
extension HomeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: Selected section enum
enum HomeSelectedSection {
    case News
    case Posts
}
