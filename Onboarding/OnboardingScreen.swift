//
//  OnboardingScreen.swift
//  major-7-ios
//
//  Created by jason on 12/12/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit
import Pastel
import SkyFloatingLabelTextField
import ViewAnimator
import NVActivityIndicatorView

class OnboardingScreen: UIViewController {
    var gradientBg: PastelView!
    var mainScrollView: UIScrollView!
    var pageSize: CGSize!
    var isKeyboardPresent = false
    private var timer: Timer?

    //screen one
    var screenOneBg: UIView!
    var screenOneTitle: UILabel!
    var screenOneSubTitle: UILabel!
    var profilePic: UIImageView!
    var usernameField: SkyFloatingLabelTextField!
    var usernameDesc: UILabel!
    
    //screen two
    var screenTwoBg: UIView!
    var screenTwoTitle: UILabel!
    var screenTwoSubTitle: UILabel!
    var genreCollectionView: UICollectionView!
    var genres = [Genre]()
    var indicator = NVActivityIndicatorView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 20, height: 20)), type: .lineScale)
    private let animations = [AnimationType.from(direction: .right, offset: 100), AnimationType.zoom(scale: 0.5)]

    //screen three
    var screenThreeBg: UIView!
    var screenThreeTitle: UILabel!
    var screenThreeSubTitle: UILabel!
    
    var isScreenOneAnimated = false
    var isScreenTwoAnimated = false
    var isScreenThreeAnimated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mainScrollView.contentSize = CGSize(width: pageSize.width * 3, height: pageSize.height - 100)
    }
}

//MARK: - UI related
extension OnboardingScreen {
    private func setupPastelView() {
        // Custom Direction
        gradientBg = PastelView()
        gradientBg.startPastelPoint = .bottomLeft
        gradientBg.endPastelPoint = .topRight
        
        // Custom Duration
        gradientBg.animationDuration = 2
        
        // Custom Color
        gradientBg.setColors([UIColor(hexString: "#ad5389"), UIColor(hexString: "#3c1053")])
        
        gradientBg.startAnimation()
        view.insertSubview(gradientBg, at: 0)
        gradientBg.snp.makeConstraints { (make) -> Void in
            make.edges.equalTo(0)
        }
    }
    
    private func setupScrollView() {
        pageSize = view.bounds.size

        mainScrollView = UIScrollView()
        mainScrollView.delegate = self
        mainScrollView.showsVerticalScrollIndicator = false
        mainScrollView.showsHorizontalScrollIndicator = false
        mainScrollView.isPagingEnabled = true
        mainScrollView.backgroundColor = .clear
        
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(0)
            make.bottom.equalToSuperview().offset(-80)
        }
    }
    
    private func setupUI() {
        //handle keyboard
        NotificationCenter.default.setObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.setObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        setupPastelView()
        setupScrollView()
        
        setupScreenOne()
        setupScreenTwo()
        setupScreenThree()
        
        animateScreenOne()
    }
}

//MARK: - Page control
extension OnboardingScreen {
    func setupPageControl() {
        
    }
}

//MARK: - Onboarding Screens UI
//MARK: Screen One: UITextFieldDelegate, Keyboard handling
extension OnboardingScreen: UITextFieldDelegate {
    private func setupScreenOne() {
        screenOneBg = UIView()
        mainScrollView.addSubview(screenOneBg)
        screenOneBg.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.size.equalTo(pageSize)
        }
        
        screenOneTitle = UILabel()
        screenOneTitle.alpha = 0
        screenOneTitle.numberOfLines = 0
        screenOneTitle.text = "Pick a username!"
        screenOneTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenOneTitle.textColor = .white
        screenOneBg.addSubview(screenOneTitle)
        screenOneTitle.snp.makeConstraints { (make) in
            if UIDevice.current.hasHomeButton { make.top.equalTo(50) } else { make.top.equalTo(83) }
            make.width.equalTo(pageSize.width - 60)
            make.left.equalTo(UIScreen.main.bounds.midX)
        }
        
        screenOneSubTitle = UILabel()
        screenOneSubTitle.alpha = 0
        screenOneSubTitle.text = "A great name helps you produce better music (joke)"
        screenOneSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenOneSubTitle.textColor = .white
        screenOneSubTitle.numberOfLines = 0
        screenOneBg.addSubview(screenOneSubTitle)
        screenOneSubTitle.snp.makeConstraints { (make) in
            if UIDevice.current.type == .iPhone_5_5S_5C_SE {
                make.top.equalTo(screenOneTitle.snp.bottom).offset(25)
            } else {
                make.top.equalTo(screenOneTitle.snp.bottom).offset(35)
            }
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenOneTitle.snp.left)
        }
        
        profilePic = UIImageView()
        profilePic.alpha = 0
        profilePic.layer.cornerRadius = UIDevice.current.type == .iPhone_5_5S_5C_SE ? 50 : 65
        profilePic.contentMode = .scaleAspectFill
        profilePic.backgroundColor = .darkGray
        screenOneBg.addSubview(profilePic)
        profilePic.snp.makeConstraints { (make) in
            if UIDevice.current.type == .iPhone_5_5S_5C_SE {
                make.top.equalTo(screenOneSubTitle.snp.bottom).offset(50)
                make.size.equalTo(100)
            } else {
                make.top.equalTo(screenOneSubTitle.snp.bottom).offset(100)
                make.size.equalTo(130)
            }
            make.centerX.equalToSuperview().offset(100)
        }

        usernameField = SkyFloatingLabelTextField()
        usernameField.alpha = 0
        usernameField.delegate = self
        usernameField.placeholder = "Username"
        usernameField.title = "Username"
        usernameField.titleColor = .white
        usernameField.selectedTitleColor = .white
        usernameField.lineHeight = 1.25
        usernameField.lineColor = .white15Alpha()
        usernameField.placeholderColor = .white15Alpha()
        usernameField.selectedLineHeight = 1.5
        usernameField.selectedLineColor = .white
        usernameField.textColor = .white
        screenOneBg.addSubview(usernameField)
        usernameField.snp.makeConstraints { (make) in
            make.top.equalTo(profilePic.snp.bottom).offset(32)
            make.width.equalTo(200)
            make.height.equalTo(40)
            make.centerX.equalToSuperview().offset(100)
        }

        usernameDesc = UILabel()
        usernameDesc.alpha = 0
        usernameDesc.text = "You can change this anytime!"
        usernameDesc.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        screenOneBg.addSubview(usernameDesc)
        usernameDesc.snp.makeConstraints { (make) in
            make.top.equalTo(usernameField.snp.bottom).offset(10)
            make.height.equalTo(17)
            make.centerX.equalToSuperview()
        }
    }
    
    private func animateScreenOne() {
        let originalTitleTransform = screenOneTitle.transform
        let translatedTitleTransform = originalTitleTransform.translatedBy(x: -UIScreen.main.bounds.midX + 30, y: -0)
        
        UIView.animate(withDuration: 0.65, delay: 0.1, options: .curveEaseInOut, animations: {
            self.screenOneTitle.transform = translatedTitleTransform
            self.screenOneTitle.alpha = 1
        }, completion: nil)
                        
        UIView.animate(withDuration: 0.65, delay: 0.3, options: .curveEaseInOut, animations: {
            self.screenOneSubTitle.transform = translatedTitleTransform
            self.screenOneSubTitle.alpha = 1
        }, completion: nil)
        
        let originalImgViewTransform = profilePic.transform
        let translatedImgViewTransform = originalImgViewTransform.translatedBy(x: -100, y: -0)
        
        UIView.animate(withDuration: 0.65, delay: 0.5, options: .curveEaseInOut, animations: {
            self.profilePic.transform = translatedImgViewTransform
            self.profilePic.alpha = 1
        }, completion: nil)

        UIView.animate(withDuration: 0.65, delay: 0.7, options: .curveEaseInOut, animations: {
            self.usernameField.transform = translatedImgViewTransform
            self.usernameField.alpha = 1
        }, completion: nil)
        
        isScreenOneAnimated = true
    }
    
    @objc func keyboardWillAppear(_ notification: Notification) {
        //Get keyboard height
        if !isKeyboardPresent {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardMinY = keyboardRectangle.minY
                var keyboardTopPlusPadding = self.usernameDesc.frame.minY - keyboardMinY
                if #available(iOS 13.0, *) {
                    keyboardTopPlusPadding += 80
                } else {
                    keyboardTopPlusPadding += 40
                }
                
                //animate the constraint's constant change
                profilePic.snp.updateConstraints { (make) in
                    if UIDevice.current.type == .iPhone_5_5S_5C_SE {
                        make.top.equalTo(screenOneSubTitle.snp.bottom).offset(-130)
                    } else {
                        make.top.equalTo(screenOneSubTitle.snp.bottom).offset(30)
                    }
                }
                
                if UIDevice.current.type == .iPhone_5_5S_5C_SE {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                        self.screenOneTitle.alpha = 0
                        self.screenOneSubTitle.alpha = 0
                        self.screenOneBg.layoutIfNeeded()
                    }, completion: nil)
                } else {
                    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                        self.screenOneBg.layoutIfNeeded()
                    }, completion: nil)
                }
            }
            isKeyboardPresent = true
        }
    }
    
    @objc func keyboardWillDisappear() {
        if isKeyboardPresent {
            //animate the constraint's constant change
            profilePic.snp.updateConstraints { (make) in
                if UIDevice.current.type == .iPhone_5_5S_5C_SE {
                    make.top.equalTo(screenOneSubTitle.snp.bottom).offset(50)
                } else {
                    make.top.equalTo(screenOneSubTitle.snp.bottom).offset(80)
                }
            }
            
            if UIDevice.current.type == .iPhone_5_5S_5C_SE {
                UIView.animate(withDuration: 0.3) {
                    self.screenOneTitle.alpha = 1
                    self.screenOneSubTitle.alpha = 1
                    self.screenOneBg.layoutIfNeeded()
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.screenOneBg.layoutIfNeeded()
                }
            }
            isKeyboardPresent = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.65, delay: 0.6, options: .curveEaseInOut, animations: {
            self.usernameDesc.alpha = 1
        }, completion: nil)
    }

}

//MARK: Screen Two: UICollectionView
extension OnboardingScreen: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func setupScreenTwo() {
        screenTwoBg = UIView()
        mainScrollView.addSubview(screenTwoBg)
        screenTwoBg.snp.makeConstraints { (make) in
            make.left.equalTo(screenOneBg.snp.right)
            make.size.equalTo(pageSize)
        }
        
        screenTwoTitle = UILabel()
        screenTwoTitle.alpha = 0
        screenTwoTitle.numberOfLines = 0
        screenTwoTitle.text = "Pick your genres!"
        screenTwoTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenTwoTitle.textColor = .white
        screenTwoBg.addSubview(screenTwoTitle)
        screenTwoTitle.snp.makeConstraints { (make) in
            if UIDevice.current.hasHomeButton { make.top.equalTo(50) } else { make.top.equalTo(83) }
            make.width.equalTo(pageSize.width - 60)
            make.left.equalTo(UIScreen.main.bounds.midX)
        }
        
        screenTwoSubTitle = UILabel()
        screenTwoSubTitle.alpha = 0
        screenTwoSubTitle.text = "This help us suggest suitable artists for you"
        screenTwoSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenTwoSubTitle.textColor = .white
        screenTwoSubTitle.numberOfLines = 0
        screenTwoBg.addSubview(screenTwoSubTitle)
        screenTwoSubTitle.snp.makeConstraints { (make) in
            if UIDevice.current.type == .iPhone_5_5S_5C_SE {
                make.top.equalTo(screenTwoTitle.snp.bottom).offset(25)
            } else {
                make.top.equalTo(screenTwoTitle.snp.bottom).offset(35)
            }
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenTwoTitle.snp.left)
        }
        
        indicator.alpha = 0
        screenTwoBg.addSubview(indicator)
        indicator.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(100)
            make.top.equalTo(screenTwoSubTitle.snp.bottom).offset(100)
        }
        indicator.startAnimating()
        
        setupGenreCollectionView()
    }

    private func setupGenreCollectionView() {
        let layout = GenresLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets (top: 0, left: 30, bottom: 0, right: 30)

        genreCollectionView = UICollectionView(frame: CGRect(origin: .zero, size: .zero), collectionViewLayout: layout)
        genreCollectionView.backgroundColor = .clear
        genreCollectionView.dataSource = self
        genreCollectionView.delegate = self
        
        genreCollectionView.showsVerticalScrollIndicator = false
        genreCollectionView.showsHorizontalScrollIndicator = false
        genreCollectionView.register(UINib.init(nibName: "OnboardingGenreCell", bundle: nil), forCellWithReuseIdentifier: OnboardingGenreCell.reuseIdentifier)
        
        screenTwoBg.addSubview(genreCollectionView)
        genreCollectionView.snp.makeConstraints { (make) in
            make.height.equalTo(mainScrollView.snp.height)
            make.width.equalTo(pageSize.width)
            make.top.equalTo(screenTwoSubTitle.snp.bottom).offset(30)
        }
    }
    
    private func animateScreenTwo() {
        let originalTransform = screenTwoTitle.transform
        let translatedTransform = originalTransform.translatedBy(x: -UIScreen.main.bounds.midX + 30, y: -0)
        
        UIView.animate(withDuration: 0.65, delay: 0, options: .curveEaseInOut, animations: {
            self.screenTwoTitle.transform = translatedTransform
            self.screenTwoTitle.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.65, delay: 0.2, options: .curveEaseInOut, animations: {
            self.screenTwoSubTitle.transform = translatedTransform
            self.screenTwoSubTitle.alpha = 1
        }, completion: nil)
        
        let originalIndicatorTransform = indicator.transform
        let translatedIndicatorTransform = originalIndicatorTransform.translatedBy(x: -100, y: -0)
        
        UIView.animate(withDuration: 0.65, delay: 0.4, options: .curveEaseInOut, animations: {
            self.indicator.transform = translatedIndicatorTransform
            self.indicator.alpha = 1
        }, completion: nil)
        
        isScreenTwoAnimated = true
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return genres.isEmpty ? 0 : genres.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = genreCollectionView.dequeueReusableCell(withReuseIdentifier: OnboardingGenreCell.reuseIdentifier, for: indexPath) as! OnboardingGenreCell
        cell.genre.text = genres.isEmpty ? "" : genres[indexPath.row].titleEN?.lowercased()

        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let genre = genres[indexPath.row].titleEN?.lowercased()
//        let size = genre!.size(withAttributes: nil)
//        return CGSize(width: size.width + 32, height: OnboardingGenreCell.height)
//    }
}

//MARK: Screen Three
extension OnboardingScreen {
    private func setupScreenThree() {
        screenThreeBg = UIView()
        mainScrollView.addSubview(screenThreeBg)
        screenThreeBg.snp.makeConstraints { (make) in
            make.left.equalTo(screenTwoBg.snp.right)
            make.size.equalTo(pageSize)
            make.right.equalToSuperview()
        }
        
        screenThreeTitle = UILabel()
        screenThreeTitle.alpha = 0
        screenThreeTitle.numberOfLines = 0
        screenThreeTitle.text = "Notifications"
        screenThreeTitle.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        screenThreeTitle.textColor = .white
        screenThreeBg.addSubview(screenThreeTitle)
        screenThreeTitle.snp.makeConstraints { (make) in
            if UIDevice.current.hasHomeButton { make.top.equalTo(50) } else { make.top.equalTo(83) }
            make.width.equalTo(pageSize.width - 60)
            make.left.equalTo(UIScreen.main.bounds.midX)
        }
        
        screenThreeSubTitle = UILabel()
        screenThreeSubTitle.alpha = 0
        screenThreeSubTitle.text = "請允許我們向你提供推送通知，例如表演者將舉行表演的時間地點 、本地音樂消息等等。\n\n你稍後可在設定中變更通知選項。"
        screenThreeSubTitle.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        screenThreeSubTitle.textColor = .white
        screenThreeSubTitle.numberOfLines = 0
        screenThreeBg.addSubview(screenThreeSubTitle)
        screenThreeSubTitle.snp.makeConstraints { (make) in
            if UIDevice.current.type == .iPhone_5_5S_5C_SE {
                make.top.equalTo(screenThreeTitle.snp.bottom).offset(25)
            } else {
                make.top.equalTo(screenThreeTitle.snp.bottom).offset(35)
            }
            make.width.equalTo(UIScreen.main.bounds.width - 60)
            make.left.equalTo(screenThreeTitle.snp.left)
        }
    }
    
    private func animateScreenThree() {
        let originalTransform = screenThreeTitle.transform
        let translatedTransform = originalTransform.translatedBy(x: -UIScreen.main.bounds.midX + 30, y: -0)
        
        UIView.animate(withDuration: 0.65, delay: 0, options: .curveEaseInOut, animations: {
            self.screenThreeTitle.transform = translatedTransform
            self.screenThreeTitle.alpha = 1
        }, completion: nil)
        
        UIView.animate(withDuration: 0.65, delay: 0.2, options: .curveEaseInOut, animations: {
            self.screenThreeSubTitle.transform = translatedTransform
            self.screenThreeSubTitle.alpha = 1
        }, completion: nil)
        
        isScreenThreeAnimated = true
    }
}

//MARK: - API Calls
extension OnboardingScreen {
    func getGenres() {
        self.genreCollectionView.isUserInteractionEnabled = false
        OtherService.getGenres().done { response -> () in
            self.genres.append(contentsOf: response.list.shuffled())
            self.genreCollectionView.reloadData()
            self.genreCollectionView.performBatchUpdates({
                UIView.animate(views: self.genreCollectionView!.orderedVisibleCells,
                               animations: self.animations, duration: 0.6)
            }, completion: nil)

            }.ensure {
                UIView.animate(withDuration: 0.2) {
                    self.indicator.alpha = 0
                }
                
                self.genreCollectionView.isUserInteractionEnabled = true
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }.catch { error in }
    }
}

//MARK: - UIScrollView delegate
extension OnboardingScreen: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = scrollView.contentOffset.x / scrollView.bounds.size.width
        
        // initiate animations on half way before user scrolls to next page (i.e. pageIndex == 1)
        if pageIndex > 0.35 && !isScreenTwoAnimated {
            animateScreenTwo()
            getGenres()
        }
        
        if pageIndex > 1.35 && !isScreenThreeAnimated { animateScreenThree() }
        
        //if pageIndex > 0.35 && pageIndex
    }
}
