//
//  NewsDetailViewController.swift
//  major-7-ios
//
//  Created by jason on 15/2/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import CHIPageControl
import SkeletonView
import NVActivityIndicatorView
import InfiniteLayout

class NewsDetailViewController: UIViewController {

    static let storyboardId = "newsDetailVC"

    //newsId
    var newsId = "" {
        didSet {
            getDetails(newsId: newsId)
        }
    }
    
    //news details
    var details : NewsDetails? {
        didSet {
            imgCollectionView.reloadData()
            loadUpperDetails()
            loadLowerDetails()
        }
    }

    var loadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 15, height: 15)), type: .lineScale)
    
    let detailUpperView = UIView()
    var imgCollectionView: InfiniteCollectionView!
    let pageControl = CHIPageControlJalapeno(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
    let imgOverlay = UIView()
    var titleLabel = UILabel()
    var descLabel = UILabel()
    var viewsLabel = UILabel()
    var swipeUpImg = UIImageView()
    var swipeUpLabel = UILabel()

    let detailLowerView = UIView()
    var pageSize = CGSize()
    var descString = ""
    let contentLabel = UILabel()
    var contentLabelHeight : CGFloat = 0.0
    var sepLine = UIView()
    var copyrightLabel = UILabel()
    
    //let detailViews = [detailUpperView, detailLowerView]
    var detailViews = [UIView]() //upper + lower view
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    private func getDetails(newsId: String) {
        NewsService.getDetails(newsId: newsId).done { details -> () in
            self.details = details
            
            }.ensure {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.isSkeletonable = true
        
        updatesStatusBarAppearanceAutomatically = true
        view.backgroundColor = .darkGray()
        mainScrollView.delegate = self
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.isPagingEnabled = true
        
        if #available(iOS 11.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        }
        
        setupLeftBarItems()
        //setupNavBarTitle()
        
        pageSize = view.bounds.size

        setupUpperViewUI()
        setupLowerViewUI()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //transparent navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.barTintColor = .darkGray()
        navigationController?.navigationBar.isTranslucent = true
        TabBar.hide(from: self)
        
        loadingIndicator.startAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBar.show(from: self)
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
    
    private func setupNavBarTitle() {
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: 50, height: 40))
        label.backgroundColor = .red
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        label.text = "My title"
        label.numberOfLines = 2
        label.textColor = .black
        label.sizeToFit()
        label.textAlignment = .center
        
        self.navigationItem.titleView = label
    }
    
    @objc private func popView() {
        navigationController?.popViewController(animated: true)
    }

}

//MARK: Upper view UI
extension NewsDetailViewController {
    private func setupUpperViewUI() {
        detailUpperView.backgroundColor = .darkGray()

        setupImgCollectionView()
        setupOverlay()
        setupLabels()
        setupPageControl()
        
        detailViews.append(detailUpperView)
        mainScrollView.addSubview(detailUpperView)
        detailUpperView.frame = CGRect(origin: CGPoint.zero, size: pageSize)
        
        //setup scrollView content size
        mainScrollView.contentSize = CGSize(width: pageSize.width, height: pageSize.height)
    }
    
    private func setupImgCollectionView() {
        //image collection view
        //let layout: UICollectionViewFlowLayout = PagedCollectionViewLayout()
        let layout: UICollectionViewFlowLayout = InfiniteLayout()
        layout.itemSize = pageSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        imgCollectionView = InfiniteCollectionView(frame: self.view.frame, collectionViewLayout: layout)
        imgCollectionView.backgroundColor = .darkGray()
        imgCollectionView.isItemPagingEnabled = true
        //imgCollectionView.preferredCenteredIndexPath = nil
        imgCollectionView.dataSource = self
        imgCollectionView.delegate = self
        imgCollectionView.showsHorizontalScrollIndicator = false
        imgCollectionView.register(UINib.init(nibName: "NewsDetailImageCell", bundle: nil), forCellWithReuseIdentifier: NewsDetailImageCell.reuseIdentifier)
        detailUpperView.addSubview(imgCollectionView)
    }
    
    private func setupLabels() {
        swipeUpLabel.textAlignment = .center
        swipeUpLabel.numberOfLines = 1
        swipeUpLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        swipeUpLabel.textColor = .lightGrayText()
        swipeUpLabel.text = "Loading Content..."
        detailUpperView.insertSubview(swipeUpLabel, aboveSubview: imgOverlay)
        swipeUpLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(detailUpperView.snp.bottom).offset(UIDevice.current.hasHomeButton ? -20 : -40)
            make.width.equalTo(detailUpperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        
        detailUpperView.insertSubview(loadingIndicator, aboveSubview: imgOverlay)
        loadingIndicator.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.size.equalTo(15)
            make.bottom.equalTo(swipeUpLabel.snp.top).offset(-10)
        }
        
        swipeUpImg.alpha = 0
        swipeUpImg.image = UIImage(named: "icon_swipe_up")
        detailUpperView.insertSubview(swipeUpImg, aboveSubview: imgOverlay)
        swipeUpImg.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.size.equalTo(25)
            make.bottom.equalTo(swipeUpLabel.snp.top).offset(-10)
        }
        swipeUpImg.bounceUpRepeat()
        
        viewsLabel.alpha = 0
        viewsLabel.textAlignment = .left
        viewsLabel.numberOfLines = 1
        viewsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        viewsLabel.textColor = .topazText()
        detailUpperView.insertSubview(viewsLabel, aboveSubview: imgOverlay)
        viewsLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(swipeUpImg.snp.top).offset(-15)
            make.width.equalTo(detailUpperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            //make.height.equalTo(16)
        }
        
        descLabel.alpha = 0
        descLabel.textAlignment = .left
        descLabel.numberOfLines = 0
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descLabel.textColor = .lightGrayText()
        detailUpperView.insertSubview(descLabel, aboveSubview: imgOverlay)
        descLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(viewsLabel.snp.top).offset(-20)
            make.width.equalTo(detailUpperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        
        titleLabel.alpha = 0
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .white
        detailUpperView.insertSubview(titleLabel, aboveSubview: imgOverlay)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(descLabel.snp.top).offset(-10)
            make.width.equalTo(detailUpperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        
    }
    
    private func setupPageControl() {
        pageControl.alpha = 0
        pageControl.numberOfPages = 3
        pageControl.radius = 5
        pageControl.tintColor = .white
        pageControl.currentPageTintColor = .white
        pageControl.padding = 8
        detailUpperView.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-15)
        }
    }
    
    private func setupOverlay() {
        imgOverlay.isUserInteractionEnabled = false
        imgOverlay.backgroundColor = .clear
        imgOverlay.layer.insertSublayer(GradientLayer.create(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height / 3) * 2)), colors: [.darkGray(), .clear], startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0)), at: 0)
        detailUpperView.addSubview(imgOverlay)
        imgOverlay.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(detailUpperView.snp.bottom)
            make.width.equalTo(detailUpperView.snp.width)
            make.height.equalTo((UIScreen.main.bounds.height / 3) * 2)
        }
    }
    
    private func loadUpperDetails() {
        if details != nil {
            if let newsDetails = self.details?.item {
                imgCollectionView.infiniteLayout.isEnabled = newsDetails.coverImages.count > 1
                pageControl.numberOfPages = newsDetails.coverImages.count
                titleLabel.text = newsDetails.title
                descLabel.text = newsDetails.subTitle
                //viewsLabel.text
            }
        }
        
        UIView.animate(withDuration: 0.5) {
            self.pageControl.alpha = 1
            self.titleLabel.alpha = 1
            self.descLabel.alpha = 1
            self.viewsLabel.alpha = 1
        }

    }
}

//MARK: Content View UI
extension NewsDetailViewController {

    private func setupLowerViewUI() {
        detailLowerView.backgroundColor = .darkGray()
    }
    
    private func loadLowerDetails() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            UIView.animate(withDuration: 0.75) {
                self.loadingIndicator.alpha = 0
                self.swipeUpImg.alpha = 1
            }
            
            self.swipeUpLabel.fadeTransition(0.75)
            self.swipeUpLabel.text = "Swipe Up For More Details"
        }

        copyrightLabel.textAlignment = .center
        copyrightLabel.numberOfLines = 1
        copyrightLabel.font = UIFont.systemFont(ofSize: 10, weight: .medium)
        copyrightLabel.textColor = .lightGrayText()
        copyrightLabel.text = "Copyright © 2019 | Major VII | ALL RIGHTS RESERVED"
        detailLowerView.addSubview(copyrightLabel)
        copyrightLabel.snp.makeConstraints { (make) -> Void in
            make.bottom.equalToSuperview().offset(UIDevice.current.hasHomeButton ? -20 : -40)
            make.centerX.equalTo(detailLowerView)
            make.width.equalTo(detailLowerView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        
        sepLine.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        sepLine.layer.cornerRadius = 0.2
        detailLowerView.addSubview(sepLine)
        sepLine.snp.makeConstraints { (make) -> Void in
            make.centerX.equalTo(detailLowerView)
            make.bottom.equalTo(copyrightLabel.snp.top).offset(-20)
            make.width.equalTo(detailLowerView.snp.width).inset(UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 40))
            make.height.equalTo(2)
        }
        
        if let newsDetails = details?.item {
            descString = newsDetails.content!
        } else {
            descString = "default content"
        }
            
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.lineBreakMode = .byTruncatingTail

        let myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.whiteText(), NSAttributedString.Key.paragraphStyle: paragraphStyle]
        
        // create attributed string
        let descAttrString = NSAttributedString(string: descString, attributes: myAttribute)
        
        // set attributed text on a UILabel
        contentLabel.attributedText = descAttrString
        contentLabel.sizeToFit()
        //contentLabel.textColor = .white
        //contentLabel.text =
        contentLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        detailLowerView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalToSuperview().offset(UIDevice.current.hasHomeButton ? 80 : 100)
            make.leftMargin.equalTo(20)
            make.rightMargin.equalTo(-20)
        }
        
        detailViews.append(detailLowerView)
        
        //assign contentLabelHeight
        if UIDevice.current.hasHomeButton {
            /* contentLabelHeight + bottomPadding + topPadding */
            let labelHeight = contentLabel.attributedTextHeight(withWidth: UIScreen.main.bounds.width - 40) + 120 + 80
            contentLabelHeight = labelHeight > UIScreen.main.bounds.height ? labelHeight : UIScreen.main.bounds.height
        } else {
            let labelHeight = contentLabel.attributedTextHeight(withWidth: UIScreen.main.bounds.width - 40) + 120 + 100
            contentLabelHeight = labelHeight > UIScreen.main.bounds.height ? labelHeight : UIScreen.main.bounds.height
        }

        
        for (pageIndex, page) in detailViews.enumerated() {
            if pageIndex == 0 {
                page.frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(pageIndex) * pageSize.height), size: pageSize)
            } else { //content page
                // this page's height is equal to the content of the label i.e. contentLabel
                page.frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(pageIndex) * pageSize.height), size: CGSize(width: UIScreen.main.bounds.width, height: contentLabelHeight))
            }
            mainScrollView.addSubview(page)
        }
        
        mainScrollView.contentSize = CGSize(width: pageSize.width, height: pageSize.height + contentLabelHeight)
    }
}

extension NewsDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = (details != nil) ? (details?.item?.coverImages.count)! : 3
        return count //number of images
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailImageCell.reuseIdentifier, for: indexPath) as! NewsDetailImageCell

        if let newsDetails = self.details?.item {
            let realIndexPath = self.imgCollectionView.indexPath(from: indexPath) //InfiniteLayout indexPath
            if let url = URL(string: newsDetails.coverImages[realIndexPath.row].secureUrl!) {
                cell.imgView.kf.setImage(with: url, options: [.transition(.fade(0.4))])
            }
        }

        return cell
    }

}

extension NewsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("current y offset = \(mainScrollView.contentOffset.y)")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            HapticFeedback.createImpact(style: .medium)
            if mainScrollView.currentVerticalPage == 1 && mainScrollView.contentOffset.y < UIScreen.main.bounds.height {
                self.mainScrollView.setContentOffset(.zero, animated: true)
            }
            
            mainScrollView.isPagingEnabled = mainScrollView.currentVerticalPage != 0 ? false : true
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == imgCollectionView {
            let indexPath = imgCollectionView.indexPath(from: imgCollectionView.indexPathsForVisibleItems.first!)
            pageControl.set(progress: indexPath.row, animated: true)
            //pageControl.set(progress: Int(scrollView.contentOffset.x) / Int(scrollView.frame.width), animated: true)
        } else {
            HapticFeedback.createImpact(style: .medium)
        }
        mainScrollView.isPagingEnabled = mainScrollView.currentVerticalPage != 0 ? false : true
    }
}

// MARK: function to push this view controller
extension NewsDetailViewController {
    static func push(fromView: UIViewController, newsId: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: NewsDetailViewController.storyboardId) as! NewsDetailViewController
        
        detailsVC.newsId = newsId
        
        fromView.navigationItem.title = ""
        fromView.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .zoom)
        fromView.navigationController?.pushViewController(detailsVC, animated: true)
    }
}


