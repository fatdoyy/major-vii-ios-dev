//
//  BuskersViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Kingfisher
import NVActivityIndicatorView

protocol BuskersViewControllerDelegate: AnyObject {
    func searchWithQuery(_ query: String)
}

class BuskersViewController: UIViewController {
    //weak var previousController: UIViewController? //for tabbar scroll to top
    weak var delegate: BuskersViewControllerDelegate?
    
    var indicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 5, height: 5)), type: .lineScale)
    
    var mainCollectionView: UICollectionView!
    var skeletonCollectionView: UICollectionView!
    
    var searchTask: DispatchWorkItem? //avoid live search throttle
    var searchController: UISearchController!
    
    var buskers = [OrganizerProfile]() {
        didSet {
            imgHeight.removeAll()
            for busker in buskers {
                let height = (busker.coverImages[0].height)! / 2
                imgHeight.append(height)
            }
            print("imgHeight = \(imgHeight)")

            if mainCollectionView == nil {
                setupMainCollectionView()
            } else {
                mainCollectionView.reloadData()
            }
            
            skeletonCollectionView.removeFromSuperview()
        }
    }
    var imgHeight = [CGFloat]()
    var buskersLimit = 6
    var gotMoreBuskers = true
    
    var scaledImgArray = [UIImage]()
    var randomColor = [UIColor]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .m7DarkGray()
        hideKeyboardWhenTappedAround()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        //tabBarController?.delegate = self
        
        setupNavBar()
        setupUI()
        getBuskersByTrend(limit: buskersLimit)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.setObserver(self, selector: #selector(updateSearchBarText), name: .updateSearchBarText, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(hideSearchBarIndicator), name: .hideSearchBarIndicator, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(dismissSearchBarKeyboard), name: .dismissKeyboard, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //status bar color
        UIApplication.shared.statusBarUIView?.backgroundColor = UIColor.m7DarkGray().withAlphaComponent(0.8)
        
        //nav bar handle
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = UIColor.m7DarkGray().withAlphaComponent(0.8)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //status bar color
        UIApplication.shared.statusBarUIView?.backgroundColor = .clear
        
        //nav bar handle
        navigationController?.navigationBar.backgroundColor = .clear
    }
}

//MARK: - API Calls
extension BuskersViewController {
    func getBuskersByTrend(skip: Int? = nil, limit: Int? = nil) {
        //mainCollectionView.isUserInteractionEnabled = false
        BuskerService.getBuskersByTrend(skip: skip, limit: limit).done { response in
            let randomArr = response.list.shuffled()
            self.buskers.append(contentsOf: randomArr)
            for _ in 0 ..< self.buskers.count {
                self.randomColor.append(UIColor.random)
            }
            self.gotMoreBuskers = response.list.count < self.buskersLimit || response.list.count == 0 ? false : true
            }.ensure {
                //self.mainCollectionView.isUserInteractionEnabled = true
                
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
}

//MARK: - Search Controller setup
extension BuskersViewController {
    private func setupSearchController() {
        let searchResultsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "buskersSearchVC") as! BuskersSearchViewController

        print("setting up searchController...")
        searchResultsVC.delegate = self
        searchResultsVC.buskerVCInstance = self
        searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.delegate = self
        searchController.searchResultsUpdater = searchResultsVC
        searchController.searchBar.delegate = self
        searchController.searchBar.tintColor = .white
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.backgroundColor = UIColor.m7DarkGray().withAlphaComponent(0.8)
        searchController.searchResultsController?.view.addObserver(self, forKeyPath: "hidden", options: [], context: nil)
        setupKeyboardToolbar()
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [.foregroundColor: UIColor.white]
        
        if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            //setup UI
            if let backgroundview = textfield.subviews.first {
                // Rounded corner
                backgroundview.layer.cornerRadius = GlobalCornerRadius.value / 1.2
                backgroundview.clipsToBounds = true
            }
            
            //add target to detect input and search in real time
            textfield.addTarget(self, action: #selector(searchWithQuery), for: .editingChanged)
        }
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func setupKeyboardToolbar() {
        let toolbar = UIToolbar(frame:CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolbar.barStyle = .black
        
        let dismissBtn = UIButton(type: .custom)
        dismissBtn.setImage(UIImage(named: "imagename"), for: .normal)
        dismissBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        dismissBtn.setImage(UIImage(named: "icon_dismiss_keyboard"), for: .normal)
        dismissBtn.addTarget(self, action: #selector(dismissSearchBarKeyboard), for: .touchUpInside)
        
        let item = UIBarButtonItem(customView: dismissBtn)
        toolbar.items = [item]
        searchController.searchBar.inputAccessoryView = toolbar
    }

    @objc func dismissSearchBarKeyboard() {
        searchController.searchBar.endEditing(true)
    }
    
    //Do search action whenever user types
    @objc func searchWithQuery() {
        if let query = searchController.searchBar.text {
            if !query.isEmpty {
                searchController.searchBar.isLoading = true //show indicator
                
                //Cancel previous task if any
                self.searchTask?.cancel()
                
                //Replace previous task with a new one
                let newTask = DispatchWorkItem { [weak self] in
                    self?.delegate?.searchWithQuery(query)
                }
                self.searchTask = newTask
                
                //Execute task in 0.3 seconds (if not cancelled !)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: newTask)
            }
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let someView: UIView = object as! UIView? {
            if (someView == self.searchController.searchResultsController?.view && (keyPath == "hidden") && (searchController.searchResultsController?.view.isHidden)! && searchController.searchBar.isFirstResponder) {
                searchController.searchResultsController?.view.isHidden = false
            }
        }
    }
    
}

//MARK: - Update Search Bar State
extension BuskersViewController {
    @objc func updateSearchBarText(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            searchController.searchBar.text = userInfo["text"] as? String
            searchController.searchBar.isLoading = true
        }
    }
    
    @objc func hideSearchBarIndicator() {
        searchController.searchBar.isLoading = false
    }
}

//MARK: - UI related
extension BuskersViewController {
    private func setupUI() {
        self.setupSearchController()

//        DispatchQueue.background(background: {
//            self.setupSearchController()
//        }, completion:{
//            print("loaded searchController")
//            UIView.animate(withDuration: 0.2, animations: {
//                self.view.setNeedsDisplay()
//            })
//        })

        setupSkeletonCollectionView()
        skeletonCollectionView.reloadData()
    }
    
    private func setupSkeletonCollectionView() {
        let layout = PinterestLayout()
        layout.delegate = self
        
        skeletonCollectionView = UICollectionView(frame: CGRect(origin: .zero, size: .zero), collectionViewLayout: layout)
        skeletonCollectionView.showsVerticalScrollIndicator = false
        skeletonCollectionView.isUserInteractionEnabled = false
        skeletonCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        skeletonCollectionView.backgroundColor = .m7DarkGray()
        skeletonCollectionView.dataSource = self
        skeletonCollectionView.delegate = self
        skeletonCollectionView.register(UINib.init(nibName: "BuskerCell", bundle: nil), forCellWithReuseIdentifier: BuskerCell.reuseIdentifier)
        skeletonCollectionView.register(UINib.init(nibName: "NewsSectionFooter", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NewsSectionFooter.reuseIdentifier)
        view.addSubview(skeletonCollectionView)
        skeletonCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalTo(0)
        }
    }
    
    private func setupMainCollectionView() {
        let layout = PinterestLayout()
        layout.delegate = self
        //layout.footerReferenceSize = CGSize(width: UIScreen.main.bounds.width, height: NewsSectionFooter.height)
        
        mainCollectionView = UICollectionView(frame: CGRect(origin: .zero, size: .zero), collectionViewLayout: layout)
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        mainCollectionView.backgroundColor = .m7DarkGray()
        mainCollectionView.contentInsetAdjustmentBehavior = .always
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.register(UINib.init(nibName: "BuskerCell", bundle: nil), forCellWithReuseIdentifier: BuskerCell.reuseIdentifier)
        mainCollectionView.register(UINib.init(nibName: "NewsSectionFooter", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NewsSectionFooter.reuseIdentifier)
        view.addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
    }
    
    private func setupNavBar() {
        definesPresentationContext = true
        navigationItem.title = "Performers"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

//MARK: - UICollectionview delegate
extension BuskersViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case skeletonCollectionView:    return 6
        case mainCollectionView:    return buskers.count
        default:                    return 6
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case skeletonCollectionView:
            let cell = skeletonCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerCell.reuseIdentifier, for: indexPath) as! BuskerCell
            return cell
            
        case mainCollectionView:
            let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerCell.reuseIdentifier, for: indexPath) as! BuskerCell
            if !buskers.isEmpty {
                for view in cell.skeletonViews { //hide all skeleton views
                    view.hideSkeleton()
                }
                
                //Gradient.createOverlay(cell: cell, imgHeight: imgHeight[indexPath.row])
                
                let profile = buskers[indexPath.row]
                if let url = URL(string: profile.coverImages[0].url!) {
                    cell.imgView.kf.setImage(with: url, options: [.transition(.fade(0.3))])
                }
                
                cell.buskerName.text = profile.name
                
                if profile.genreCodes.count > 1 && !profile.genreCodes.isEmpty { //more than one genre
                    var genreStr = "\(profile.genreCodes.first?.replacingOccurrences(of: "_", with: "-") ?? "")" //assign the first genre to string first
                    var genreCodes = profile.genreCodes
                    genreCodes.removeFirst() //then remove first genre and append the remainings
                    for genreCode in genreCodes {
                        let genre = genreCode.replacingOccurrences(of: "_", with: "-")
                        genreStr.append(", \(genre)")
                    }
                    cell.genre.text = genreStr.lowercased()
                } else if profile.genreCodes.count == 1 {
                    cell.genre.text = profile.genreCodes.first?.replacingOccurrences(of: "_", with: "-").lowercased()
                } else if profile.genreCodes.isEmpty {
                    cell.genre.text = ""
                }
                
                cell.genre.textColor = randomColor[indexPath.row]
                cell.verifiedIcon.alpha = profile.verified ?? true ? 1 : 0
                
            }
            return cell
            
        default: return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == mainCollectionView {
            if (indexPath.row == buskers.count - 1) {
                print("Fetching buskers...")
                gotMoreBuskers ? getBuskersByTrend(skip: buskers.count, limit: buskersLimit) : print("No more buskers to fetch!")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionFooter:
            let footer = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: NewsSectionFooter.reuseIdentifier, for: indexPath) as! NewsSectionFooter
            footer.sepLine.alpha = gotMoreBuskers ? 0 : 1
            footer.copyrightLabel.alpha = gotMoreBuskers ? 0 : 1
            footer.loadingIndicator.alpha = gotMoreBuskers ? 1 : 0
            
            return footer
        default: return UICollectionReusableView()
        }
    }


//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width, height: NewsSectionFooter.height)
//    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mainCollectionView {
            BuskerProfileViewController.push(from: self, buskerName: buskers[indexPath.row].name ?? "", buskerID: buskers[indexPath.row].id ?? "")
        }
    }
    
    //PinterestLayout delegate
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        switch collectionView {
        case skeletonCollectionView:    return 220
        case mainCollectionView:    return imgHeight[indexPath.row]
        default:                    return 220
        }
    }
    
}

//MARK: - UISearchControllerDelegate Delegate
extension BuskersViewController: UISearchControllerDelegate, UISearchBarDelegate, BuskersSearchViewControllerDelegate {
    func reassureShowingVC() {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        //TabBar.hide(from: self)
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        print("Tapped search bar")
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        //Do search action when user tap search button
        print("Ended search?")
        searchController.searchBar.isLoading = false
//        if let string = searchController.searchBar.text {
//            delegate?.searchWith(query: string, instance: self)
//        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.count == 0) {
            //searchController.searchResultsController?.view.isHidden = false
            NotificationCenter.default.post(name: .showSCViews, object: nil)
        } else {
            NotificationCenter.default.post(name: .hideSCViews, object: nil)
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        //searchBar.text = ""
        //searchController.searchResultsController?.view.isHidden = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        NotificationCenter.default.post(name: .showSCViews, object: nil)
    }
}

//MARK: - UIScrollView Delegate
extension BuskersViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //toggle tab bar
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
            TabBar.toggle(from: self, hidden: true, animated: true)
        } else {
            TabBar.toggle(from: self, hidden: false, animated: true)
        }
        
        if scrollView.contentOffset.y <= 0 {
            TabBar.toggle(from: self, hidden: false, animated: true)
        }
    }
}

//MARK: - UIGestureRecognizerDelegate (i.e. swipe pop gesture)
extension BuskersViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//MARK: - Scroll to top when tabbar icon is tapped
//extension BuskersViewController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if previousController == viewController || previousController == nil {
//            // the same tab was tapped a second time
//            let nav = viewController as! UINavigationController
//
//            // if in first level of navigation (table view) then and only then scroll to top
//            if nav.viewControllers.count < 2 {
//                //let vc = nav.topViewController as! HomeViewController
//                //tableCont.tableView.setContentOffset(CGPoint(x: 0.0, y: -tableCont.tableView.contentInset.top), animated: true)
//                //vc.mainCollectionView.setContentOffset(CGPoint.zero, animated: true)
//                mainCollectionView.setContentOffset(CGPoint(x: 0, y: -44), animated: true)
//
//            }
//        }
//        previousController = viewController;
//        return true
//    }
//}
