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

class BuskerProfileViewController: UIViewController {
    static let storyboardId = "buskerProfileVC"
    
    @IBOutlet weak var mainScrollView: UIScrollView!
    
    var contentView = UIView()
    var imgCollectionView: UICollectionView!
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    let imgCollectionViewHeight: CGFloat = (UIScreen.main.bounds.height / 5) * 2
    let imgOverlay = UIView()
    var buskerLabel = UILabel()
    var actionBtn = UIButton()
    var buskerTaglineLabel = UILabel()
    let pageControl = CHIPageControlJaloro(frame: CGRect(x: 0, y: 0, width: 100, height: 10))

    override func viewDidLoad() {
        super.viewDidLoad()
        updatesStatusBarAppearanceAutomatically = true
        view.backgroundColor = .darkGray()
        
        setupImgCollectionView()
        setupOverlay()
        setupLabels()
        setupPageControl()
        setupActionBtn()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let aViewController = storyboard.instantiateViewController(withIdentifier: "A") as! ProfileDescView
        let bViewController = storyboard.instantiateViewController(withIdentifier: "B") as! ProfileEventsView
        let cViewController = storyboard.instantiateViewController(withIdentifier: "C") as! ProfilePostsView
        
        setupSegmentedControl()
        
        if #available(iOS 11.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        }
        mainScrollView.contentSize = CGSize(width: screenWidth, height: UIScreen.main.bounds.height)
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
    
    private func setupActionBtn() {
        //pageControl.alpha = 0
        actionBtn.backgroundColor = .darkGray
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
            make.top.equalTo(buskerLabel.snp.bottom).offset(15)
        }
    }
    
    @objc private func didTapActionBtn(_ sender: UIButton) {
        Animations.btnBounce(sender: sender)
        print("action btn tapped")
    }
}

//MARK: Segmented Control
extension BuskerProfileViewController {
    private func setupSegmentedControl() {
        let descVC = ProfileDescView()
        let eventsVC = ProfileEventsView()
        let postsVC = ProfilePostsView()
        
        let pagingViewController = FixedPagingViewController(viewControllers: [descVC, eventsVC, postsVC])
        
        //2  addChild(pagingViewController)
        mainScrollView.addSubview(pagingViewController.view)
        pagingViewController.didMove(toParent: self)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: imgCollectionViewHeight)
            ])
    }
    
}

//MARK: Collection View Delegate
extension BuskerProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        let count = (details != nil) ? (details?.item?.coverImages.count)! : 3
        //        return count //number of images
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BuskerProfileImgCell.reuseIdentifier, for: indexPath) as! BuskerProfileImgCell
        
        //        if let newsDetails = self.details?.item {
        //            if let url = URL(string: newsDetails.coverImages[indexPath.row].secureUrl!) {
        //                cell.imgView.kf.setImage(with: url, options: [.transition(.fade(0.75))])
        //            }
        //        }
        cell.imgView.image = UIImage(named: "cat")
        
        return cell
    }
    
}

//MARK: UIScrollView Delegate
extension BuskerProfileViewController: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
        }
        HapticFeedback.createImpact(style: .medium)

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView != mainScrollView { //UICollectionView
            pageControl.set(progress: Int(scrollView.contentOffset.x) / Int(scrollView.frame.width), animated: true)
        }
    }
}
