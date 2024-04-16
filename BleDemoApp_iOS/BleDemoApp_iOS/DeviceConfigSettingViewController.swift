//
//  DeviceConfigSettingViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/8.
//

import UIKit
import SunionBluetoothTool

protocol DeviceConfigSettingViewControllerDelegate: AnyObject {
    func config(data: DeviceSetupModel?,v3: Bool, N81: DeviceSetupModelN81?)
}

class DeviceConfigSettingViewController: UIViewController {
    

    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var vacationSwitch: UISwitch!
    @IBOutlet weak var autoLockSwitch: UISwitch!
    @IBOutlet weak var autoLockTimeTextField: UITextField!
    
    @IBOutlet weak var lonTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var guidingSwitch: UISwitch!
    
    @IBOutlet weak var stackViewV2: UIStackView!
    @IBOutlet weak var stackViewVoiceOffOn: UIStackView!
    @IBOutlet weak var stackViewVoiceLevel: UIStackView!
    @IBOutlet weak var stackViewVoiceProgress: UIStackView!
    
    @IBOutlet weak var stackViewSound: UIStackView!
    @IBOutlet weak var stackViewTwoFA: UIStackView!
    @IBOutlet weak var stackViewVirtualCode: UIStackView!
    @IBOutlet weak var stackViewFastMode: UIStackView!
    @IBOutlet weak var stackViewGuiding: UIStackView!
    @IBOutlet weak var stackViewVacation: UIStackView!
    @IBOutlet weak var stackViewAutoLock: UIStackView!
    @IBOutlet weak var stackViewAutoLockTime: UIStackView!
    @IBOutlet weak var stackViewVoice: UIStackView!
    
    @IBOutlet weak var swtichTwoFA: UISwitch!
    @IBOutlet weak var switchVirtualCode: UISwitch!
    @IBOutlet weak var switchFastMode: UISwitch!
    @IBOutlet weak var switchVoiceOffOn: UISwitch!
    @IBOutlet weak var segmentVoiceLevle: UISegmentedControl!
    @IBOutlet weak var textFieldVoiceProgress: UITextField!
    
    @IBOutlet weak var stackViewSabbathMode: UIStackView!
    @IBOutlet weak var switchSabbathMode: UISwitch!
    
    weak var delegate: DeviceConfigSettingViewControllerDelegate?
    
    var data: DeviceSetupResultModel?
    var n80: DeviceSetupResultModelN80?
    var v3 = false
    
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
            
            if let a = data.A0 {
                let amodel = DeviceSetupModelA1(direction: a.direction, soundOn: getCodeStatusValue(value: stackViewSound, element: soundSwitch), vacationModeOn: getCodeStatusValue(value: stackViewVacation, element: vacationSwitch), autoLockOn: getCodeStatusValue(value: stackViewAutoLock, element: autoLockSwitch), autoLockTime: Int(autoLockTimeTextField.text!) ?? 10, guidingCode: getCodeStatusValue(value: stackViewGuiding, element: guidingSwitch), virtualCode: getCodeStatusValue(value: stackViewVirtualCode, element: switchVirtualCode), twoFA: getCodeStatusValue(value: stackViewTwoFA, element: swtichTwoFA), latitude: Double(latTextField.text!) ?? 0.0, longitude: Double(lonTextField.text!) ?? 0.0, fastMode: getCodeStatusValue(value: stackViewFastMode, element: switchFastMode), voiceValue: getVoiceData())
                model.A1 = amodel
            }
            
            delegate?.config(data: model,v3: self.v3, N81: nil)
        }
        
        
        if let a = self.n80 {
            let nmodel = DeviceSetupModelN81(latitude: Double(latTextField.text!) ?? 0.0, longitude: Double(lonTextField.text!) ?? 0.0, guidingCode: getCodeStatusValue(value: stackViewGuiding, element: guidingSwitch), virtualCode: getCodeStatusValue(value: stackViewVirtualCode, element: switchVirtualCode), twoFA: getCodeStatusValue(value: stackViewTwoFA, element: swtichTwoFA), vacationModeOn: getCodeStatusValue(value: stackViewVacation, element: vacationSwitch), autoLockOn: getCodeStatusValue(value: stackViewAutoLock, element: autoLockSwitch), autoLockTime: Int(autoLockTimeTextField.text!) ?? 10, soundOn: getCodeStatusValue(value: stackViewSound, element: soundSwitch), fastMode: getCodeStatusValue(value: stackViewFastMode, element: switchFastMode), voiceValue: getVoiceData(), direction: a.direction, sabbathMode: getCodeStatusValue(value: stackViewSabbathMode, element: switchSabbathMode), language: a.language)
            delegate?.config(data: nil,v3: self.v3, N81: nmodel)
        }
        
   
        self.dismiss(animated: true)
    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func getVoiceData() -> VoiceValue {
        var value: VoiceValue = .error
        if stackViewVoiceOffOn.isHidden == false {
            value = switchVoiceOffOn.isOn ? .open : .close
        }
        
        if stackViewVoiceLevel.isHidden == false {
            if segmentVoiceLevle.selectedSegmentIndex == 0 {
                value = .loudly
            }
            
            if segmentVoiceLevle.selectedSegmentIndex == 1 {
                value = .whisper
            }
            
            if segmentVoiceLevle.selectedSegmentIndex == 2 {
                value = .close
            }
        }
        
        if stackViewVoiceProgress.isHidden == false {
            value = .value(Int(textFieldVoiceProgress.text!) ?? 10)
        }
        return value
    }
    
    private func getCodeStatusValue(value: UIStackView, element: UISwitch) -> CodeStatus {
        var statue: CodeStatus = .unsupport
    
        if value.isHidden == false {
            statue = element.isOn ? .open : .close
        }

        return statue
    }
    
    func setupData() {
        if let data = data {
            if let d = data.D4 {
                stackViewV2.isHidden = true
                stackViewSabbathMode.isHidden = true
                soundSwitch.isOn = d.soundOn
                vacationSwitch.isOn = d.vacationModeOn
                autoLockSwitch.isOn = d.autoLockOn
                autoLockTimeTextField.text = String(d.autoLockTime ?? 1)
                lonTextField.text = String(d.longitude ?? 0.0)
                latTextField.text = String(d.latitude ?? 0.0)
                guidingSwitch.isOn = d.guidingCode
            }
            
            if let a = data.A0 {
                stackViewV2.isHidden = false
                stackViewSabbathMode.isHidden = true
                lonTextField.text = String(a.longitude ?? 0.0)
                latTextField.text = String(a.latitude ?? 0.0)
                
                if a.sound == .unsupport || a.sound == .error {
                    stackViewSound.isHidden = true
                } else {
                    stackViewSound.isHidden = false
                    soundSwitch.isOn = a.sound == .open ? true : false
                }
                
                if a.guidingCode == .error || a.guidingCode == .unsupport {
                    stackViewGuiding.isHidden = true
                } else {
                    stackViewGuiding.isHidden = false
                    guidingSwitch.isOn = a.guidingCode == .open ? true : false
                }
                
                if a.virtualCode == .error || a.virtualCode == .unsupport {
                    stackViewVirtualCode.isHidden = true
                } else {
                    stackViewVirtualCode.isHidden = false
                    switchVirtualCode.isOn = a.virtualCode == .open ? true : false
                }
                
                if a.twoFA == .error || a.twoFA == .unsupport {
                    stackViewTwoFA.isHidden = true
                } else {
                    stackViewTwoFA.isHidden = false
                    swtichTwoFA.isOn = a.twoFA == .open ? true : false
                }
                
                if a.vacationMode == .error || a.vacationMode == .unsupport {
                    stackViewVacation.isHidden = true
                } else {
                    stackViewVacation.isHidden = false
                    vacationSwitch.isOn = a.vacationMode == .open ? true : false
                }
                
                if a.isAutoLock == .error || a.isAutoLock == .unsupport {
                    stackViewAutoLock.isHidden = true
                    stackViewAutoLockTime.isHidden = true
                } else {
                    autoLockSwitch.isOn = a.isAutoLock == .open ? true : false
                    autoLockTimeTextField.text = String(a.autoLockTime ?? 5)
                }
                
                if a.fastMode == .error || a.fastMode == .unsupport {
                    stackViewFastMode.isHidden = true
                } else {
                    switchFastMode.isOn = a.fastMode == .open ? true : false
                }
             
              
                
                if a.voiceType == .error {
                    stackViewVoice.isHidden = true
                } else {
                    stackViewVoice.isHidden = false
              
                    switch a.voiceType {
                    case .onoff:
                        stackViewVoiceProgress.isHidden = true
                        stackViewVoiceLevel.isHidden = true
                        stackViewVoiceOffOn.isHidden = false
                        switch a.voiceValue {
                        case .open:
                            switchVoiceOffOn.isOn = true
                        case .close:
                            switchVoiceOffOn.isOn = false
                        default:
                            break
                        }
                    case .level:
                        stackViewVoiceProgress.isHidden = true
                        stackViewVoiceLevel.isHidden = false
                        stackViewVoiceOffOn.isHidden = true
                        switch a.voiceValue {
                        case .loudly:
                            segmentVoiceLevle.selectedSegmentIndex = 0
                        case .whisper:
                            segmentVoiceLevle.selectedSegmentIndex = 1
                        case .close:
                            segmentVoiceLevle.selectedSegmentIndex = 2
                        default:
                            break
                        }
                    case .percentage:
                        stackViewVoiceProgress.isHidden = false
                        stackViewVoiceLevel.isHidden = true
                        stackViewVoiceOffOn.isHidden = true
                        switch a.voiceValue {
                        case .value(let value):
                            textFieldVoiceProgress.text = String(value)
                        default:
                            break
                        }
                    default:
                        break
                    }
                }
                
                
            }
    
        }
        
        
        if let a = self.n80 {
            stackViewV2.isHidden = false
            stackViewSabbathMode.isHidden = false
            lonTextField.text = String(a.longitude ?? 0.0)
            latTextField.text = String(a.latitude ?? 0.0)
            
            if a.sound == .unsupport || a.sound == .error {
                stackViewSound.isHidden = true
            } else {
                stackViewSound.isHidden = false
                soundSwitch.isOn = a.sound == .open ? true : false
            }
            
            if a.guidingCode == .error || a.guidingCode == .unsupport {
                stackViewGuiding.isHidden = true
            } else {
                stackViewGuiding.isHidden = false
                guidingSwitch.isOn = a.guidingCode == .open ? true : false
            }
            
            if a.virtualCode == .error || a.virtualCode == .unsupport {
                stackViewVirtualCode.isHidden = true
            } else {
                stackViewVirtualCode.isHidden = false
                switchVirtualCode.isOn = a.virtualCode == .open ? true : false
            }
            
            if a.twoFA == .error || a.twoFA == .unsupport {
                stackViewTwoFA.isHidden = true
            } else {
                stackViewTwoFA.isHidden = false
                swtichTwoFA.isOn = a.twoFA == .open ? true : false
            }
            
            if a.vacationMode == .error || a.vacationMode == .unsupport {
                stackViewVacation.isHidden = true
            } else {
                stackViewVacation.isHidden = false
                vacationSwitch.isOn = a.vacationMode == .open ? true : false
            }
            
            if a.isAutoLock == .error || a.isAutoLock == .unsupport {
                stackViewAutoLock.isHidden = true
                stackViewAutoLockTime.isHidden = true
            } else {
                autoLockSwitch.isOn = a.isAutoLock == .open ? true : false
                autoLockTimeTextField.text = String(a.autoLockTime ?? 5)
            }
            
            if a.sabbathMode == .error || a.sabbathMode == .unsupport {
                stackViewSabbathMode.isHidden = true
            } else {
                stackViewSabbathMode.isHidden = false
                switchSabbathMode.isOn = a.sabbathMode == .open ? true : false
            }
            
            if a.fastMode == .error || a.fastMode == .unsupport {
                stackViewFastMode.isHidden = true
            } else {
                switchFastMode.isOn = a.fastMode == .open ? true : false
            }
             

            if a.voiceType == .error {
                stackViewVoice.isHidden = true
            } else {
                stackViewVoice.isHidden = false
          
                switch a.voiceType {
                case .onoff:
                    stackViewVoiceProgress.isHidden = true
                    stackViewVoiceLevel.isHidden = true
                    stackViewVoiceOffOn.isHidden = false
                    switch a.voiceValue {
                    case .open:
                        switchVoiceOffOn.isOn = true
                    case .close:
                        switchVoiceOffOn.isOn = false
                    default:
                        break
                    }
                case .level:
                    stackViewVoiceProgress.isHidden = true
                    stackViewVoiceLevel.isHidden = false
                    stackViewVoiceOffOn.isHidden = true
                    switch a.voiceValue {
                    case .loudly:
                        segmentVoiceLevle.selectedSegmentIndex = 0
                    case .whisper:
                        segmentVoiceLevle.selectedSegmentIndex = 1
                    case .close:
                        segmentVoiceLevle.selectedSegmentIndex = 2
                    default:
                        break
                    }
                case .percentage:
                    stackViewVoiceProgress.isHidden = false
                    stackViewVoiceLevel.isHidden = true
                    stackViewVoiceOffOn.isHidden = true
                    switch a.voiceValue {
                    case .value(let value):
                        textFieldVoiceProgress.text = String(value)
                    default:
                        break
                    }
                default:
                    break
                }
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
