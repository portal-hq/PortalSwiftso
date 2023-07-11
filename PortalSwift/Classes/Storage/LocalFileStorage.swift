//
//  LocalFileStorage.swift
//  PortalSwift
//
//  Created by Rami Shahatit on 5/16/23.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation

public enum LocalFileStorageError: Error {
  case mustExtendStorageClass
  case fileNotFound
  case writeError
  case readError
}

public class LocalFileStorage: Storage {
  var fileName: String = "PORTAL_BACKUP_SHARE"

  public init(fileName: String = "PORTAL_BACKUP_SHARE") {
    self.fileName = fileName
    super.init()
  }

  /// Deletes an item in storage.
  override public func delete(completion: @escaping (Result<Bool>) -> Void) {
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

    do {
      try FileManager.default.removeItem(at: fileURL)
      completion(Result(data: true))
    } catch {
      completion(Result(error: LocalFileStorageError.fileNotFound))
    }
  }

  /// Reads an item from storage.
  override public func read(completion: @escaping (Result<String>) -> Void) {
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

    do {
      let content = try String(contentsOf: fileURL)
      completion(Result(data: content))
    } catch {
      completion(Result(error: LocalFileStorageError.readError))
    }
  }

  /// Writes an item to storage.
  override public func write(privateKey content: String, completion: @escaping (Result<Bool>) -> Void) {
    let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)

    do {
      try content.write(to: fileURL, atomically: true, encoding: .utf8)
      completion(Result(data: true))
    } catch {
      completion(Result(error: LocalFileStorageError.writeError))
    }
  }

  /// Get the documents directory for the app.
  private func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }
}
