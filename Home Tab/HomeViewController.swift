//
//  HomeViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import SDWebImage
import Localize_Swift

class HomeViewController: UIViewController, UIGestureRecognizerDelegate {
    
    var coverImagesUrl: [String] = []
    var news: [News] = []
    var cellType: Int?
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        
        self.tabBarController?.delegate = self
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        
        mainCollectionView.backgroundColor = .darkGray()
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.showsHorizontalScrollIndicator = false
        
        mainCollectionView.register(UINib.init(nibName: "HeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "EventsSection", bundle: nil), forCellWithReuseIdentifier: EventsSection.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "NewsHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NewsHeaderView.reuseIdentifier)
        
        mainCollectionView.register(UINib.init(nibName: "NewsCellType1", bundle: nil), forCellWithReuseIdentifier: NewsCellType1.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType2", bundle: nil), forCellWithReuseIdentifier: NewsCellType2.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType3", bundle: nil), forCellWithReuseIdentifier: NewsCellType3.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType4", bundle: nil), forCellWithReuseIdentifier: NewsCellType4.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsCellType5", bundle: nil), forCellWithReuseIdentifier: NewsCellType5.reuseIdentifier)
        
        fetchNews()
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
        
        //transparent navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func fetchNews(){
        NewsService.fetchNews().done{ news -> () in
            self.news = news.list!
            
            //            for news in self.news{
            //                for tag in news.hashtags{
            //                    self.coverImagesUrl.append(tag)
            //                    print(self.coverImagesUrl)
            //                }
            //            }
            
            self.mainCollectionView.reloadData()
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }

}

// MARK: UICollectionView Data Source
extension HomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 { return 1 } else {
            let count = news.isEmpty ? 2 : news.count
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
            return cell
        } else { //news section
            if !news.isEmpty { self.cellType = news[indexPath.row].cellType! }
            
            switch cellType {
            case 1:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType1.reuseIdentifier, for: indexPath) as! NewsCellType1
                
                Hashtags.create(position: .top, dataSource: news[indexPath.row].hashtags, toCell: cell, multiLines: true, solidColor: true)
                cell.newsTitle.text = news[indexPath.row].title
                cell.bgImgView.sd_imageTransition = .fade
                if let url = URL(string: news[indexPath.row].coverImages[0].secureUrl!){
                    cell.bgImgView.sd_setImage(with: url, completed: nil)
                }
                
                return cell
            case 2:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType2.reuseIdentifier, for: indexPath) as! NewsCellType2
                
                Hashtags.create(position: .bottom, dataSource: news[indexPath.row].hashtags, toCell: cell, solidColor: true)
                cell.newsTitle.text = news[indexPath.row].title
                cell.bgImgView.sd_imageTransition = .fade
                if let url = URL(string: news[indexPath.row].coverImages[0].secureUrl!){
                    cell.bgImgView.sd_setImage(with: url, completed: nil)
                }
                
                return cell
            case 3:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType3.reuseIdentifier, for: indexPath) as! NewsCellType3
                
                Hashtags.create(position: .top, dataSource: news[indexPath.row].hashtags, toCell: cell, solidColor: true)
                cell.newsTitle.text = news[indexPath.row].title
                cell.subTitle.text = news[indexPath.row].subTitle
                
                cell.bgImgView.sd_imageTransition = .fade
                if let url = URL(string: news[indexPath.row].coverImages[0].secureUrl!){
                    cell.bgImgView.sd_setImage(with: url, completed: nil)
                }
                
                return cell
            case 4:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType4.reuseIdentifier, for: indexPath) as! NewsCellType4
                
                for view in cell.skeletonViews{ //hide all skeleton views because template 4 is the default template
                    if view.tag == 2{ //remove dummyTagLabel
                        view.removeFromSuperview()
                    }
                    view.hideSkeleton()
                }
                
                cell.gradientBg.startAnimation()
                Hashtags.create(position: .top, dataSource: news[indexPath.row].hashtags, toCell: cell)
                cell.newsTitle.text = news[indexPath.row].title
                cell.subTitle.text = news[indexPath.row].subTitle
                
                return cell
            case 5:
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType5.reuseIdentifier, for: indexPath) as! NewsCellType5
                
                Hashtags.create(position: .top, dataSource: news[indexPath.row].hashtags, toCell: cell)
                cell.newsTitle.text = news[indexPath.row].title
                cell.subTitle.text = news[indexPath.row].subTitle
                
                return cell
            default: //loading template
                let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: NewsCellType4.reuseIdentifier, for: indexPath) as! NewsCellType4
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = self.view.frame.width
        // Upcoming events section
        if indexPath.section == 0 { return CGSize(width: width, height: EventsSection.height)} else {
            // News section
            if !news.isEmpty { self.cellType = news[indexPath.row].cellType! }
            switch cellType {
            case 1, 2:  return CGSize(width: NewsCellType1.cellWidth, height: NewsCellType1.cellHeight)
            default:    return CGSize(width: NewsCellType3.cellWidth, height: NewsCellType3.cellHeight)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 1{
            print("\(indexPath.row)")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        } else {
            return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: mainCollectionView.bounds.width, height: HeaderView.height)
        } else {
            return CGSize(width: mainCollectionView.bounds.width, height: NewsHeaderView.height)
        }
    }
    
    //Header view
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let section = indexPath.section
            switch section {
            case 1:
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: NewsHeaderView.reuseIdentifier, for: indexPath) as! NewsHeaderView
                return reusableview
            default: //case 0
                let reusableview = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as! HeaderView
                reusableview.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: HeaderView.height)
                return reusableview
            }
        default:  fatalError("Unexpected element kind")
        }
    }
}

extension HomeViewController: EventsSectionDelegate {
    func viewAllBtnTapped() {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let eventsVc = storyBoard.instantiateViewController(withIdentifier: "eventsVc")
        
        self.navigationItem.title = "Events"
        self.navigationController?.pushViewController(eventsVc, animated: true)
    }
}

//Scroll to top when tabbar icon is tapped
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
