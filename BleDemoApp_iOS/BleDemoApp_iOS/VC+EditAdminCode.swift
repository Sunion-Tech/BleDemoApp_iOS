//
//  VC+EditAdminCode.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/7.
//

import UIKit
import SunionBluetoothTool

extension ViewController {
    func showEditAdminCodeAlert() {
        let alertController = UIAlertController(title: "Edit Admin Code", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Old Admin Code"
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(self.showEditAdminCodeAlerttextFieldDidChange(_:)), for: .editingChanged)
        }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "New Admin Code"
            textField.isSecureTextEntry = true
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(self.showEditAdminCodeAlerttextFieldDidChange(_:)), for: .editingChanged)
        }
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { [weak alertController] _ in
            guard let textFields = alertController?.textFields, textFields.count == 2 else { return }
            let oldPassword = textFields[0].text ?? ""
            let newPassword = textFields[1].text ?? ""
            // 在这里处理密码更新逻辑
            SunionBluetoothTool.shared.editAdminCode(oldCode: oldPassword, newCode: newPassword)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(updateAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func showEditAdminCodeAlerttextFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        
          // 仅允许数字输入
          let filteredText = text.filter { "0123456789".contains($0) }
          
          // 限制长度为4到8个字符
          let maxLength = 8
          let minLength = 4
          let updatedText: String
          if filteredText.count > maxLength {
              updatedText = String(filteredText.prefix(maxLength))
          } else {
              updatedText = filteredText
          }
          
          // 更新textField的文本
          textField.text = updatedText
          
          // 如果文本不符合要求（比如不在4到8个字符之间），可以在这里添加额外的UI反馈
          if updatedText.count < minLength {
              // 可以设置textField的背景颜色，提示用户输入不足
              textField.backgroundColor = UIColor.red.withAlphaComponent(0.1)
          } else {
              // 恢复正常背景色
              textField.backgroundColor = nil
          }
    }

}
