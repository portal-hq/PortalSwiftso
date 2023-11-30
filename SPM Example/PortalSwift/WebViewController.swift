//
//  WebViewController.swift
//  PortalSwift_Example
//
//  Created by Blake Williams on 7/7/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import PortalSwift
import SwiftUI

class WebViewController: UIViewController {
  public var portal: Portal?
  public var url: String?

  override func viewDidLoad() {
    super.viewDidLoad()

    guard let portal = self.portal else {
      print("No self.portal found")
      return
    }

    if self.portal != nil && self.url != nil {
      guard let url = URL(string: url ?? "") else {
        print("WebViewController error: URL could not be derived.")
        return
      }

      let webViewController = PortalWebView(portal: portal, url: url, onError: onError, onLoad: onLoad)

      // Install the WebViewController as a child view controller.
      addChild(webViewController)

      guard let webViewControllerView = webViewController.view else {
        print("WebViewController error: webViewController.view could not be derived.")
        return
      }

      view.addSubview(webViewControllerView)
      webViewController.didMove(toParent: self)
    }
  }

  func onLoad() {
    print("✅ PortalWebView loaded")
  }

  func onError(result: Result<Any>) {
    if let error = result.error {
      print("PortalWebviewError:", error, "Description:", error.localizedDescription)
      return
    }

    guard let dataAsAnyObject = result.data as? AnyObject,
          let nestedResult = dataAsAnyObject.result as? Result<Any>
    else {
      print("❌ Unable to cast result data")
      return
    }

    if let nestedError = nestedResult.error {
      print("❌ Error in nested PortalWebviewError:", nestedError)
      return
    }
  }
}
