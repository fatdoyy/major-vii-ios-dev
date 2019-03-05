//
//  ProfileDescView.swift
//  major-7-ios
//
//  Created by jason on 4/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

class ProfileDescView: UIViewController {

    @IBOutlet weak var hashtagsCollectionView: UICollectionView!
    let hashtagsArray = ["123", "456", "789", "asdfgghh", "hkbusking", "guitarbusking", "cajon123", "abc555", "00000000", "#1452fa", "1234567890"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        
        hashtagsCollectionView.delegate = self
        hashtagsCollectionView.dataSource = self
        hashtagsCollectionView.tag = 111
        
        if let layout = hashtagsCollectionView.collectionViewLayout as? HashtagsFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        if #available(iOS 11.0, *) {
            hashtagsCollectionView.contentInsetAdjustmentBehavior = .always
        }
        
        hashtagsCollectionView.backgroundColor = .darkGray
        hashtagsCollectionView.register(UINib.init(nibName: "HashtagCell", bundle: nil), forCellWithReuseIdentifier: HashtagCell.reuseIdentifier)
    }

}

extension ProfileDescView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == hashtagsCollectionView{
            return hashtagsArray.count
        } else { //imgCollectionView
            return 3 //imgUrlArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = hashtagsCollectionView.dequeueReusableCell(withReuseIdentifier: HashtagCell.reuseIdentifier, for: indexPath) as! HashtagCell
        cell.hashtag.text = "#\(hashtagsArray[indexPath.row])"
        return cell
        
        if collectionView == hashtagsCollectionView {

        } //else { //imgCollectionView
//            let cell = imgCollectionView.dequeueReusableCell(withReuseIdentifier: DetailsImageCell.reuseIdentifier, for: indexPath) as! DetailsImageCell
//            cell.imgView.kf.setImage(with: URL(string: imgUrlArray[indexPath.row]), options: [.transition(.fade(0.75))])
//            return cell
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (hashtagsArray[indexPath.row] as NSString).size(withAttributes: nil)
        return CGSize(width: size.width + 32, height: HashtagCell.height)
        
        if collectionView == hashtagsCollectionView {

        } //else { //imgCollectionView
//            return CGSize(width: DetailsImageCell.width, height: DetailsImageCell.height)
//        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == hashtagsCollectionView {} /*else {
//            let cell = imgCollectionView.cellForItem(at: indexPath) as! DetailsImageCell
//            delegate?.imageCellTapped(index: indexPath.row, displacementItem: cell.imgView)
//        }*/
//    }
}
