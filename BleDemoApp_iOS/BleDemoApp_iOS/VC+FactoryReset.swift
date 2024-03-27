//
//  VC+FactoryReset.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/7.
//


import UIKit
import SunionBluetoothTool


extension ViewController {
    func showfactoryResetAlert(v3: Bool = false) {
        let alertController = UIAlertController(title: "Factory Reset", message: "Please enter Admin Code", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Enter numbers here"
            // 对于iOS 13及以上版本，可以直接在这里使用闭包进行字符检查
            textField.addTarget(self, action: #selector(self.showfactoryResetAlerttextFieldDidChange(_:)), for: .editingChanged)
        
     
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak alertController] (_) in
            guard let textField = alertController?.textFields?.first, let inputText = textField.text else { return }
            // 确认按钮的逻辑处理，可以在这里处理输入的文本
            print("输入的数字是：\(inputText)")
            let digit = inputText.compactMap{Int(String($0))}
            if v3 {
                SunionBluetoothTool.shared.UseCase.utility.factoryResetDevice(adminCode: digit)
            } else {
                SunionBluetoothTool.shared.factoryReset(adminCode: digit)
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func showfactoryResetAlerttextFieldDidChange(_ textField: UITextField) {
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
