//
//  DeviceConfigSettingViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/8.
//

import UIKit
import SunionBluetoothTool

protocol DeviceConfigSettingViewControllerDelegate: AnyObject {
    func config(data: DeviceSetupModel)
}

class DeviceConfigSettingViewController: UIViewController {
    

    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var vacationSwitch: UISwitch!
    @IBOutlet weak var autoLockSwitch: UISwitch!
    @IBOutlet weak var autoLockTimeTextField: UITextField!
    
    @IBOutlet weak var lonTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var guidingSwitch: UISwitch!
    
    weak var delegate: DeviceConfigSettingViewControllerDelegate?
    
    var data: DeviceSetupResultModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupData()
        configureTextField()
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        let model = DeviceSetupModel()
        if let data = data {
            if let d = data.D4 {
                let dmodel = DeviceSetupModelD5(soundOn: soundSwitch.isOn, vacationModeOn: vacationSwitch.isOn, autoLockOn: autoLockSwitch.isOn, autoLockTime: Int(autoLockTimeTextField.text!) ?? 1, guidingCode: guidingSwitch.isOn, latitude: Double(latTextField.text!) ?? 0.0, longitude: Double(lonTextField.text!) ?? 0.0)
                model.D5 = dmodel
            }
        }
        
        delegate?.config(data: model)
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    func setupData() {
        if let data = data {
            if let d = data.D4 {
                soundSwitch.isOn = d.soundOn
                vacationSwitch.isOn = d.vacationModeOn
                autoLockSwitch.isOn = d.autoLockOn
                autoLockTimeTextField.text = String(d.autoLockTime ?? 1)
                lonTextField.text = String(d.longitude ?? 0.0)
                latTextField.text = String(d.latitude ?? 0.0)
                guidingSwitch.isOn = d.guidingCode
            }
        }
    }
    
    func configureTextField() {
        let textField = UITextField() // 假设这是你的UITextField
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
        latTextField.inputAccessoryView = toolBar
        lonTextField.inputAccessoryView = toolBar
        autoLockTimeTextField.inputAccessoryView = toolBar
        
        // 如果你的UITextField已经在Storyboard或者XIB中定义了，可以忽略创建UITextField的部分
        // 直接将上述代码添加到配置UITextField的地方
    }

    

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

}
