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

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var coverImagesUrl: [String] = []
    var newsList: [News] = []
    var posts: [Post] = []
    var numberOfNews = 8 //news limit per request
    var hasMoreNews = true
    var cellType: Int?
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()

        //check if we need to present loginVC
        if UserService.User.isLoggedIn() == false {
            let loginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
//            loginVC.hero.isEnabled = true
//            loginVC.hero.modalAnimationType = .selectBy(presenting: .zoom, dismissing: .zoomOut)
            self.present(loginVC, animated: true, completion: nil)
        }
        
        self.tabBarController?.delegate = self
        
        mainCollectionView.isUserInteractionEnabled = false
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
        
        mainCollectionView.register(UINib.init(nibName: "NewsSectionFooter", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NewsSectionFooter.reuseIdentifier)
        
        getNews(limit: numberOfNews)
        getPosts()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func getNews(skip: Int? = nil, limit: Int? = nil) {
        NewsService.getList(skip: skip, limit: limit).done { response -> () in
            //self.newsList = response.list
            self.newsList.append(contentsOf: response.list)
            if response.list.count < self.numberOfNews || response.list.count == 0 {
                self.hasMoreNews = false
            }
            
            //            for news in self.news{
            //                for tag in news.hashtags{
            //                    self.coverImagesUrl.append(tag)
            //                    print(self.coverImagesUrl)
            //                }
            //            }
            
            self.mainCollectionView.reloadData()
            }.ensure {
                self.mainCollectionView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }

    private func getPosts(skip: Int? = nil, limit: Int? = nil) {
        PostService.getList(skip: skip, limit: limit).done { response -> () in
            //self.newsList = response.list
            self.posts.append(contentsOf: response.list)

            print(self.posts[0].content!)
            
            //self.mainCollectionView.reloadData()
            }.ensure {
                //self.mainCollectionView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
}

// MARK: UICollectionView Delegate
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 } else {
            let count = newsList.isEmpty ? 2 : newsList.count
            return count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 { //events section
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: EventsSection.reuseIdentifier, for: indexPath) as! EventsSection
            cell.delegate = self
            cell.eventsCollectionView.reloadData()
            return cell
        } else { //news section
            if !newsList.isEmpty { self.cellType = newsList[indexPath.row].cellType! }
            
            switch cellType {
            case 1:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType1.reuseIdentifier, for: indexPath) as! NewsCellType1
                
                //Hashtag.createAtCell(cell: cell, position: .cellTop, dataSource: newsList[indexPath.row].hashtags, multiLines: true, solidColor: true)
                cell.newsTitle.text = newsList[indexPath.row].title
                cell.hashtagsArray = newsList[indexPath.row].hashtags
                //cell.bgImgView.sd_imageTransition = .fade
                if let url = URL(string: newsList[indexPath.row].coverImages[0].secureUrl!){
                    cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.4))])
                }
                
                return cell
            case 2:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType2.reuseIdentifier, for: indexPath) as! NewsCellType2
                
                cell.newsTitle.text = newsList[indexPath.row].title
                cell.hashtagsArray = newsList[indexPath.row].hashtags
                
                if let url = URL(string: newsList[indexPath.row].coverImages[0].secureUrl!){
                    cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.4))])
                }
                
                return cell
            case 3:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType3.reuseIdentifier, for: indexPath) as! NewsCellType3
                
                cell.newsTitle.text = newsList[indexPath.row].title
                cell.subTitle.text = newsList[indexPath.row].subTitle
                cell.hashtagsArray = newsList[indexPath.row].hashtags

                if let url = URL(string: newsList[indexPath.row].coverImages[0].secureUrl!){
                    cell.bgImgView.kf.setImage(with: url, options: [.transition(.fade(0.4))])
                }
                
                return cell
            case 4:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType4.reuseIdentifier, for: indexPath) as! NewsCellType4
                
                for view in cell.skeletonViews{ //hide all skeleton views because template 4 is the default template
                    if view.tag == 2 { //remove dummyTagLabel
                        view.removeFromSuperview()
                    }
                    view.hideSkeleton()
                }
                
                cell.gradientBg.startAnimation()
                cell.viewsLabel.isHidden = false
                cell.newsTitle.text = newsList[indexPath.row].title
                cell.subTitle.text = newsList[indexPath.row].subTitle
                cell.hashtagsArray = newsList[indexPath.row].hashtags
                
                return cell
            case 5:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType5.reuseIdentifier, for: indexPath) as! NewsCellType5
                
                cell.newsTitle.text = newsList[indexPath.row].title
                cell.subTitle.text = newsList[indexPath.row].subTitle
                cell.hashtagsArray = newsList[indexPath.row].hashtags

                return cell
            default: //loading template
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType4.reuseIdentifier, for: indexPath) as! NewsCellType4
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == newsList.count - 1 ) {
            print("need to fetch!")

            hasMoreNews ? getNews(skip: self.newsList.count, limit: numberOfNews) : print("fetched all news!")

            //if hasMoreNews { getNews(skip: self.newsList.count, limit: numberOfNews) } else { print("fetched all news!") }
        }
        
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType3.reuseIdentifier, for: indexPath) as! NewsCellType3
        
        cell.subTitle.restartLabel()

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        // Upcoming events section
        if indexPath.section == 0 { return CGSize(width: width, height: EventsSection.height) } else {
            // News section
            if !newsList.isEmpty { self.cellType = newsList[indexPath.row].cellType! }
            switch cellType {
            case 1, 2:  return CGSize(width: NewsCellType1.width, height: NewsCellType1.height)
            default:    return CGSize(width: NewsCellType3.width, height: NewsCellType3.height)
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
    }
    
    func postsBtnTapped(sender: UIButton) {
        print("post btn tapped")
        //let indexSet = IndexSet(integer: 1)
        mainCollectionView.reloadItems(inSection: 1)
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
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        
        print(tabBarIndex)
        
        if tabBarIndex == 0 {
            mainCollectionView.setContentOffset(CGPoint.zero, animated: true)
        }
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
