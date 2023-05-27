//
//  ICloudStorageTests.swift
//  PortalSwift_Tests
//
//  Created by Portal Labs, Inc.
//  Copyright © 2022 Portal Labs, Inc. All rights reserved.
//

import XCTest
@testable import PortalSwift

final class ICloudStorageTests: XCTestCase {
  var storage: ICloudStorage?

  override func setUpWithError() throws {
    storage = ICloudStorage()
    storage?.api = MockPortalApi(address:"", apiKey: "", chainId: 5)
  }

  override func tearDownWithError() throws {
    storage = nil
  }

  func testDelete() throws {
    let expectation = XCTestExpectation(description: "Delete")
    let privateKey = "privateKey"

    storage!.write(privateKey: privateKey) { (result: Result<Bool>) -> Void in
      if (result.error != nil) {
        XCTFail("Failed to write private key to storage. Make sure you are signed into iCloud on your simulator before running tests.")
      }

      self.storage!.read() { (result: Result<String>) -> Void in
        XCTAssert(result.data! == privateKey)

        self.storage!.delete() { (result: Result<Bool>) -> Void in
          XCTAssert(result.data! == true)

          self.storage!.read() { (result: Result<String>) -> Void in
            XCTAssert(result.data! == "")
            expectation.fulfill()
          }
        }
      }
    }

    wait(for: [expectation], timeout: 5.0)
  }

  func testRead() throws {
    let expectation = XCTestExpectation(description: "Read")

    storage!.read() { (result: Result<String>) -> Void in
      XCTAssert(result.data! == "")
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5.0)
  }

  func testWrite() throws {
    let expectation = XCTestExpectation(description: "Write")
    let privateKey = "privateKey"

    storage!.write(privateKey: privateKey) { (result: Result<Bool>) -> Void in
      XCTAssert(result.data! == true)

      self.storage!.read() { (result: Result<String>) -> Void in
        XCTAssert(result.data! == privateKey)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 5.0)
  }
}
