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

protocol BuskersSearchViewControllerDelegate {
    func reassureShowingVC()
}

class BuskersSearchViewController: UIViewController {
    var delegate: BuskersSearchViewControllerDelegate?
    
    var loadingIndicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
    
    let screenWidth: CGFloat = UIScreen.main.bounds.width
    
    let genreLabel = UILabel()
    var genreCollectionView: UICollectionView!

    let perfomers: [String] = ["jamistry", "水曜日のカンパネラ", "Anomalie", "鄧小巧", "陳奕迅", "Mr.", "RubberBand", "Postman", "Zeplin", "SourceTree", "Xcode", "August", "VIRT"]

    let imgArray: [UIImage] = [UIImage(named: "gif9_thumbnail")!, UIImage(named: "gif10_thumbnail")!, UIImage(named: "gif11_thumbnail")!, UIImage(named: "cat")!, UIImage(named: "gif0_thumbnail")!, UIImage(named: "gif1_thumbnail")!, UIImage(named: "gif2_thumbnail")!, UIImage(named: "gif3_thumbnail")!, UIImage(named: "gif4_thumbnail")!, UIImage(named: "gif5_thumbnail")!, UIImage(named: "gif6_thumbnail")!, UIImage(named: "gif7_thumbnail")!, UIImage(named: "gif8_thumbnail")!]
    
    var grayscaleImgArray = [UIImage]()
    
    let genres: [String] = ["canto-pop", "j-pop", "blues", "alternative rock", "punk", "country", "house", "edm", "electronic", "dance", "k-pop", "acid jazz", "downtempo"]
    var history: [String] = ["canto-pop", "j-pop", "blues", "alternative rock"]
    var boolArr = [Int]()
    var boolArr2 = [Int]()
    
    let historyLabel = UILabel()
    let clearHistoryBtn = UIButton()
    var historyTableView: UITableView!
    
    let resultsLabel = UILabel()
    var resultsCollectionView: UICollectionView!
    
    var viewsToHide = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        view.backgroundColor = .darkGray()
        
        for img in imgArray {
            grayscaleImgArray.append(img.tonalFilter!)
            boolArr.append(Int.random(in: 0 ... 1))
            boolArr2.append(Int.random(in: 0 ... 1))
        }
        
        setupGenreSection()
        setupHistorySection()
        setupResultsSection()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.setObserver(self, selector: #selector(showViews), name: .showSCViews, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(hideViews), name: .hideSCViews, object: nil)
    }

}

//MARK: Genre Section
extension BuskersSearchViewController {
    private func setupGenreSection() {
        genreLabel.textColor = .white
        genreLabel.text = "Suggested genres"
        genreLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.addSubview(genreLabel)
        genreLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(20)
        }
        viewsToHide.append(genreLabel)
        
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
        viewsToHide.append(genreCollectionView)
    }
}

//MARK: Search History Section
extension BuskersSearchViewController {
    private func setupHistorySection() {
        historyLabel.textColor = .white
        historyLabel.text = "Search history"
        historyLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        view.addSubview(historyLabel)
        historyLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(genreCollectionView.snp.bottom).offset(15)
            make.left.equalTo(20)
        }
        viewsToHide.append(historyLabel)
        
        clearHistoryBtn.setTitle("Clear", for: .normal)
        clearHistoryBtn.setTitleColor(.whiteText75Alpha(), for: .normal)
        clearHistoryBtn.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        clearHistoryBtn.addTarget(self, action: #selector(clearAllHistory), for: .touchUpInside)
        clearHistoryBtn.backgroundColor = UIColor.darkGray
        clearHistoryBtn.layer.cornerRadius = 13.5
        view.addSubview(clearHistoryBtn)
        clearHistoryBtn.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(genreCollectionView.snp.bottom).offset(17)
            make.width.equalTo(60)
            make.right.equalTo(-20)
        }
        viewsToHide.append(clearHistoryBtn)

        setupHistoryTableView()
    }
    
    @objc private func clearAllHistory() {
        history.removeAll()
        historyTableView.reloadData()
        UIView.animate(withDuration: 0.2) {
            self.clearHistoryBtn.alpha = 0
        }
    }
    
    private func setupHistoryTableView() {
        historyTableView = UITableView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: GenreCell.height)))
        historyTableView.showsVerticalScrollIndicator = false
        historyTableView.alwaysBounceVertical = false
        historyTableView.rowHeight = 46
        historyTableView.backgroundColor = .darkGray()
        historyTableView.separatorColor = .darkGray
        historyTableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        historyTableView.tableFooterView = UIView()
        historyTableView.cellLayoutMarginsFollowReadableWidth = false
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.register(UINib.init(nibName: "SearchHistoryCell", bundle: nil), forCellReuseIdentifier: SearchHistoryCell.reuseIdentifier)
        view.addSubview(historyTableView)
        historyTableView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(historyLabel.snp.bottom).offset(5)
            make.left.right.bottom.equalTo(0)
        }
        viewsToHide.append(historyTableView)
    }
}

//MARK: Search Results Section
extension BuskersSearchViewController {
    private func setupResultsSection() {
        resultsLabel.textColor = .white
        resultsLabel.text = "Search results"
        resultsLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        resultsLabel.alpha = 0
        view.addSubview(resultsLabel)
        resultsLabel.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalTo(20)
        }

        setupResultsCollectionView()
    }
    
    private func setupResultsCollectionView() {
        let layout = BouncyLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 15
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        
        resultsCollectionView = UICollectionView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: screenWidth, height: GenreCell.height)), collectionViewLayout: layout)
        resultsCollectionView.alpha = 0
        resultsCollectionView.showsVerticalScrollIndicator = false
        resultsCollectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 20, right: 10)
        resultsCollectionView.backgroundColor = .darkGray()
        resultsCollectionView.dataSource = self
        resultsCollectionView.delegate = self
        resultsCollectionView.register(UINib.init(nibName: "SearchResultCell", bundle: nil), forCellWithReuseIdentifier: SearchResultCell.reuseIdentifier)
        view.addSubview(resultsCollectionView)
        resultsCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(resultsLabel.snp.bottom).offset(15)
            make.left.right.bottom.equalTo(0)
        }
    }
}

//MARK: Notification Center functions
extension BuskersSearchViewController {
    @objc private func showViews() {
        if genreCollectionView.alpha != 1 {
            UIView.animate(withDuration: 0.2) {
                //self.loadingIndicator.alpha = 0
                
                for view in self.viewsToHide {
                    view.alpha = 1
                }
                
                self.resultsLabel.alpha = 0
                self.resultsCollectionView.alpha = 0
            }
        }
    }
    
    @objc private func hideViews() {
        if genreCollectionView.alpha != 0 {
            UIView.animate(withDuration: 0.2) {
                //self.loadingIndicator.alpha = 1
                
                for view in self.viewsToHide {
                    view.alpha = 0
                }
                
                self.resultsLabel.alpha = 1
                self.resultsCollectionView.alpha = 1
            }
        }
    }
}

//MARK: UICollectionView Delegate
extension BuskersSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case genreCollectionView:       return grayscaleImgArray.count
        case resultsCollectionView:     return grayscaleImgArray.count
        default:                        return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView{
        case genreCollectionView:
            let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as! GenreCell
            
            cell.bgImgView.image = grayscaleImgArray.reversed()[indexPath.row]
            cell.genre.text = genres.reversed()[indexPath.row]
            
            cell.trendingIcon.image = boolArr[indexPath.row] == 1 ? UIImage(named: "icon_trending") : nil
            
            return cell
            
        case resultsCollectionView:
            let cell = resultsCollectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as! SearchResultCell
            
            cell.performerLabel.text = perfomers[indexPath.row]
            cell.bgImgView.image = grayscaleImgArray.reversed()[indexPath.row]
            cell.genre.text = genres.reversed()[indexPath.row]
            
            cell.verifiedBg.alpha = boolArr[indexPath.row] == 1 ? 1 : 0
            cell.premiumBadge.alpha = boolArr2[indexPath.row] == 1 ? 1 : 0
            
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionView {
        case genreCollectionView:       return CGSize(width: GenreCell.width, height: GenreCell.height)
        case resultsCollectionView:     return CGSize(width: SearchResultCell.width, height: SearchResultCell.height)
        default:                        return CGSize(width: GenreCell.width, height: GenreCell.height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch collectionView {
        case genreCollectionView:
            print("tapped genre cell")
        case resultsCollectionView:
            BuskerProfileViewController.present(fromView: self, buskerName: perfomers[indexPath.row], buskerId: "5be7f512d92f1257fd2a530e")
        default:
            print("error")
        }
    }
    
}

//MARK: UITableView Delegate
extension BuskersSearchViewController: UITableViewDelegate, UITableViewDataSource, SearchHistoryCellDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = historyTableView.dequeueReusableCell(withIdentifier: SearchHistoryCell.reuseIdentifier, for: indexPath) as! SearchHistoryCell
        cell.delegate = self
        cell.history.text = history[indexPath.row]
        
        return cell
    }
    
    func removeBtnTapped(cell: SearchHistoryCell) {
        if let indexPath = historyTableView.indexPath(for: cell) {
            print("cell.history is \(String(describing: cell.history.text))")
            history.remove(at: indexPath.row)
            historyTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //to do
    }
}

//MARK: UISearchResultsUpdating Delegate
extension BuskersSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text
        if query == nil || query!.isEmpty {
            self.delegate?.reassureShowingVC()
        }
    }
}
