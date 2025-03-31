//
//  AddEditCredentialViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/22.
//

import UIKit
import SunionBluetoothTool

protocol AddEditCredentialViewControllerDelegate: AnyObject {
    func addEditCredential(model: CredentialRequestModel)
    func setupCardFpFace(model: SetupCredentialRequestModel, credentialreq: CredentialRequestModel)
}

class AddEditCredentialViewController: UIViewController {

    @IBOutlet weak var textFieldValue: UITextField!
    @IBOutlet weak var segmentType: UISegmentedControl!
    @IBOutlet weak var scanButton: UIButton!
    
    
    weak var delegate: AddEditCredentialViewControllerDelegate?
    var credientialIndex: Int?
    var userIndex: Int?
    var able: UserableResponseModel?
    var data: CredentialModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        configureTextField()
        
        
        
        if let supportCount = able {
            segmentType.removeAllSegments()
            var index = 0
            
   
            if supportCount.codeCount > 0 {
                segmentType.insertSegment(withTitle: "Code", at: index, animated: false)
                index += 1
                scanButton.isHidden = true
            }
            if supportCount.cardCount > 0 {
                segmentType.insertSegment(withTitle: "Card", at: index, animated: false)
                index += 1
                scanButton.isHidden = false
            }
            if supportCount.fpCount > 0 {
                segmentType.insertSegment(withTitle: "Fingerprint", at: index, animated: false)
                index += 1
                scanButton.isHidden = false
            }
            if supportCount.faceCount > 0 {
                segmentType.insertSegment(withTitle: "Face", at: index, animated: false)
                index += 1
                scanButton.isHidden = false
            }
            
            segmentType.selectedSegmentIndex = 0
        }
        
        if let data = data, let type = data.credentialDetailStruct?.first?.type, let data = data.credentialDetailStruct?.first?.data {
            textFieldValue.text = data
            
            switch type {
            case .pin:
                if let index = indexOfSegment(withTitle: "Code", inSegmentedControl: segmentType) {
                    segmentType.selectedSegmentIndex = index
                }
            case .rfid:
                if let index = indexOfSegment(withTitle: "Card", inSegmentedControl: segmentType) {
                    segmentType.selectedSegmentIndex = index
                }
            case .fingerprint:
                if let index = indexOfSegment(withTitle: "Fingerprint", inSegmentedControl: segmentType) {
                    segmentType.selectedSegmentIndex = index
                }
            case .face:
                if let index = indexOfSegment(withTitle: "Face", inSegmentedControl: segmentType) {
                    segmentType.selectedSegmentIndex = index
                }
            default:
                break
            }
      
        }
    }
    
    func indexOfSegment(withTitle title: String, inSegmentedControl segmentControl: UISegmentedControl) -> Int? {
        // 遍历所有的段
        for index in 0..<segmentControl.numberOfSegments {
            // 获取当前段的标题
            if let segmentTitle = segmentControl.titleForSegment(at: index) {
                // 比较当前段的标题是否与指定的标题相同
                if segmentTitle == title {
                    // 如果相同，返回当前索引
                    return index
                }
            }
        }
        // 如果没有找到匹配的段，返回nil
        return nil
    }
    
    @IBAction func segmentAction(_ sender: UISegmentedControl) {
        let typeName = sender.titleForSegment(at: sender.selectedSegmentIndex)
        textFieldValue.isEnabled = typeName == "Code"
        scanButton.isHidden = typeName == "Code"
    }
    
    
    @IBAction func scanButtonAction(_ sender: UIButton) {
        var type: CredentialStructModel.CredentialTypeEnum = .rfid
        
        switch segmentType.titleForSegment(at: segmentType.selectedSegmentIndex) {
        case "Card":
            type = .rfid
        case "Fingerprint":
            type = .fingerprint
        case "Face":
            type = .face
        default:
            break
        }
        
        let creIndex = data?.credientialIndex ?? self.credientialIndex ?? 1
        
        let model = SetupCredentialRequestModel(type: type, index: creIndex, state: .start)
        
        
        var credentialrequesttype: CredentialStructModel.CredentialTypeEnum = .pin
        let segmentValue = segmentType.titleForSegment(at: segmentType.selectedSegmentIndex)
        
        switch segmentValue {
        case "Code":
            credentialrequesttype = .pin
        case "Card":
            credentialrequesttype = .rfid
        case "Fingerprint":
            credentialrequesttype = .fingerprint
        case "Face":
            credentialrequesttype = .face
        default:
            break
        }
        
        let useri = data?.userIndex ?? self.userIndex ?? 1
        let CredentialDetailStructRequestModel = CredentialDetailStructRequestModel(credientialIndex: creIndex, status: .occupiedEnabled, type: credentialrequesttype, data: String(creIndex))
        let credentialrequestModel = CredentialRequestModel(userIndex:  useri, credentialData: CredentialDetailStructRequestModel, isCreate: data == nil ? true : false)
        
        self.delegate?.setupCardFpFace(model: model, credentialreq: credentialrequestModel)
        self.dismiss(animated: true)
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
        textFieldValue.inputAccessoryView = toolBar

        
        // 如果你的UITextField已经在Storyboard或者XIB中定义了，可以忽略创建UITextField的部分
        // 直接将上述代码添加到配置UITextField的地方
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @IBAction func buttonActionCancel(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func buttonActionConfirm(_ sender: UIButton) {
        
        var type: CredentialStructModel.CredentialTypeEnum = .pin
        let segmentValue = segmentType.titleForSegment(at: segmentType.selectedSegmentIndex)
        
        switch segmentValue {
        case "Code":
            type = .pin
        case "Card":
            type = .rfid
        case "Fingerprint":
            type = .fingerprint
        case "Face":
            type = .face
        default:
            break
        }
        
        
        let creIndex = data?.credientialIndex ?? self.credientialIndex ?? 1
        let useri = data?.userIndex ?? self.userIndex ?? 1
        let CredentialDetailStructRequestModel = CredentialDetailStructRequestModel(credientialIndex: creIndex, status: .occupiedEnabled, type: type, data: textFieldValue.text!)
        let model = CredentialRequestModel(userIndex:  useri, credentialData: CredentialDetailStructRequestModel, isCreate: data == nil ? true : false)
        delegate?.addEditCredential(model: model)
        self.dismiss(animated: true)
    }
    
}
