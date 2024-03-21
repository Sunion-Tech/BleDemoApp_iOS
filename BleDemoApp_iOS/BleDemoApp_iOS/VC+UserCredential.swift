//
//  VC+UserCredential.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/21.
//


import UIKit
import SunionBluetoothTool


extension ViewController {
    func showgetusercredentialDataAlert() {
        let alertController = UIAlertController(title: "Get User Credential Data", message: "Please enter user position", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.placeholder = "Enter position here"
         
     
        }
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { [weak alertController] (_) in
            guard let textField = alertController?.textFields?.first, let inputText = textField.text else { return }
            // 确认按钮的逻辑处理，可以在这里处理输入的文本
            print("输入的数字是：\(inputText)")
            SunionBluetoothTool.shared.getUserCredential(position: Int(inputText)!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    

}
