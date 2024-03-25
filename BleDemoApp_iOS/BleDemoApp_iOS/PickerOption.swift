//
//  PickerOption.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/6.
//

import Foundation



enum PickerOption {
    case cmd1O
    case cmd2O
    case cmd30
}

enum Picker1Option: CaseIterable, CustomStringConvertible {
    case connecting
    case adminCodeExist
    case setAdminCode
    case editAdminCode
    case boltCheck
    case factoryReset
    case setDeviceName
    case getDeviceName
    case setTimeZone
    case setDeviceTime
    case getDeviceConfig
    case setDeviceConfig
    case getDeviceStatus
    case switchDevice
    case getLogCount
    case getLogData
    case gettokenArray
    case gettokenData
    case addtoken
    case edittoken
    case deltoken
    case getAccessArray
    case getAccessData
    case addAccess
    case editAccess
    case delAccess
    case disconnected
    
    var description: String {
        switch self {
        case .connecting:
            return "Connecting"
        case .adminCodeExist:
            return "Admin Code Exist"
        case .setAdminCode:
            return "Set Admin Code"
        case .editAdminCode:
            return "Edit Admin Code"
        case .boltCheck:
            return "Reset Bolt Direction"
        case .factoryReset:
            return "Factory Reset"
        case .setDeviceName:
            return "Set Device Name"
        case .setTimeZone:
            return "Set Timezone to Asia/Taipei"
        case .setDeviceTime:
            return "Set Device Time"
        case .getDeviceName:
            return "Get Device Name"
        case .getDeviceConfig:
            return "Get Device Config"
        case .setDeviceConfig:
            return "Set Device Config"
        case .getDeviceStatus:
            return "Get Device Status"
        case .switchDevice:
            return "Lock/Locked"
        case .getLogCount:
            return "Get Log Count"
        case .getLogData:
            return "Get Log Data"
        case .gettokenArray:
            return "Get Token Array"
        case .gettokenData:
            return "Get Token Data"
        case .addtoken:
            return "Add Token"
        case .edittoken:
            return "Edit Token"
        case .deltoken:
            return "Delete Token"
        case .getAccessArray:
            return "Get Access Array"
        case .getAccessData:
            return "Get Access Data"
        case .addAccess:
            return "Add Access"
        case .editAccess:
            return "Edit Access"
        case .delAccess:
            return "Delete Access"
        case .disconnected:
            return "Disconnected"
        }
    }
}



enum Picker2Option: CaseIterable, CustomStringConvertible {
    case connecting
    case adminCodeExist
    case setAdminCode
    case editAdminCode
    case boltCheck
    case factoryReset
    case setDeviceName
    case getDeviceName
    case setTimeZone
    case setDeviceTime
    case getDeviceConfig
    case setDeviceConfig
    case getDeviceStatus
    case switchDevice
    case getLogCount
    case getLogData
    case gettokenArray
    case gettokenData
    case addtoken
    case edittoken
    case deltoken
    case getSupportAccess
    case getAccessArray
    case getAccessData
    case addAccess
    case editAccess
    case delAccess
    case disconnected
    
    var description: String {
        switch self {
        case .connecting:
            return "Connecting"
        case .adminCodeExist:
            return "Admin Code Exist"
        case .setAdminCode:
            return "Set Admin Code"
        case .editAdminCode:
            return "Edit Admin Code"
        case .boltCheck:
            return "Reset Bolt Direction"
        case .factoryReset:
            return "Factory Reset"
        case .setDeviceName:
            return "Set Device Name"
        case .setTimeZone:
            return "Set Timezone to Asia/Taipei"
        case .setDeviceTime:
            return "Set Device Time"
        case .getDeviceName:
            return "Get Device Name"
        case .getDeviceConfig:
            return "Get Device Config"
        case .setDeviceConfig:
            return "Set Device Config"
        case .getDeviceStatus:
            return "Get Device Status"
        case .switchDevice:
            return "Lock/Locked"
        case .getLogCount:
            return "Get Log Count"
        case .getLogData:
            return "Get Log Data"
        case .gettokenArray:
            return "Get Token Array"
        case .gettokenData:
            return "Get Token Data"
        case .addtoken:
            return "Add Token"
        case .edittoken:
            return "Edit Token"
        case .deltoken:
            return "Delete Token"
        case .getSupportAccess:
            return "Get Supported Access"
        case .getAccessArray:
            return "Get Access Array"
        case .getAccessData:
            return "Get Access Data"
        case .addAccess:
            return "Add Access"
        case .editAccess:
            return "Edit Access"
        case .delAccess:
            return "Delete Access"
        case .disconnected:
            return "Disconnected"
        }
    }
}




enum Picker3Option: CaseIterable, CustomStringConvertible {
    case connecting
    case adminCodeExist
    case setAdminCode
    case editAdminCode
    case boltCheck
    case factoryReset
    case setDeviceName
    case getDeviceName
    case setTimeZone
    case setDeviceTime
    case getDeviceConfig
    case setDeviceConfig
    case getDeviceStatus
    case switchDevice
    case getLogCount
    case getLogData
    case gettokenArray
    case gettokenData
    case addtoken
    case edittoken
    case deltoken
    case getUserCapabilities
    case isMatterDevice
    case getUserCredentialArray
    case getUserCredentialData
    case addUserCredential
    case editUserCredential
    case delUserCredential
    case getUserSupportedCount
    case getCredentialArray
    case getCredentialData
    case addCredential
    case editCredentail
    case deviceRetrieveCredential
    case delCredential
    case disconnected
    
    var description: String {
        switch self {
        case .connecting:
            return "Connecting"
        case .adminCodeExist:
            return "Admin Code Exist"
        case .setAdminCode:
            return "Set Admin Code"
        case .editAdminCode:
            return "Edit Admin Code"
        case .boltCheck:
            return "Reset Bolt Direction"
        case .factoryReset:
            return "Factory Reset"
        case .setDeviceName:
            return "Set Device Name"
        case .setTimeZone:
            return "Set Timezone to Asia/Taipei"
        case .setDeviceTime:
            return "Set Device Time"
        case .getDeviceName:
            return "Get Device Name"
        case .getDeviceConfig:
            return "Get Device Config"
        case .setDeviceConfig:
            return "Set Device Config"
        case .getDeviceStatus:
            return "Get Device Status"
        case .switchDevice:
            return "Lock/Locked"
        case .getLogCount:
            return "Get Log Count"
        case .getLogData:
            return "Get Log Data"
        case .gettokenArray:
            return "Get Token Array"
        case .gettokenData:
            return "Get Token Data"
        case .addtoken:
            return "Add Token"
        case .edittoken:
            return "Edit Token"
        case .deltoken:
            return "Delete Token"
        case .getUserCapabilities:
            return "Get User Capabilities"
        case .isMatterDevice:
            return "Is Matter Device"
        case .getUserCredentialArray:
            return "Get User Credential Array"
        case .getUserCredentialData:
            return "Get User Credential Data"
        case .addUserCredential:
            return "Add User Credential"
        case .editUserCredential:
            return "Edit User Credential"
        case .delUserCredential:
            return "Delete User Credential"
        case .getUserSupportedCount:
            return "Get User Supported Count"
        case .getCredentialArray:
            return "Get Credential Array"
        case .getCredentialData:
            return "Get Credentail Data"
        case .addCredential:
            return "Add Credentail"
        case .editCredentail:
            return "Edit Credentail"
        case .deviceRetrieveCredential:
            return "Device Retrieve Credential"
        case .delCredential:
            return "Delete Credential"
        case .disconnected:
            return "Disconnected"
        }
    }
}
