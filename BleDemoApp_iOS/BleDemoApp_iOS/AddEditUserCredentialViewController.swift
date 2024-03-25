//
//  AddEditUserCredentialViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/22.
//

import UIKit
import SunionBluetoothTool

class AddEditUserCredentialViewController: UIViewController {

    @IBOutlet weak var segmentType: UISegmentedControl! // 0: unrest //1: year // 2: week // 3: forced // 4: disposed
    @IBOutlet weak var segmentStatus: UISegmentedControl! //0: av // 1: ocen // 2: ocDis
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var labelTitle: UILabel!
    var index: Int?
    var isCreate: Bool?
    
    var able: UserableResponseModel?
    var data: UserCredentialModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let data = data {
            labelTitle.text = "edit User Credential"
            textFieldName.text = data.name
            switch data.type {
            case .unrestrictedUser:
                segmentType.selectedSegmentIndex = 0
            case .yearDayScheduleUser:
                segmentType.selectedSegmentIndex = 1
            case .weekDayScheduleUser:
                segmentType.selectedSegmentIndex = 2
            case .forcedUser:
                segmentType.selectedSegmentIndex = 3
            case .disposableUser:
                segmentType.selectedSegmentIndex = 4
            default:
                break
            }
            
            switch data.status {
            case .occupiedEnabled:
                segmentStatus.selectedSegmentIndex = 0
            case .occupiedDisabled:
                segmentStatus.selectedSegmentIndex = 1
            default:
                break
            }
        } else {
            labelTitle.text = "add User Credential"
        }
        
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
        textFieldName.inputAccessoryView = toolBar

        
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
        var statu: UserCredentialModel.UserStatusEnum = .occupiedEnabled
        switch segmentStatus.selectedSegmentIndex {
        case 0:
            statu = .occupiedEnabled
        case 1:
            statu = .occupiedDisabled
 
        default:
            break
        }
        
        var type: UserCredentialModel.UserTypeEnum = .unrestrictedUser
        switch segmentType.selectedSegmentIndex {
        case 0:
            type = .unrestrictedUser
        case 1:
            type = .yearDayScheduleUser
        case 2:
            type = .weekDayScheduleUser
        case 3:
            type = .forcedUser
        case 4:
            type = .disposableUser
        default:
            break
        }
        
        var years: [YearDayscheduleStructRequestModel] = []
        var weeks: [WeekDayscheduleStructRequestModel] = []
        var ss: [CredentialStructRequestModel] = []
        if let able = able {
  
      

            for _ in 0..<able.yeardayCount {
                    let value = YearDayscheduleStructRequestModel(status: .available, start: Date(), end: Date())
                    years.append(value)
                }
            
            
 
              
            for _ in 0..<able.weekdayCount {
                    let value = WeekDayscheduleStructRequestModel(status: .available, daymask: .friday, startHour: "8", startMinute: "00", endHour: "17", endMinute: "00")
                    weeks.append(value)
                }
            
            
    
          
            for _ in 0..<able.codeCount {
                    let value = CredentialStructRequestModel(type: .pin, index: 65535)
                    ss.append(value)
                }
            
        }
        
        if let data = data {
            data.yearDayscheduleStruct.forEach { el in
                let value = YearDayscheduleStructRequestModel(status: el.status, start: el.start!, end: el.end!)
                years.append(value)
            }
            data.weekDayscheduleStruct.forEach { el in
                let value = WeekDayscheduleStructRequestModel(status: el.status, daymask: el.daymask!, startHour: el.startHour!, startMinute: el.startMinute!, endHour: el.endHour!, endMinute: el.endMinute!)
                weeks.append(value)
            }
            data.credentialStruct.forEach { el in
                let value = CredentialStructRequestModel(type: el.type, index: el.index!)
                ss.append(value)
            }
        }
        
        
        let model = UserCredentialRequestModel(isCreate: isCreate!, index: self.index!, name: textFieldName.text!, uid: 0, status: statu, type: type, credentialRule: .single, credentialStruct: ss, weekDayscheduleStruct: weeks, yearDayscheduleStruct: years)
        SunionBluetoothTool.shared.userCredentialAction(model: model)
        self.dismiss(animated: true)
    }
}
