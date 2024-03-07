//
//  VC+DeviceName.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/7.
//

import UIKit
import SunionBluetoothTool

extension ViewController {
    func showsetDeviceNameAlert() {
        let alertController = UIAlertController(title: "Set Device Name", message: "Enter up to 20 characters", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "Enter name here"
            textField.addTarget(self, action: #selector(self.showsetDeviceNameAlerttextFieldDidChange(_:)), for: .editingChanged)
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { _ in
            // 处理确认动作
            if let text = alertController.textFields?.first?.text {
                print("输入的文本: \(text)")
                SunionBluetoothTool.shared.setupDeviceName(name: text)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func showsetDeviceNameAlerttextFieldDidChange(_ textField: UITextField) {
        // 检查文本长度，并确保它不超过20个字符
        if let text = textField.text, text.count > 20 {
            // 如果文本超过20个字符，截取前20个字符
            textField.text = String(text.prefix(20))
        }
    }
}
