//
//  NewsDetailViewController.swift
//  major-7-ios
//
//  Created by jason on 15/2/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import CHIPageControl

class NewsDetailViewController: UIViewController {

    static let storyboardId = "newsDetailVC"

    let upperView = UIView()
    let pageControl = CHIPageControlJalapeno(frame: CGRect(x: 0, y:0, width: 100, height: 20))
    let imgOverlay = ImageOverlay()
    var titleLabel = UILabel()
    var descLabel = UILabel()
    var viewsLabel = UILabel()
    var swipeUpImg = UIImageView()

    let lowerView = UIView()
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updatesStatusBarAppearanceAutomatically = true
        view.backgroundColor = .darkGray()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        let pageSize = view.bounds.size
        
        
        upperView.backgroundColor = .darkGray()
        
        //image collection view
        let layout: UICollectionViewFlowLayout = PagedCollectionViewLayout()
        layout.itemSize = pageSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.frame = self.view.frame
        collectionView.backgroundColor = .mintGreen()
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib.init(nibName: "NewsDetailImageCell", bundle: nil), forCellWithReuseIdentifier: NewsDetailImageCell.reuseIdentifier)

        upperView.addSubview(collectionView)
        setupUpperViewUI()
        
        lowerView.backgroundColor = .blue
        
        let pagesViews = [upperView, lowerView]
        
        let numberOfPages = pagesViews.count
        
        for (pageIndex, page) in pagesViews.enumerated() {
            page.frame = CGRect(origin: CGPoint(x: 0, y: CGFloat(pageIndex) * pageSize.height), size: pageSize)
            scrollView.addSubview(page)
        }
        
        scrollView.contentSize = CGSize(width: pageSize.width, height: pageSize.height * CGFloat(numberOfPages))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //transparent navigation bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        //navigationController?.navigationBar.barTintColor = .darkGray()
        navigationController?.navigationBar.isTranslucent = true
        TabBar.hide(rootView: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        TabBar.show(rootView: self)
    }

    private func setupUpperViewUI() {
        setupOverlay()
        setupLabels()
        setupPageControl()
    }

    private func setupLabels() {
        swipeUpImg.image = UIImage(named: "icon_swipe_up")
        self.upperView.insertSubview(swipeUpImg, aboveSubview: imgOverlay)
        swipeUpImg.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.size.equalTo(25)
            make.bottom.equalTo(upperView.snp.bottom).offset(-40)
        }
        
        swipeUpImg.bounceRepeat()
        
        viewsLabel.textAlignment = .left
        viewsLabel.numberOfLines = 1
        viewsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        viewsLabel.textColor = .topazText()
        viewsLabel.text = "Today | 1,234 views"
        self.upperView.insertSubview(viewsLabel, aboveSubview: imgOverlay)
        viewsLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(swipeUpImg.snp.top).offset(-20)
            make.width.equalTo(upperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            //make.height.equalTo(16)
        }
        
        descLabel.textAlignment = .left
        descLabel.numberOfLines = 2
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descLabel.textColor = .lightGrayText()
        descLabel.text = "Pimp up your home with latest design classics and smart helpers."
        self.upperView.insertSubview(descLabel, aboveSubview: imgOverlay)
        descLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(viewsLabel.snp.top).offset(-20)
            make.width.equalTo(upperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }

        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.text = "JL is releasing an brand new album."
        self.upperView.insertSubview(titleLabel, aboveSubview: imgOverlay)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(descLabel.snp.top).offset(-10)
            make.width.equalTo(upperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }

    }
    

    private func setupPageControl() {
        pageControl.numberOfPages = 4 //number of images
        pageControl.radius = 5
        pageControl.tintColor = .white
        pageControl.currentPageTintColor = .white
        pageControl.padding = 8
        self.upperView.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-15)
        }
    }
    
    private func setupOverlay() {
        imgOverlay.isUserInteractionEnabled = false
        self.upperView.addSubview(imgOverlay)
        imgOverlay.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(upperView.snp.bottom)
            make.width.equalTo(upperView.snp.width)
            make.height.equalTo(UIScreen.main.bounds.height / 2)
        }
    }

}

extension NewsDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4 //number of images
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewsDetailImageCell.reuseIdentifier, for: indexPath) as! NewsDetailImageCell
        cell.imgView.image = UIImage(named: "cat")
        return cell
    }

}

extension NewsDetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        HapticFeedback.createImpact(style: .medium)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.set(progress: Int(scrollView.contentOffset.x) / Int(scrollView.frame.width), animated: true)
    }
}

// MARK: function to push this view controller
extension NewsDetailViewController {
    static func push(fromView: UIViewController, eventId: String){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: NewsDetailViewController.storyboardId) as! NewsDetailViewController
        
        //detailsVC.eventId = eventId
        
        fromView.navigationItem.title = ""
        fromView.navigationController?.hero.navigationAnimationType = .autoReverse(presenting: .zoom)
        fromView.navigationController?.pushViewController(detailsVC, animated: true)
    }
}
