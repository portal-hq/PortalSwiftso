//
//  GDriveClient.swift
//  PortalSwift
//
//  Created by Blake Williams on 2/7/23.
//

import Foundation
import GoogleSignIn

struct GDriveDeleteResponse: Codable {
  let kind: String;
}

struct GDriveFile: Codable {
  let kind: String;
  let id: String;
  let name: String;
  let mimeType: String;
}

struct GDriveFolderMetadata: Codable {
  let mimeType: String;
  let name: String;
  let parents: [String];
}

struct GDriveFileMetadata: Codable {
  let name: String;
  let parents: [String];
}

struct GDriveFilesListResponse: Codable {
  let kind: String;
  let incompleteSearch: Bool;
  let files: [GDriveFile];
}

private enum GDriveClientError: Error {
  case noFileFound
  case userNotAuthenticated
}

class GDriveClient {
  private var api: HttpRequester
  private var auth: GoogleAuth
  private var baseUrl: String = "https://www.googleapis.com"
  private var boundary: String = "portal-backup-share"
  private var clientId: String
  private var folder: String
  
  init(
    clientId: String,
    view: UIViewController,
    folder: String = "_PORTAL_MPC_DO_NOT_DELETE_"
  ) {
    api = HttpRequester(baseUrl: baseUrl)
    auth = GoogleAuth(config: GIDConfiguration(clientID: clientId), view: view)
    self.clientId = clientId
    self.folder = folder
  }
  
  public func delete(id: String, callback: @escaping (Result<Bool>) -> Void) -> Void {
    auth.getAccessToken() { accessToken in
      if accessToken.error != nil {
        callback(Result(error: accessToken.error!))
      } else if (accessToken.data == "") {
        callback(Result(error: GDriveClientError.userNotAuthenticated))
      }
      
      do {
        try self.api.delete(
          path: "/drive/v3/files/\(id)",
          headers: ["Authorization": "Bearer \(accessToken)"]
        ) { (result: Result<GDriveDeleteResponse>) -> Void in
          if result.error != nil {
            callback(Result(error: result.error!))
          } else {
            callback(Result(data: true))
          }
        }
      } catch {
        callback(Result(error: error))
      }
    }
  }
  
  private func getAccessToken(callback: @escaping (Result<String>) -> Void) -> Void {
    if auth.getCurrentUser() == nil {
      callback(Result(error: GDriveClientError.userNotAuthenticated))
    }
    
    auth.getAccessToken() { (accessToken) in
      callback(accessToken)
    }
  }
  
  private func getIdForFilename(filename: String, callback: @escaping (Result<String>) -> Void) throws -> Void {
    if auth.getCurrentUser() == nil {
      throw GDriveClientError.userNotAuthenticated
    }
    
    auth.getAccessToken() { accessToken in
      let query = "name='\(filename)'".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
      do {
        try self.api.get(
          path: "/drive/v3/files?corpora=user&q=\(query!)",
          headers: [
            "Accept": "application/json",
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json"
          ]
        ) { (result: Result<GDriveFilesListResponse>) in
          if (result.error != nil) {
            callback(Result(error: result.error!))
          }
          
          if (result.data!.files.count > 0) {
            callback(Result(data: result.data!.files[0].id))
            return
          }
          
          callback(Result(error: GDriveClientError.noFileFound))
        }
      } catch {
        callback(Result(error: error))
      }
    }
  }
  
  
  public func read(id: String, callback: @escaping (Result<String>) -> Void) -> Void {
    auth.getAccessToken() { (accessToken) in
      do {
        try self.api.get(
          path: "/drive/v3/files/\(id)?alt=media",
          headers: [
            "Accept": "application/json",
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "application/json",
          ]
        ) { (result: Result<String>) in
          if (result.error != nil) {
            callback(Result(error: result.error!))
            return
          }
          
          callback(result)
        }
      } catch {
        callback(Result(error: error))
      }
    }
  }
  
  public func write(filename: String, content: String, callback: @escaping (Result<String>) -> Void) throws -> Void {
    auth.getAccessToken() { accessToken in
      if (accessToken.error != nil) {
        callback(Result(error: accessToken.error!))
        return
      }
      
      // Delete existing file
      do {
        try self.getIdForFilename(filename: filename) { (fileId: Result<String>) in
          if (fileId.error != nil) {
            callback(Result(error: fileId.error!))
          }
          
          var existingFileId = fileId.data!
          self.delete(id: existingFileId) { result in
            do {
              try self.writeFile(filename: filename, content: content, accessToken: accessToken.data!) {
                (result: Result<String>) in
                callback(result)
              }
            } catch {
              callback(Result(error: error))
            }
          }
        }
      } catch GDriveClientError.noFileFound {
        print("[Portal.GDriveStorage] No existing file found. Skipping delete.")
        do {
          try self.writeFile(filename: filename, content: content, accessToken: accessToken.data!) {
            result in
            callback(result)
          }
        } catch {
          callback(Result(error: error))
        }
      } catch {
        callback(Result(error: error))
      }
    }
  }
  
  private func buildMultipartFormData(content: String, metadata: GDriveFileMetadata) throws -> String {
    var metadataString = try JSONEncoder().encode(metadata)
    var body = [
      "--\(boundary)\n",
      "Content-Type: application/json; charset=UTF-8\n\n",
      "\(metadataString)\n",
      "--\(boundary)\n",
      "Content-Type: text/plain\n\n",
      "\(content)\n",
      "--\(boundary)--",
    ]
    
    return body.joined(separator: "")
  }
  
  private func createFolder(callback: @escaping (Result<GDriveFile>) -> Void) throws -> Void {
    auth.getAccessToken() { accessToken in
      if (accessToken.error != nil) {
        callback(Result(error: accessToken.error!))
        return
      }
      
      do {
        var body = GDriveFolderMetadata(
          mimeType: "application/vnd.google-apps.folder",
          name: self.folder,
          parents: ["root"]
        )
        var bodyData = try JSONEncoder().encode(body)
        var bodyString = String(data: bodyData, encoding: .utf8 )!
        
        
        try self.api.post(
          path:"/drive/v3/files?ignoreDefaultVisibility=true",
          body: [
            "name": body.name,
            "mimeType": body.mimeType,
            "parents": body.parents
          ],
          headers: [
            "Accept": "application/json",
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json",
            "Content-Length": String(bodyString.count)
          ]
        ) { (result: Result<GDriveFile>) in
          
        }
      } catch {
        callback(Result(error: error))
      }
    }
  }
    
  private func getOrCreateFolder(callback: @escaping (Result<GDriveFile>) -> Void) -> Void {
    auth.getAccessToken() { accessToken in
      if (accessToken.error != nil) {
        callback(Result(error: accessToken.error!))
        return
      }
      
      do {
        let query = "name='\(self.folder)'".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        try self.api.get(
          path: "/drive/v3/files?q=\(query!)",
          headers: [
            "Accept": "application/json",
            "Authorization": "Bearer $accessToken",
            "Content-Type": "application/json"
          ]
        ) { (result: Result<GDriveFilesListResponse>) in
          if (result.error != nil) {
            callback(Result(error: result.error!))
            return
          }
          
          do {
            if (result.data!.files.count > 0) {
              callback(Result(data: result.data!.files[0]))
            } else {
              try self.createFolder() { createdFolder in
                callback(createdFolder)
              }
            }
          } catch {
            callback(Result(error: error))
          }
        }
      } catch {
        callback(Result(error: error))
      }
    }
  }
  
  private func writeFile(filename: String, content: String, accessToken: String, callback: @escaping (Result<String>) -> Void) throws {
    getOrCreateFolder() { folder in
      if (folder.error != nil) {
        callback(Result(error: folder.error!))
        return
      }
      
      do {
        var metadata = GDriveFileMetadata(
          name: filename,
          parents: [folder.data!.id]
        )

        var body = try self.buildMultipartFormData(
          content: content,
          metadata: metadata
        )

        try self.api.post(
          path: "/upload/drive/v3/files?ignoreDefaultVisibility=true&uploadType=multipart",
          body: ["rawBody":  body],
          headers: [
            "Authorization": "Bearer \(accessToken)",
            "Content-Type": "multipart/related; boundary=\(self.boundary)"
          ]
        ) { (result: Result<GDriveFile>) in
          if (result.error != nil) {
            callback(Result(error: result.error!))
            return
          }
          
          callback(Result(data: result.data!.id))
        }
      } catch {
        callback(Result(error: error))
      }
    }
  }
}
