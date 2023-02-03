//
//  AppDelegate.swift
//  ZFPlayerTest
//
//  Created by Hira on 2022/8/2.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    
    var cleanupCompleted: Bool = false
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Perform any necessary cleanup here
        doCleanup()

        // Wait for the cleanup to complete
        while !cleanupCompleted {
            // Wait for a short period of time before checking again
            Thread.sleep(forTimeInterval: 0.1)
        }

        // Now that the cleanup is complete, terminate the application
        exit(0)
    }

    func doCleanup() {
        // Perform any necessary cleanup tasks here, such as saving data or closing resources

        // Set the flag to indicate that the cleanup is complete
        DLNAConnectManager.share.getMediaControl()?.stop(success: { _ in
            self.cleanupCompleted = true
        }, failure: { _ in
            
        })
    }
}

