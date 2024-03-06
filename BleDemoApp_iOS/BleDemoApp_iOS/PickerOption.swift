//
//  PickerOption.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/6.
//

import Foundation

enum Picker1Option: CaseIterable, CustomStringConvertible {
    case connecting
    case addAdminCode
 
    case adminCodeExist
    case disconnected
    
    var description: String {
        switch self {
        case .connecting:
            return "Connecting"
        case .addAdminCode:
            return "Add admin Code"
        case .adminCodeExist:
            return "Admin Code Exist"
        case .disconnected:
            return "Disconnected"
        }
    }
}
