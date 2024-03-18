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
    case getUserArray
    case getUserData
    case addUser
    case editUser
    case delUser
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
        case .getUserArray:
            return "Get User Array"
        case .getUserData:
            return "Get User Data"
        case .addUser:
            return "Add User"
        case .editUser:
            return "Edit User"
        case .delUser:
            return "Delete User"
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
    case getUserArray
    case getUserData
    case addUser
    case editUser
    case delUser
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
        case .getUserArray:
            return "Get User Array"
        case .getUserData:
            return "Get User Data"
        case .addUser:
            return "Add User"
        case .editUser:
            return "Edit User"
        case .delUser:
            return "Delete User"
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
