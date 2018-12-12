//
//  EventDetailsViewController.swift
//  major-7-ios
//
//  Created by jason on 13/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Hero
import ImageViewer
import Floaty

//rounded view in header's bottom (i.e. the red view in IB)
class roundedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.topLeft, .topRight], radius: GlobalCornerRadius.value + 4)
    }
}

//Image viewer item
struct ImgViewerItem {
    let imageView: UIImageView
    let galleryItem: GalleryItem
}

class EventDetailsViewController: UIViewController {
    
    static let storyboardId = "eventDetails"

    @IBOutlet weak var headerImg: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var bgView: EventDetailsView!
    @IBOutlet weak var roundedView: UIView!
    
//    @IBInspectable var buttonsCount: Int = 3
//    @IBInspectable var duration: Double = 2 // circle animation duration
//    @IBInspectable var distance: Float = 100 // distance between center button and buttons
    
    //img viewer
    var imgArray: [UIImage] = []
    var imgViewerItems: [ImgViewerItem] = []
    var displaceableImgView: UIImageView?
    
    //floaty btn
    var floatyBtn = Floaty()
    
    //gesture for swipe-pop
    var gesture: UIGestureRecognizer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gesture?.delegate = self
        self.hero.isEnabled = true
        view.backgroundColor = .darkGray()
        roundedView.backgroundColor = .darkGray()
        mainScrollView.delegate = self
        
        createHeroTransitions()
        
        setupLeftBarItems()
        loadDetails()
        loadImgIntoImgViewer()
        FloatyBtn.create(btn: floatyBtn, toVc: self)
        floatyBtn.fabDelegate = self
        
        mainScrollView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
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
    
    private func loadDetails(){
        self.headerImg.image = UIImage(named: "cat")
        
        bgView.delegate = self
        bgView.titleLabel.text = "CityEcho呈獻：星期五時代廣場Busking"
        bgView.descLabel.text = "Right click on the portion of the screen where your project’s files are (view controller, storyboard, etc) and choose “new file”. Xcode will prompt you for which file type you’d like to create. Choose the “View” option under the User Interface menu. On the following pop up you’ll be prompted to name your xib — we called ours “TestView”.Right click on the portion of the screen where your project’s files are (view controller, storyboard, etc) and choose “new file”. Xcode will prompt you for which file type you’d like to create. Choose the “View” option under the User Interface menu. On the following pop up you’ll be prompted to name your xib — we called ours “TestView”.Right click on the portion of the screen where your project’s files are (view controller, storyboard, etc) and choose “new file”. Xcode will prompt you for which file type you’d like to create. Choose the “View” option under the User Interface menu. On the following pop up you’ll be prompted to name your xib — we called ours “TestView”."
        
        bgView.hashtagsArray = ["descTitleLabel", "descLabel", "webTitleLabel", "remarksTitleLabel", "imgCollectionView", "hashtagsCollectionView", "performerLabel", "titleLabel"]
        bgView.hashtagsCollectionView.reloadData()
    
        imgArray = [UIImage(named: "cat")!, UIImage(named: "icon_white")!, UIImage(named: "music-studio-12")!, UIImage(named: "tabbar_buskers")!, UIImage(named: "tabbar_coop")!]
        bgView.imgArray = self.imgArray
        
        if UIDevice().userInterfaceIdiom == .phone { //only reload imgCollectionView if device is not iPhone SE
            if UIScreen.main.nativeBounds.height != 1136 {
                bgView.imgCollectionView.reloadData()
            }
        }
        
        bgView.layoutIfNeeded()
    }
    
    private func createHeroTransitions(){
        bgView.hero.modifiers = [.delay(0.1), .translate(y: 500)]
        bgView.bookmarkBtn.hero.modifiers = [.delay(0.3), .translate(y: 500)]
        bgView.bookmarkCountImg.hero.modifiers = [.delay(0.35), .translate(y: 500)]
        bgView.bookmarkCountLabel.hero.modifiers = [.delay(0.4), .translate(y: 500)]
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
    
    private func loadImgIntoImgViewer(){
        var imgViewArray: [UIImageView] = []
        
        if imgArray.count != 0 {
            for img in imgArray {
                let imgView = UIImageView(image: img)
                imgViewArray.append(imgView)
            }
        }
        
        for imgView in imgViewArray {
            var galleryItem: GalleryItem!
            
            let image = imgView.image
            galleryItem = GalleryItem.image { $0(image) }
            
            imgViewerItems.append(ImgViewerItem(imageView: imgView, galleryItem: galleryItem))
        }
    }
    
    
    @objc private func popView(){
        navigationController?.hero.navigationAnimationType = .zoomOut
        navigationController?.popViewController(animated: true)
    }
}

// MARK: scrollview delegate
extension EventDetailsViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}

// MARK: Events Details View Delegate
extension EventDetailsViewController: EventsDetailsViewDelegate{
    func bookmarkBtnTapped(sender: UIButton) {
        let bookmarkedImg = UIImage(named: "eventdetails_bookmarked_1")
        let notBookmarkedImg = UIImage(named: "eventdetails_bookmarked_0")
        
        if (sender.currentImage?.isEqual(notBookmarkedImg))! { //if the image is notBookmarkedImg, then do bookmark action
            HapticFeedback.createImpact(style: .heavy)
            sender.setImage(bookmarkedImg, for: .normal)
            print("bookmarked")
        } else {
            HapticFeedback.createImpact(style: .light)
            sender.setImage(notBookmarkedImg, for: .normal)
            print("removed bookmark")
        }
    }

    
    func imageCellTapped(index: Int, displacementItem: UIImageView) {
        showImageViewer(atIndex: index)
        displaceableImgView = displacementItem
    }
}

// MARK: present image viewer when imgCollectionView cell is tapped
extension EventDetailsViewController{
    func showImageViewer(atIndex: Int){
        let frame = CGRect(x: 0, y: 0, width: 200, height: 24)
        let footerView = CounterView(frame: frame, currentIndex: atIndex, count: imgViewerItems.count)
        
        
        let galleryViewController = GalleryViewController(startIndex: atIndex, itemsDataSource: self, displacedViewsDataSource: self, configuration: ImageViewerHelper.config())
        //galleryViewController.headerView = headerView
        galleryViewController.footerView = footerView
        
        galleryViewController.launchedCompletion = { print("LAUNCHED") }
        galleryViewController.closedCompletion = { print("CLOSED") }
        galleryViewController.swipedToDismissCompletion = { print("SWIPE-DISMISSED") }
        galleryViewController.landedPageAtIndexCompletion = { index in
            
            print("LANDED AT INDEX: \(index)")
            
            footerView.count = self.imgViewerItems.count
            footerView.currentIndex = index
        }
        
        self.presentImageGallery(galleryViewController)
    }
}

// MARK: extend UIImageView to subclass displaceableview
extension UIImageView: DisplaceableView {}

// MARK: image viewer data source
extension EventDetailsViewController: GalleryDisplacedViewsDataSource {
    func provideDisplacementItem(atIndex index: Int) -> DisplaceableView? {
        print(index)
        return index < imgViewerItems.count ? displaceableImgView : nil
    }
}

extension EventDetailsViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return imgViewerItems.count
    }
    
    func provideGalleryItem(_ index: Int) -> GalleryItem {
        return imgViewerItems[index].galleryItem
    }
}

// MARK: Floating Button Delegate
extension EventDetailsViewController: FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        print("Floaty Will Open")
    }
    
    func floatyDidOpen(_ floaty: Floaty) {
        print("Floaty Did Open")
    }
    
    func floatyWillClose(_ floaty: Floaty) {
        print("Floaty Will Close")
    }
    
    func floatyDidClose(_ floaty: Floaty) {
        print("Floaty Did Close")
    }
}


// MARK: swipe pop gesture
extension EventDetailsViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: function to push this view controller
extension EventDetailsViewController{
    static func push(fromView: UIViewController){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVc = storyboard.instantiateViewController(withIdentifier: EventDetailsViewController.storyboardId)
        
        fromView.navigationItem.title = ""
        fromView.navigationController?.hero.navigationAnimationType = .zoom
        fromView.navigationController?.pushViewController(detailsVc, animated: true)
    }
}
