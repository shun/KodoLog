//
//  AppDelegate.swift
//  KodoLog
//
//  Created by KudoShunsuke on 2015/07/01.
//  Copyright (c) 2015年 KudoShunsuke. All rights reserved.
//

import UIKit
import GoogleMaps;

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var m_maincontroller: AppMainController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        LogTrace.sharedInstance.info()
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyCk1umxJSurzYnImG-CeRQq7eXbQoyCBe4")

        UIDevice.currentDevice().batteryMonitoringEnabled = true
        let settings = UIUserNotificationSettings(
            forTypes: UIUserNotificationType.Badge
                | UIUserNotificationType.Sound
                | UIUserNotificationType.Alert,
            categories: nil)
        application.registerUserNotificationSettings(settings);
#if false
        removefiles()
#endif
        sleep(2)
        m_maincontroller = AppMainController()
        m_maincontroller?.setAppMode(.FOREGROUND)
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        LogTrace.sharedInstance.info()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        m_maincontroller?.setAppMode(.BACKGROUND)
    }

    func applicationDidEnterBackground(application: UIApplication) {
        LogTrace.sharedInstance.info()
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        LogTrace.sharedInstance.info()
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        m_maincontroller?.setAppMode(.FOREGROUND)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        LogTrace.sharedInstance.info()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        LogTrace.sharedInstance.info()
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        var notification = UILocalNotification()
        notification.fireDate = NSDate()	// すぐに通知したいので現在時刻を取得
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.alertBody = "アプリケーションが終了したので、記録が必要な場合はアプリケーションを起動してください"
        notification.alertAction = "OK"
        notification.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }

    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        LogTrace.sharedInstance.warn()
    }

    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        LogTrace.sharedInstance.warn()
    }

    func removefiles() {
        var docrootpath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let filemanager = NSFileManager.defaultManager()
        let logdirpath = docrootpath + "/logs"
        let logpath = docrootpath + "/log.txt"

        if (filemanager.fileExistsAtPath(logdirpath)) {
            filemanager.removeItemAtPath(logdirpath, error: nil)
        }

        if (filemanager.fileExistsAtPath(logpath)) {
            filemanager.removeItemAtPath(logpath, error: nil)
        }

    }
    /*
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        LogTrace.sharedInstance.warn()
    }

    func applicationDidFinishLaunching(application: UIApplication) {
        LogTrace.sharedInstance.info()

    }
    func application(application: UIApplication, willFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        LogTrace.sharedInstance.info()
        return false

    }

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        LogTrace.sharedInstance.info()
        return false

    }// Will be deprecated at some point, please replace with application:openURL:sourceApplication:annotation:
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        LogTrace.sharedInstance.info()
        return false

    }// no equiv. notification. return NO if the application can't open for some reason

    func applicationSignificantTimeChange(application: UIApplication) {
        LogTrace.sharedInstance.info()

    }// midnight, carrier time update, daylight savings time change

    func application(application: UIApplication, willChangeStatusBarOrientation newStatusBarOrientation: UIInterfaceOrientation, duration: NSTimeInterval){
        LogTrace.sharedInstance.info()

    }
    func application(application: UIApplication, didChangeStatusBarOrientation oldStatusBarOrientation: UIInterfaceOrientation){
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, willChangeStatusBarFrame newStatusBarFrame: CGRect) {
        LogTrace.sharedInstance.info()

    }// in screen coordinates
    func application(application: UIApplication, didChangeStatusBarFrame oldStatusBarFrame: CGRect){
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings){
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData){
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [NSObject : AnyObject], completionHandler: () -> Void){
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: () -> Void){
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!){
        LogTrace.sharedInstance.info()

    }

    func applicationProtectedDataWillBecomeUnavailable(application: UIApplication){
        LogTrace.sharedInstance.info()

    }
    func applicationProtectedDataDidBecomeAvailable(application: UIApplication){
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> Int{
        LogTrace.sharedInstance.info()
        return -1
    }

    func application(application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: String) -> Bool{
        LogTrace.sharedInstance.info()
        return false

    }

    func application(application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [AnyObject], coder: NSCoder) -> UIViewController?{
        LogTrace.sharedInstance.info()
        return nil
    }
    func application(application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool{
        LogTrace.sharedInstance.info()
        return false

    }
    func application(application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool{
        LogTrace.sharedInstance.info()
        return false

    }
    func application(application: UIApplication, willEncodeRestorableStateWithCoder coder: NSCoder){
        LogTrace.sharedInstance.info()

    }
    func application(application: UIApplication, didDecodeRestorableStateWithCoder coder: NSCoder){
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, willContinueUserActivityWithType userActivityType: String) -> Bool {
        LogTrace.sharedInstance.info()
        return false

    }

    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]!) -> Void) -> Bool {
        LogTrace.sharedInstance.info()
        return false
    }

    func application(application: UIApplication, didFailToContinueUserActivityWithType userActivityType: String, error: NSError) {
        LogTrace.sharedInstance.info()

    }

    func application(application: UIApplication, didUpdateUserActivity userActivity: NSUserActivity) {
        LogTrace.sharedInstance.info()

    }
*/






}

