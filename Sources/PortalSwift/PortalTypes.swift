public struct AnyEncodable: Encodable {
  let value: Encodable

  init(_ value: Encodable) {
    self.value = value
  }

  public func encode(to encoder: Encoder) throws {
    try self.value.encode(to: encoder)
  }
}

/*********************************************
 * Legacy stuff - consider replacing these
 *********************************************/

public struct FeatureFlags {
  public var optimized: Bool
  public var isMultiBackupEnabled: Bool?

  public init(optimized: Bool, isMultiBackupEnabled: Bool? = nil) {
    self.optimized = optimized
    self.isMultiBackupEnabled = isMultiBackupEnabled
  }
}

public struct BackupConfigs {
  public var passwordStorage: PasswordStorageConfig?

  public init(passwordStorage: PasswordStorageConfig? = nil) {
    self.passwordStorage = passwordStorage
  }
}

public struct PasswordStorageConfig {
  public var password: String

  public enum PasswordStorageError: Error {
    case invalidLength
  }

  public init(password: String) throws {
    if password.count < 4 {
      throw PasswordStorageError.invalidLength
    }
    self.password = password
  }
}

/// A struct with the backup options (gdrive and/or icloud) initialized.
public struct BackupOptions {
  public var gdrive: GDriveStorage?
  public var icloud: ICloudStorage?
  public var passwordStorage: PasswordStorage?
  public var local: Storage?

  public var _passkeyStorage: Any?

  @available(iOS 16, *)
  var passkeyStorage: PasskeyStorage? {
    get { return self._passkeyStorage as? PasskeyStorage }
    set { self._passkeyStorage = newValue }
  }

  /// Create the backup options for PortalSwift.
  /// - Parameter gdrive: The instance of GDriveStorage to use for backup.
  /// - Parameter icloud: The instance of ICloudStorage to use for backup.
  @available(iOS 16, *)
  public init(gdrive: GDriveStorage? = nil, icloud: ICloudStorage? = nil, passwordStorage: PasswordStorage? = nil, passkeyStorage: PasskeyStorage? = nil) {
    self.gdrive = gdrive
    self.icloud = icloud
    self.passwordStorage = passwordStorage
    self.passkeyStorage = passkeyStorage
  }

  /// Create the backup options for PortalSwift.
  /// - Parameter gdrive: The instance of GDriveStorage to use for backup.
  /// - Parameter icloud: The instance of ICloudStorage to use for backup.
  public init(gdrive: GDriveStorage? = nil, icloud: ICloudStorage? = nil, passwordStorage: PasswordStorage? = nil) {
    self.gdrive = gdrive
    self.icloud = icloud
    self.passwordStorage = passwordStorage
  }

  /// Create the backup options for PortalSwift.
  /// - Parameter gdrive: The instance of GDriveStorage to use for backup.
  public init(gdrive: GDriveStorage) {
    self.gdrive = gdrive
  }

  /// Create the backup options for PortalSwift.
  /// - Parameter icloud: The instance of ICloudStorage to use for backup.
  public init(icloud: ICloudStorage) {
    self.icloud = icloud
  }

  public init(local: Storage) {
    self.local = local
  }

  public init(passwordStorage: PasswordStorage) {
    self.passwordStorage = passwordStorage
  }

  /// Create the backup options for PortalSwift.
  /// - Parameter gdrive: The instance of GDriveStorage to use for backup.
  /// - Parameter icloud: The instance of ICloudStorage to use for backup.
  public init(gdrive: GDriveStorage, icloud: ICloudStorage, passwordStorage: PasswordStorage) {
    self.gdrive = gdrive
    self.icloud = icloud
    self.passwordStorage = passwordStorage
  }

  subscript(key: String) -> Any? {
    switch key {
    case BackupMethods.GoogleDrive.rawValue:
      return self.gdrive
    case BackupMethods.iCloud.rawValue:
      return self.icloud
    case BackupMethods.local.rawValue:
      return self.local
    case BackupMethods.Password.rawValue:
      return self.passwordStorage
    case BackupMethods.Passkey.rawValue:
      return self._passkeyStorage
    default:
      return nil
    }
  }
}
