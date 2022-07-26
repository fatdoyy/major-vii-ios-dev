//
//  AppDelegate.swift
//  major-7-ios
//
//  Created by Heinz Leung on 12/10/2018.
//  Copyright © 2018 Major VII. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import GoogleMaps
import SkeletonView
import AuthenticationServices

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Apple sign in
        if #available(iOS 13.0, *) {
            NotificationCenter.default.setObserver(self, selector: #selector(appleIDStateChanged), name: ASAuthorizationAppleIDProvider.credentialRevokedNotification, object: nil)
        }
        
        //firebase
        FirebaseApp.configure()
        
        //Setup API Keys, using AppConfig.plist
        if let appConfig = Bundle.main.appConfig() {
            
            //facebook
            Settings.appID = appConfig.fbAppID
            Settings.clientToken = appConfig.fbClientToken
            Settings.displayName = appConfig.fbDisplayName
            
            //google login/maps
            //GIDSignIn.sharedInstance.clientID = "1044647301084-uomk81nqohoq7vv28eakhqgbvgj5pbsr.apps.googleusercontent.com"
            GMSServices.provideAPIKey(appConfig.googleMapsKey)
        }
        
        //dark UI elements
        UITabBar.appearance().barTintColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:0.75)
        UITabBar.appearance().tintColor = .white
        UITextField.appearance().keyboardAppearance = .dark
        
        //Skeleton View Appearance
        SkeletonAppearance.default.multilineCornerRadius = Int(GlobalCornerRadius.value / 2.75)
        SkeletonAppearance.default.gradient = SkeletonGradient(baseColor: .gray)
        
        //Network reachability
        NetworkManager.sharedInstance.startNetworkReachabilityObserver()
        
        setInitialVC()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        let fbDidHandle = ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])

        /*** Disabled Google Login*/
        //let googleDidHandle = GIDSignIn.sharedInstance().handle(url as URL?, sourceApplication: options[.sourceApplication] as? String, annotation: options[.annotation])
        //let googleDidHandle = GIDSignIn.sharedInstance.handle(url as URL? ?? nil)
        
        return fbDidHandle /*|| googleDidHandle! */
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()

    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "major_7_ios")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

//MARK: - Custom App Delegate functions
extension AppDelegate {
    @available(iOS 13.0, *)
    @objc func appleIDStateChanged() {
        let provider = ASAuthorizationAppleIDProvider()
        provider.getCredentialState(forUserID: "12345") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                print()
            case .revoked:
                //UserService.current.logout(fromVC: self)
                print()
            case .notFound:
                print()
            default: break
            }
        }
    }
    
    func setInitialVC() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        var initialVC: UIViewController
        
        if !UserDefaults.standard.hasValue(LOCAL_KEY.IS_FIRST_LAUNCH) {
            initialVC = mainStoryboard.instantiateViewController(withIdentifier: "onboardingScreen") as! OnboardingScreen
            UserDefaults.standard.set(false, forKey: LOCAL_KEY.IS_FIRST_LAUNCH)
            
            self.window?.rootViewController = initialVC
            self.window?.makeKeyAndVisible()
        }

    }
}
