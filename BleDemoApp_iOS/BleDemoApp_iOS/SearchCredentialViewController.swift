//
//  SearchCredentialViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/22.
//

import UIKit
import SunionBluetoothTool

protocol SearchCredentialViewControllerDelegate: AnyObject {
    func searchC(model: SearchCredentialRequestModel)
}

class SearchCredentialViewController: UIViewController {

    @IBOutlet weak var textFieldIndex: UITextField!
    @IBOutlet weak var segmentFormat: UISegmentedControl!
    
    weak var delegate: SearchCredentialViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTextField()
    }
    
    func configureTextField() {
      
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // 创建“取消”按钮
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissKeyboard))
        
        // 创建弹性空间，让两个按钮分布在两边
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        // 创建“完成”按钮
        let doneButton = UIBarButtonItem(title: "Confirm", style: .done, target: self, action: #selector(dismissKeyboard))
        
        // 将按钮添加到工具条
        toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
        
        // 将工具条设置为UITextField的accessoryView
        textFieldIndex.inputAccessoryView = toolBar

        
        // 如果你的UITextField已经在Storyboard或者XIB中定义了，可以忽略创建UITextField的部分
        // 直接将上述代码添加到配置UITextField的地方
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    


    @IBAction func buttonActionCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func buttonActionComfirm(_ sender: UIButton) {
        var format: CredentialModel.FormatEnum = .user
        if segmentFormat.selectedSegmentIndex == 1 {
            format = .credential
        }
        var model = SearchCredentialRequestModel(format: format, index: Int(textFieldIndex.text!)!)
        
        delegate?.searchC(model: model)
        self.dismiss(animated: true)
        
    }
    
}
