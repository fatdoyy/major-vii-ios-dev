//
//  BuskersSearchViewController.swift
//  major-7-ios
//
//  Created by jason on 21/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import BouncyLayout
import NVActivityIndicatorView

class BuskersSearchViewController: UIViewController {
    
    var loadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
    
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    let genreLabel = UILabel()
    var genreCollectionView: UICollectionView!
    
    let imgArray: [UIImage] = [UIImage(named: "gif9_thumbnail")!, UIImage(named: "gif10_thumbnail")!, UIImage(named: "gif11_thumbnail")!, UIImage(named: "cat")!, UIImage(named: "gif0_thumbnail")!, UIImage(named: "gif1_thumbnail")!, UIImage(named: "gif2_thumbnail")!, UIImage(named: "gif3_thumbnail")!, UIImage(named: "gif4_thumbnail")!, UIImage(named: "gif5_thumbnail")!, UIImage(named: "gif6_thumbnail")!, UIImage(named: "gif7_thumbnail")!, UIImage(named: "gif8_thumbnail")!]
    
    var grayscaleImgArray = [UIImage]()
    
    let genres: [String] = ["canto-pop", "j-pop", "blues", "alternative rock", "punk", "country", "house", "edm", "electronic", "dance", "k-pop", "acid jazz", "downtempo"]
    var boolArr = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray()
        
        for img in imgArray {
            grayscaleImgArray.append(img.tonalFilter!)
            boolArr.append(Int.random(in: 0 ... 1))
        }
        
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.setObserver(self, selector: #selector(showViews), name: .showSCViews, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(hideViews), name: .hideSCViews, object: nil)
    }

}

//MARK: UI setup
extension BuskersSearchViewController {
    private func setupUI() {
        genreLabel.textColor = .white
        genreLabel.text = "Suggested genres"
        genreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.addSubview(genreLabel)
        genreLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(20)
        }
        
        loadingIndicator.alpha = 0
        loadingIndicator.startAnimating()
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(genreLabel.snp.bottom)
            make.size.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        setupGenreCollectionView()
    }
    
    private func setupGenreCollectionView() {
        let layout = BouncyLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        genreCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: GenreCell.height)), collectionViewLayout: layout)
        genreCollectionView.showsHorizontalScrollIndicator = false
        genreCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        genreCollectionView.backgroundColor = .darkGray()
        genreCollectionView.dataSource = self
        genreCollectionView.delegate = self
        genreCollectionView.register(UINib.init(nibName: "GenreCell", bundle: nil), forCellWithReuseIdentifier: GenreCell.reuseIdentifier)
        view.addSubview(genreCollectionView)
        genreCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(genreLabel.snp.bottom).offset(15)
            make.left.right.equalTo(0)
            make.height.equalTo(GenreCell.height)
        }
    }
}

//MARK: Notification functions
extension BuskersSearchViewController {
    @objc private func showViews() {
        if genreCollectionView.alpha != 1 {
            UIView.animate(withDuration: 0.2) {
                self.loadingIndicator.alpha = 0
                
                self.genreLabel.alpha = 1
                self.genreCollectionView.alpha = 1
            }
        }
    }
    
    @objc private func hideViews() {
        if genreCollectionView.alpha != 0 {
            UIView.animate(withDuration: 0.2) {
                
                self.loadingIndicator.alpha = 1
                self.genreLabel.alpha = 0
                self.genreCollectionView.alpha = 0
            }
        }
    }
}

//MARK: UICollectionView Delegate
extension BuskersSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return grayscaleImgArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as! GenreCell
        
        cell.bgImgView.image = grayscaleImgArray.reversed()[indexPath.row]
        cell.genre.text = genres.reversed()[indexPath.row]
        
        
        cell.trendingIcon.image = boolArr[indexPath.row] == 1 ? UIImage(named: "icon_trending") : nil
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: GenreCell.width, height: GenreCell.height)
    }
    
}


