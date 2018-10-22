//
//  HomeViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    private let eventCellId = "event"
    private let cellId2 = "cellId2"
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    @IBOutlet weak var pageTitle: UILabel!
    @IBOutlet weak var eventsLabel: UILabel!
    @IBOutlet weak var viewAllBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.pageTitle.text = "News"
//        self.pageTitle.textColor = .whiteText()
//
//        self.eventsLabel.text = "Upcoming Events"
//        self.eventsLabel.textColor = .whiteText()
//
//        self.viewAllBtn.setTitle("VIEW ALL", for: .normal)
//        self.viewAllBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkColor()
        
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        
        mainCollectionView.backgroundColor = .gray
        mainCollectionView.register(UINib.init(nibName: "EventsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: eventCellId)
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: eventCellId, for: indexPath) as! EventsCollectionViewCell
        return cell
    }

}

