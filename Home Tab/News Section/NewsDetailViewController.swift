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

    let detailUpperView = UIView()
    let pageControl = CHIPageControlJalapeno(frame: CGRect(x: 0, y:0, width: 100, height: 20))
    let imgOverlay = UIView()
    var titleLabel = UILabel()
    var descLabel = UILabel()
    var viewsLabel = UILabel()
    var swipeUpImg = UIImageView()
    var swipeUpLabel = UILabel()

    let detailContentView = UIView()
    let contentLabel = UILabel()
    var contentLabelHeight : CGFloat = 0.0
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        let pageSize = view.bounds.size
        
        detailUpperView.backgroundColor = .darkGray()
        
        //image collection view
        let layout: UICollectionViewFlowLayout = PagedCollectionViewLayout()
        layout.itemSize = pageSize
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.frame = self.view.frame
        collectionView.backgroundColor = .darkGray()
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib.init(nibName: "NewsDetailImageCell", bundle: nil), forCellWithReuseIdentifier: NewsDetailImageCell.reuseIdentifier)
        detailUpperView.addSubview(collectionView)
        setupUpperViewUI()
        
        detailContentView.backgroundColor = .darkGray()
        
        // setup attributes for string
        let descString = "Aaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridicul parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necpiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculupiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculupiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies necAaeosl adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculu."
        
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
        contentLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        detailContentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) -> Void in
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1136, 1334:
                    make.top.equalToSuperview().offset(80)
                    make.leftMargin.equalTo(20)
                    make.rightMargin.equalTo(-20)
                    //make.edges.equalToSuperview().inset(UIEdgeInsets(top: 80, left: 20, bottom: 40, right: 20))
                case 1920, 2208, 2436, 2688, 1792:
                    make.top.equalToSuperview().offset(100)
                    make.leftMargin.equalTo(20)
                    make.rightMargin.equalTo(-20)
                    //make.edges.equalToSuperview().inset(UIEdgeInsets(top: 100, left: 20, bottom: 40, right: 20))
                default:
                    print("unknown")
                }
            }
        }
        
        //mainScrollView
        let detailViews = [detailUpperView, detailContentView]
        
        //assign contentLabelHeight
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136, 1334:
                /* contentLabelHeight + bottomPadding + topPadding */
                let labelHeight = contentLabel.attributedTextHeight(withWidth: UIScreen.main.bounds.width - 40) + 40 + 80
                contentLabelHeight = labelHeight > UIScreen.main.bounds.height ? labelHeight : UIScreen.main.bounds.height
            case 1920, 2208, 2436, 2688, 1792:
                let labelHeight = contentLabel.attributedTextHeight(withWidth: UIScreen.main.bounds.width - 40) + 40 + 100
                contentLabelHeight = labelHeight > UIScreen.main.bounds.height ? labelHeight : UIScreen.main.bounds.height
            default:
                print("unknown")
            }
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
        
        //setup scrollView content size
        mainScrollView.contentSize = CGSize(width: pageSize.width, height: pageSize.height + contentLabelHeight)
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

    private func setupLeftBarItems(){
        let customView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 20, height: 44.0))
        customView.backgroundColor = .clear
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 5, y: 10, width: 14.13, height: 24)
        menuBtn.setImage(UIImage(named:"back"), for: .normal)
        menuBtn.addTarget(self, action: #selector(popView), for: .touchUpInside)
        customView.addSubview(menuBtn)
        
        let menuBarItem = UIBarButtonItem(customView: customView)
        let currWidth = menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 20)
        currWidth?.isActive = true
        let currHeight = menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 44)
        currHeight?.isActive = true
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
    
    @objc private func popView(){
        navigationController?.popViewController(animated: true)
    }

}

//MARK: Upper view UI
extension NewsDetailViewController {
    private func setupUpperViewUI() {
        setupOverlay()
        setupLabels()
        setupPageControl()
    }
    
    private func setupLabels() {
        swipeUpLabel.textAlignment = .center
        swipeUpLabel.numberOfLines = 1
        swipeUpLabel.font = UIFont.systemFont(ofSize: 10, weight: .semibold)
        swipeUpLabel.textColor = .lightGrayText()
        swipeUpLabel.text = "Swipe Up For More Details"
        self.detailUpperView.insertSubview(swipeUpLabel, aboveSubview: imgOverlay)
        swipeUpLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            if UIDevice().userInterfaceIdiom == .phone {
                switch UIScreen.main.nativeBounds.height {
                case 1136, 1334:
                    make.bottom.equalTo(detailUpperView.snp.bottom).offset(-20)
                case 1920, 2208, 2436, 2688, 1792:
                    make.bottom.equalTo(detailUpperView.snp.bottom).offset(-40)
                default:
                    print("unknown")
                }
            }
            make.width.equalTo(detailUpperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        
        swipeUpImg.image = UIImage(named: "icon_swipe_up")
        self.detailUpperView.insertSubview(swipeUpImg, aboveSubview: imgOverlay)
        swipeUpImg.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.size.equalTo(25)
            make.bottom.equalTo(swipeUpLabel.snp.top).offset(-10)
        }
        
        swipeUpImg.bounceRepeat()
        
        viewsLabel.textAlignment = .left
        viewsLabel.numberOfLines = 1
        viewsLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        viewsLabel.textColor = .topazText()
        viewsLabel.text = "Today | 1,234 views"
        self.detailUpperView.insertSubview(viewsLabel, aboveSubview: imgOverlay)
        viewsLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(swipeUpImg.snp.top).offset(-15)
            make.width.equalTo(detailUpperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
            //make.height.equalTo(16)
        }
        
        descLabel.textAlignment = .left
        descLabel.numberOfLines = 2
        descLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        descLabel.textColor = .lightGrayText()
        descLabel.text = "Pimp up your home with latest design classics and smart helpers."
        self.detailUpperView.insertSubview(descLabel, aboveSubview: imgOverlay)
        descLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(viewsLabel.snp.top).offset(-20)
            make.width.equalTo(detailUpperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        titleLabel.textColor = .white
        titleLabel.text = "JL is releasing an brand new album."
        self.detailUpperView.insertSubview(titleLabel, aboveSubview: imgOverlay)
        titleLabel.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(descLabel.snp.top).offset(-10)
            make.width.equalTo(detailUpperView.snp.width).inset(UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20))
        }
        
    }
    
    private func setupPageControl() {
        pageControl.numberOfPages = 4 //number of images
        pageControl.radius = 5
        pageControl.tintColor = .white
        pageControl.currentPageTintColor = .white
        pageControl.padding = 8
        self.detailUpperView.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) -> Void in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleLabel.snp.top).offset(-15)
        }
    }
    
    private func setupOverlay() {
        imgOverlay.isUserInteractionEnabled = false
        imgOverlay.backgroundColor = .clear
        imgOverlay.layer.insertSublayer(GradientLayer.create(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.height / 3) * 2)), colors: [.darkGray(), .clear], startPoint: CGPoint(x: 0.5, y: 1), endPoint: CGPoint(x: 0.5, y: 0)), at: 0)
        self.detailUpperView.addSubview(imgOverlay)
        imgOverlay.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(detailUpperView.snp.bottom)
            make.width.equalTo(detailUpperView.snp.width)
            make.height.equalTo((UIScreen.main.bounds.height / 3) * 2)
        }
    }
}

//MARK: Content View UI
extension NewsDetailViewController {
    
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print("current y offset = \(mainScrollView.contentOffset.y)")
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            HapticFeedback.createImpact(style: .medium)
            if mainScrollView.currentVerticalPage == 1 && mainScrollView.contentOffset.y < UIScreen.main.bounds.height {
                self.mainScrollView.setContentOffset(.zero, animated: true)
            }
            
            mainScrollView.isPagingEnabled = mainScrollView.currentVerticalPage == 1 ? false : true
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != mainScrollView { //uiCollectionView
            pageControl.set(progress: Int(scrollView.contentOffset.x) / Int(scrollView.frame.width), animated: true)
        }
        mainScrollView.isPagingEnabled = mainScrollView.currentVerticalPage == 1 ? false : true
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


