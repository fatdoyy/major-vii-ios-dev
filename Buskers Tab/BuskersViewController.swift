//
//  BuskersViewController.swift
//  major-7-ios
//
//  Created by jason on 22/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit

class BuskersViewController: UIViewController {
    
    var screenWidth: CGFloat = UIScreen.main.bounds.width
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    var mainCollectionView: UICollectionView!
    
    let img: [UIImage] = [UIImage(named: "cat")!, UIImage(named: "gif0_thumbnail")!, UIImage(named: "gif1_thumbnail")!, UIImage(named: "gif2_thumbnail")!, UIImage(named: "gif3_thumbnail")!, UIImage(named: "gif4_thumbnail")!, UIImage(named: "gif5_thumbnail")!, UIImage(named: "gif6_thumbnail")!, UIImage(named: "gif7_thumbnail")!, UIImage(named: "gif8_thumbnail")!]
    
    var scaledImgArray = [UIImage]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        // Do any additional setup after loading the view.
        setupNavBar()
        
        for image in img {
            scaledImgArray.append(scaleImage(image: image, maxWidth: 250))
        }
        
        setupUI()
    }

   

}

//MARK: UINavigation Bar setup
extension BuskersViewController {
    private func setupNavBar() {
        definesPresentationContext = true
        navigationItem.title = "Performers"
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        //navigationController?.navigationBar.barTintColor = .darkGray()
        //navigationController?.navigationBar.backgroundColor = UIColor.darkGray().withAlphaComponent(0.7)

        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
}

//MARK: UI setup
extension BuskersViewController {
    private func setupUI() {
        let layout = PinterestLayout()
        layout.delegate = self
        
        mainCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: screenHeight)), collectionViewLayout: layout)
        mainCollectionView.showsVerticalScrollIndicator = false
        mainCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        mainCollectionView.backgroundColor = .darkGray()
        mainCollectionView.collectionViewLayout = layout
        mainCollectionView.dataSource = self
        mainCollectionView.delegate = self
        mainCollectionView.showsHorizontalScrollIndicator = false
        mainCollectionView.register(UINib.init(nibName: "BuskerCell", bundle: nil), forCellWithReuseIdentifier: BuskerCell.reuseIdentifier)
        view.addSubview(mainCollectionView)
        mainCollectionView.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
    }
}

//MARK: UICollectionview delegate
extension BuskersViewController: UICollectionViewDelegate, UICollectionViewDataSource, PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scaledImgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: BuskerCell.reuseIdentifier, for: indexPath) as! BuskerCell
        cell.imgView.image = scaledImgArray[indexPath.row]
        cell.buskerName.text = "jamistry"
        cell.genre.text = "jazz"

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
        return scaledImgArray[indexPath.row].size.height
    }
    
    
}

//MARK: Scale image for UICollectionView
extension BuskersViewController {
    func scaleImage(image: UIImage, maxWidth: CGFloat) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let cgImage: CGImage = image.cgImage!.cropping(to: rect)!
        
        return UIImage(cgImage: cgImage, scale: image.size.width / maxWidth, orientation: image.imageOrientation)
    }
}

