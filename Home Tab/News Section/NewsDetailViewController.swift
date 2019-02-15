//
//  NewsDetailViewController.swift
//  major-7-ios
//
//  Created by jason on 15/2/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class NewsDetailViewController: UIViewController {

    static let storyboardId = "newsDetailVC"
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .darkGray()
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        let pageSize = view.bounds.size
        
        createUpperView()
        
        let upperView = UIView()
        upperView.backgroundColor = .darkGray()
        
        //image collection view
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = pageSize
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .mintGreen()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib.init(nibName: "NewsDetailImageCell", bundle: nil), forCellWithReuseIdentifier: NewsDetailImageCell.reuseIdentifier)

        upperView.addSubview(collectionView)
        
        let lowerView = UIView()
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
    
    private func createUpperView() {
        
    }
    
}

extension NewsDetailViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
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
