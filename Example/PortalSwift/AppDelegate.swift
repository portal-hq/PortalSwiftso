//
//  AppDelegate.swift
//  PortalSwift
//
//  Created by Portal Labs, Inc.
//  Copyright © 2022 Portal Labs, Inc. All rights reserved.
//

import PortalSwift
import UIKit

protocol PortalExampleAppDelegate {
  var connect: PortalConnect? { get set }
  var connect2: PortalConnect? { get set }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PortalExampleAppDelegate {
  var window: UIWindow?
  var connect: PortalConnect?
  var connect2: PortalConnect?

  func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    return true
  }

  func applicationWillResignActive(_: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    print("application entered background...")
  }

  func applicationWillEnterForeground(_: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    print("Application is now active...")
    if
      connect != nil
    {
      print("reconnecting connect 1...")
      let uri = connect?.uri ?? nil
      if uri != nil {
        connect?.connect(uri! as String)
      }
    }

    if
      connect2 != nil
    {
      print("reconnecting connect 2...")
      let uri = connect2?.uri ?? nil
      if uri != nil {
        connect2?.connect(uri! as String)
      }
    }
  }

  func applicationWillTerminate(_: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
}
