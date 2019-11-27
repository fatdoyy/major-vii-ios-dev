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
import Kingfisher

protocol BuskersSearchViewControllerDelegate: class {
    func reassureShowingVC()
}

class BuskersSearchViewController: UIViewController {
    weak var delegate: BuskersSearchViewControllerDelegate?
    
    //set delegate with BuskerVC instance. (For refreshing)
    var buskerVCInstance: BuskersViewController? {
        didSet {
            if let instance = buskerVCInstance {
                instance.delegate = self
            }
        }
    }
    let screenWidth: CGFloat = UIScreen.main.bounds.width

    let bgImgCount = 13 //gifX_thumbnail (currently have 13)
    let bgImgArrCount = 30 //will subtract based on number of genres
    var bgImgArray = [UIImage]()
    var grayscaleImgArray = [UIImage]() //handle image filter before cellForItemAt

    var genres = [Genre]()
    var history: [String] = ["canto-pop", "j-pop", "blues", "alternative rock"]
    var boolArr = [Int]()
    
    //Initial view without typing
    let genreLabel = UILabel()
    var genreCollectionView: UICollectionView!
    let historyLabel = UILabel()
    let clearHistoryBtn = UIButton()
    var historyTableView: UITableView!
    
    //search results view
    let resultsLabel = UILabel()
    var resultsCollectionView: UICollectionView!

    var searchResults = [OrganizerProfile]()
    var searchResultsLimit = 5
    var gotMoreResults = true //lazy loading
    var emptyResultsLabel = UILabel()
    
    var viewsToHide = [UIView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        view.backgroundColor = .m7DarkGray()
        
        for _ in 0 ..< self.bgImgArrCount {
            self.bgImgArray.append(UIImage(named: "gif\(Int.random(in: 0 ... self.bgImgCount))_thumbnail")!)
        }
        
        for img in self.bgImgArray { //apply filter
            self.grayscaleImgArray.append(img.tonalFilter!)
        }
        
        hideKeyboardWhenTappedAround()
        setupGenreSection()
        setupHistorySection()
        setupResultsSection()
        
        getGenres()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.layoutIfNeeded()
        NotificationCenter.default.setObserver(self, selector: #selector(showSCViews), name: .showSCViews, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(hideSCViews), name: .hideSCViews, object: nil)
    }

}

//MARK: - UI - Genre Section
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
        genreCollectionView.backgroundColor = .m7DarkGray()
        genreCollectionView.dataSource = self
        genreCollectionView.delegate = self
        genreCollectionView.register(UINib.init(nibName: "GenreCell", bundle: nil), forCellWithReuseIdentifier: GenreCell.reuseIdentifier)
        view.addSubview(genreCollectionView)
        genreCollectionView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(genreLabel.snp.bottom).offset(15)
            make.left.right.equalTo(0)
            make.height.equalTo(GenreCell.height)
        }
        
        let overlayLeft = UIImageView(image: UIImage(named: "collectionview_overlay_left_to_right"))
        view.addSubview(overlayLeft)
        overlayLeft.snp.makeConstraints { (make) in
            make.height.equalTo(genreCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(genreCollectionView.snp.top)
            make.left.equalTo(genreCollectionView.snp.left)
        }
        
        let overlayRight = UIImageView(image: UIImage(named: "collectionview_overlay_right_to_left"))
        view.addSubview(overlayRight)
        overlayRight.snp.makeConstraints { (make) in
            make.height.equalTo(genreCollectionView.snp.height)
            make.width.equalTo(20)
            make.top.equalTo(genreCollectionView.snp.top)
            make.right.equalTo(genreCollectionView.snp.right)
        }
        
        viewsToHide.append(genreCollectionView)
    }
}

//MARK: - UI - Search History Section
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
        historyTableView.backgroundColor = .m7DarkGray()
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

//MARK: - UI - Search Results Section
extension BuskersSearchViewController {
    private func setupResultsSection() {
        resultsLabel.textColor = .white
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
        resultsCollectionView.backgroundColor = .m7DarkGray()
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

//MARK: - Notification Center functions
extension BuskersSearchViewController {
    @objc private func showSCViews() {
        if genreCollectionView.alpha != 1 {
            UIView.animate(withDuration: 0.2) {
                for view in self.viewsToHide {
                    view.alpha = 1
                }
                
                self.resultsLabel.alpha = 0
                self.resultsCollectionView.alpha = 0
            }
        }
    }
    
    @objc private func hideSCViews() {
        if genreCollectionView.alpha != 0 {
            UIView.animate(withDuration: 0.2) {
                for view in self.viewsToHide {
                    view.alpha = 0
                }
                
                self.resultsLabel.alpha = 1
                self.resultsCollectionView.alpha = 1
            }
        }
    }
}

//MARK: - API Calls | BuskersViewController Delegate
extension BuskersSearchViewController: BuskersViewControllerDelegate {
    func getGenres() {
        self.genreCollectionView.isUserInteractionEnabled = false
        OtherService.getGenres().done { response -> () in
            self.genres.append(contentsOf: response.list.shuffled())
            self.genreCollectionView.reloadData()
            
            self.grayscaleImgArray.removeSubrange(0 ..< self.bgImgArrCount - response.list.count) //update count, was 30()

            for _ in 0 ..< response.list.count {
                self.boolArr.append(Int.random(in: 0 ... 1)) //trending icon boolean
            }
            }.ensure {
                self.genreCollectionView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    func searchWithQuery(_ query: String) {
        resultsLabel.text = "Searching for \"\(query)\""
        searchResults.removeAll()
        resultsCollectionView.reloadData()
        
        SearchService.byBuskers(query: query).done { response in
            if !response.list.isEmpty {
                self.searchResults = response.list
                //self.searchResults.append(contentsOf: response.list)
                self.resultsLabel.text = "Search results for \"\(query)\""
                NotificationCenter.default.post(name: .dismissKeyboard, object: nil) //hide keyboard
            } else {
                self.resultsLabel.shake()
                HapticFeedback.createNotificationFeedback(style: .error)
                self.resultsLabel.text = "No results for \"\(query)\"\nTry another keywords?"
            }
            }.ensure {
                self.resultsCollectionView.reloadData()
                NotificationCenter.default.post(name: .hideSearchBarIndicator, object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
    func searchWithGenre(_ genre: String) {
        searchResults.removeAll()
        resultsCollectionView.reloadData()
        let genreStr = genre.replacingOccurrences(of: "-", with: "_")
        
        SearchService.byBuskers(genre: genreStr).done { response in
            if !response.list.isEmpty {
                self.searchResults = response.list
                //self.searchResults.append(contentsOf: response.list)
                self.resultsLabel.text = "Search results for \"\(genre)\""
                NotificationCenter.default.post(name: .dismissKeyboard, object: nil) //hide keyboard
            } else {
                self.resultsLabel.shake()
                HapticFeedback.createNotificationFeedback(style: .error)
                self.resultsLabel.text = "No results for \"\(genre)\"\nTry another keywords?"
            }
            }.ensure {
                self.resultsCollectionView.reloadData()
                self.hideSCViews()
                NotificationCenter.default.post(name: .hideSearchBarIndicator, object: nil)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
    
}

//MARK: - UICollectionView Delegate
extension BuskersSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case genreCollectionView:       return genres.isEmpty ? 0 : genres.count
        case resultsCollectionView:     return searchResults.isEmpty ? 0 : searchResults.count
        default:                        return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView{
        case genreCollectionView:
            let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: GenreCell.reuseIdentifier, for: indexPath) as! GenreCell
            
            cell.bgImgView.image = grayscaleImgArray[indexPath.row]
            cell.trendingIcon.image = boolArr[indexPath.row] == 1 ? UIImage(named: "icon_trending") : nil
            
            if !genres.isEmpty {
                cell.genre.text = genres[indexPath.row].titleEN?.lowercased()
            }
            
            return cell
            
        case resultsCollectionView:
            let cell = resultsCollectionView.dequeueReusableCell(withReuseIdentifier: SearchResultCell.reuseIdentifier, for: indexPath) as! SearchResultCell

            if !searchResults.isEmpty {
                cell.performerLabel.text = searchResults[indexPath.row].name
                if let url = URL(string: searchResults[indexPath.row].coverImages[0].secureUrl!) {
                    let urlArr = url.absoluteString.components(separatedBy: "upload/")
                    let desaturatedUrl = URL(string: "\(urlArr[0])upload/e_saturation:-60/\(urlArr[1])") //apply saturation effect by Cloudinary
                    cell.bgImgView.kf.setImage(with: desaturatedUrl, options: [.transition(.fade(0.3))])
                }
                
                if searchResults[indexPath.row].genreCodes.count > 1 && !searchResults[indexPath.row].genreCodes.isEmpty {
                    var genreStr = "\(searchResults[indexPath.row].genreCodes.first?.replacingOccurrences(of: "_", with: "-") ?? "")" //assign the first genre to string first
                    var genreCodes = searchResults[indexPath.row].genreCodes
                    genreCodes.removeFirst() //then remove first genre and append the remainings
                    for genreCode in genreCodes {
                        let genre = genreCode.replacingOccurrences(of: "_", with: "-")
                        genreStr.append(", \(genre)")
                    }
                    cell.genre.text = genreStr.lowercased()
                } else if searchResults[indexPath.row].genreCodes.count == 1 {
                    cell.genre.text = searchResults[indexPath.row].genreCodes.first?.replacingOccurrences(of: "_", with: "-").lowercased()
                } else if searchResults[indexPath.row].genreCodes.isEmpty {
                    cell.genre.text = ""
                }
                
                cell.verifiedBadge.alpha = searchResults[indexPath.row].verified == false ? 0 : 1
                cell.premiumBadge.alpha = boolArr[indexPath.row] == 1 ? 1 : 0
            }
            
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
            let cell = genreCollectionView.cellForItem(at: indexPath) as! GenreCell
            if let genre = cell.genre.text {
                NotificationCenter.default.post(name: .updateSearchBarText, object: nil, userInfo: ["text": genre])
                searchWithGenre(genre)
            }
            
        case resultsCollectionView:
            BuskerProfileViewController.present(from: self, buskerName: searchResults[indexPath.row].name ?? "", buskerID: searchResults[indexPath.row].id ?? "")
            
        default:
            print("error")
        }
    }
    
}

//MARK: - UITableView Delegate
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

//MARK: - UISearchResultsUpdating Delegate
extension BuskersSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let query = searchController.searchBar.text
        if query == nil || query!.isEmpty {
            self.delegate?.reassureShowingVC()
        }
    }
}
