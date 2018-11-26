//
//  EventDetailsViewController.swift
//  major-7-ios
//
//  Created by jason on 13/11/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import Hero

protocol EventDetailsDelegate {
}

//rounded view in header's bottom (i.e. the red view in IB)
class roundedView: UIView {
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(corners: [.topLeft, .topRight], radius: GlobalCornerRadius.value + 4)
    }
}

class EventDetailsViewController: UIViewController {
    
    static let storyboardId = "eventDetails"

    @IBOutlet weak var headerImg: UIImageView!
    @IBOutlet weak var mainScrollView: UIScrollView!
    @IBOutlet weak var bgView: EventDetailsView!
    @IBOutlet weak var roundedView: UIView!
    
    var gesture: UIGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        setupLeftBarItems()
        gesture?.delegate = self
        bgView.hero.modifiers = [.translate(y: 500)]
        
        view.backgroundColor = .darkGray()
        roundedView.backgroundColor = .darkGray()
        self.headerImg.image = UIImage(named: "cat")
        
        mainScrollView.contentSize = CGSize(width: mainScrollView.contentSize.width, height: 0)
        mainScrollView.delegate = self
        
        //bgView.backgroundColor = .darkGray()
        //bgView.layer.cornerRadius = GlobalCornerRadius.value + 4
        
        bgView.titleLabel.text = "CityEcho呈獻：星期五時代廣場Busking"
        Hashtags.create(position: .detailsView, dataSource: ["123", "456", "789", "222", "666"], toView: self.bgView, multiLines: true, solidColor: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainScrollView.contentInset = UIEdgeInsets(top: 300, left: 0, bottom: 0, right: 0)
        
     
        
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
    
    @objc private func popView(){
        navigationController?.popViewController(animated: true)
    }
}


extension EventDetailsViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

//scrollview did scroll?
extension EventDetailsViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {}
}

//function to push this view controller
extension EventDetailsViewController{
    static func push(fromView: UIViewController){
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let detailsVc = storyboard.instantiateViewController(withIdentifier: EventDetailsViewController.storyboardId)
        
        fromView.navigationItem.title = ""
       //fromView.navigationController?.hero.navigationAnimationType = .pageIn(direction: .left)
        fromView.navigationController?.pushViewController(detailsVc, animated: true)
    }
}
