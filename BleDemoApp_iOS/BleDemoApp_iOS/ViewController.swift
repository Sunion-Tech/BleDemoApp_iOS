//
//  ViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/6.
//

import UIKit
import SunionBluetoothTool

class ViewController: UIViewController, ScanViewControllerDelegate {
    @IBOutlet weak var qrCodeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var bleBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var BLEIMG: UIBarButtonItem!
    
    private let pickerView = UIPickerView()
    
    // 假设这是你的数据源
    private var pickerData = Picker1Option.allCases
    
    private var selectedRow = 0
    var isEditAdminCode = false
    
    var modelName = ""
    var config: DeviceSetupResultModel?
    var status: DeviceStatusModel?
    var token: TokenModel?
    var tokenIndex: Int?
    
    var timezonetextField: UITextField?
    let timezonepickerView = UIPickerView()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        textField.isEnabled = false
    }
    

    // MARK: - QrCode Data
    func QrCodeData(model: BluetoothToolModel) {
        if let token = model.token,
           let aes1 = model.aes1Key,
           let mac = model.macAddress,
           let name = model.modelName {
            let msg = "token: \(token.toHexString())\n aes1Key: \(aes1.toHexString())\n macAddress: \(mac)\n modelName: \(name)"
            SunionBluetoothTool.shared.initBluetooth(macAddress: mac, aes1Key: Array(aes1), token: Array(token))
            if SunionBluetoothTool.shared.delegate == nil {
                SunionBluetoothTool.shared.delegate = self
            }
            modelName = name
            switch modelName {
            case "KD0":
                pickerData = Picker1Option.allCases
            default:
                break
            }
            
            setupPickerView()
            appendLogToTextView(logMessage: msg)
            textField.isEnabled = true
        }
       
    }
    
    func getCurrentTimeString() -> String {
        let now = Date()
        let formatter = DateFormatter()
        // 设置日期格式，这里使用的格式为：月 日 时:分:秒
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: now)
    }
    
    func appendLogToTextView(logMessage: String) {
        // 获取当前时间的字符串
        let timeString = getCurrentTimeString()
        // 构建日志字符串，包括时间和操作消息
        let logString = "---\(timeString)---\n \(logMessage)\n ------"
        
        // 确保在主线程更新UI
        DispatchQueue.main.async {
            // 将新的日志信息附加到textView的现有文本中
            self.textView.text.append(contentsOf: logString)
            
            // 可选：滚动到textView的底部，以便最新的日志信息可见
            let range = NSMakeRange(self.textView.text.count - 1, 1)
            self.textView.scrollRangeToVisible(range)
        }
    }
    
    func setupPickerView() {
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // 创建一个工具条
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        // 添加一个取消按钮到工具条的左侧
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelPicker))
            
        
        // 添加一个确认按钮
        let doneButton = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        // 通过在两个按钮之间添加一个flexible space bar button item来使这两个按钮分别对齐到左侧和右侧
         let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
         
         // 设置工具条的items，包括取消按钮、弹性空间和确认按钮
         toolBar.setItems([cancelButton, flexibleSpace, doneButton], animated: false)
         
        toolBar.isUserInteractionEnabled = true
        
        // 将pickerView和工具条设置为textField的inputView和inputAccessoryView
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
    }
    
    @objc func cancelPicker() {
        // 执行取消操作，比如可以清除textField的文本，然后关闭pickerView
        view.endEditing(true)
    }
    
    // MARK: - Action
    @objc func dismissKeyboard() {
        // 关闭pickerView
        view.endEditing(true)
        let data = pickerData[selectedRow]
        switch data {
        case .connecting:
            appendLogToTextView(logMessage: "Connecting...")
            SunionBluetoothTool.shared.connectingBluetooth()
        case .adminCodeExist:
            SunionBluetoothTool.shared.isAdminCode()
        case .setAdminCode:
            isEditAdminCode = false
            showsetAdminCodeAlert()
        case .editAdminCode:
            isEditAdminCode = true
            showEditAdminCodeAlert()
        case .boltCheck:
            SunionBluetoothTool.shared.blotCheck()
        case .factoryReset:
            showfactoryResetAlert()
        case .setDeviceName:
            showsetDeviceNameAlert()
        case .getDeviceName:
            SunionBluetoothTool.shared.getDeviceName()
        case .setTimeZone:
            SunionBluetoothTool.shared.setupTimeZone(timezone: "Asia/Taipei")
        case .setDeviceTime:
            SunionBluetoothTool.shared.setupDeviceTime()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.appendLogToTextView(logMessage: "set Device Time successfully")
            }
        case .getDeviceConfig:
            switch modelName {
            case "KD0":
                SunionBluetoothTool.shared.getDeviceConfigD4()
            default:
                break
            }
        case .setDeviceConfig:
            
            if let config = config {
                self.performSegue(withIdentifier: "config", sender: nil)
            } else {
                showAlert(title: "Please Get Device Config first", message: "")
            }
           
      
        case .getDeviceStatus:
            SunionBluetoothTool.shared.getDeviceStatus()
        case .switchDevice:
            var lockMode: CommandService.DeviceMode = .unlock
            switch modelName {
            case "KD0":
                if status?.D6?.isLocked == .locked {
                    lockMode = .unlock
                }else {
                    lockMode = .lock
                }
            default:
                break
            }
            SunionBluetoothTool.shared.switchDevice(mode: lockMode)
        case .getLogCount:
            SunionBluetoothTool.shared.getLogCount()
        case .getLogData:
            showgetLogDataAlert()
        case .getUserArray:
            SunionBluetoothTool.shared.getTokenArray()
        case .getUserData:
            showgetUserDataAlert()
        case .addUser:
            self.performSegue(withIdentifier: "user", sender: "add")
     
        case .editUser:
            if let token = token {
                if token.isOwnerToken == .owner {
                    showAlert(title: "Editing of the Owner is not allowed", message: "")
                } else {
                    self.performSegue(withIdentifier: "user", sender: "edit")
                }
               
            } else {
                showAlert(title: "Please Get User Data first", message: "")
            }
          
        case .delUser:
            if let token = token {
                if token.isOwnerToken == .owner {
                    showAlert(title: "deleting the Owner is not allowed", message: "")
                } else {
                    SunionBluetoothTool.shared.delToken(model: token)
                }
              
            } else {
                showAlert(title: "Please Get User Data first", message: "")
            }
        case .getAccessArray:
            SunionBluetoothTool.shared.getPinCodeArray()
        case .getAccessData:
            SunionBluetoothTool.shared.getPinCode(position: 1)
        case .addAccess:
            let model = PinCodeManageModel(index: 1, isEnable: true, PinCode: [1,2,3,4], name: "DemoAccess", schedule: .init(availableOption: .all), PinCodeManageOption: .add)
            SunionBluetoothTool.shared.pinCodeOption(model: model)
        case .editAccess:
            let model = PinCodeManageModel(index: 1, isEnable: true, PinCode: [2,3,4,1], name: "DemoAccess", schedule: .init(availableOption: .all), PinCodeManageOption: .edit)
            SunionBluetoothTool.shared.pinCodeOption(model: model)
        case .delAccess:
            SunionBluetoothTool.shared.delPinCode(position: 1)
        case .disconnected:
            SunionBluetoothTool.shared.disconnectBluetooth()
            appendLogToTextView(logMessage: "Disconnected")
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "qrcode",
           let vc = segue.destination as? ScanViewController {
            vc.delegate = self
        }
        
        if let id = segue.identifier, id == "config",
           let vc = segue.destination as? DeviceConfigSettingViewController {
            vc.data = self.config
            vc.delegate = self
        }
        
        if let id = segue.identifier, id == "user",
           let vc = segue.destination as? UserOptionViewController {
            if sender as! String == "edit" {
                vc.data = self.token
            }
            vc.delegate = self
        }
    }

}

extension ViewController: UserOptionViewControllerDelegate {
    func optionData(add: AddTokenModel?, edit: EditTokenModel?) {
        if let add = add {
            SunionBluetoothTool.shared.createToken(model: add)
        }
        
        if let edit = edit {
            SunionBluetoothTool.shared.editToken(model: edit)
        }
    }
    
    
}

extension ViewController: DeviceConfigSettingViewControllerDelegate {
    func config(data: DeviceSetupModel) {
        SunionBluetoothTool.shared.setupDeviceConfig(data: data)
    }

}


extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    // UIPickerViewDataSource 和 UIPickerViewDelegate 方法
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row].description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // 当选中一个选项时，更新textField的文本
        selectedRow = row
    }
}
 


extension ViewController: SunionBluetoothToolDelegate {
    func BluetoothState(State: bluetoothState) {
        switch State {
        case .enable:
            break
        case .connecting:
            break
        case .connected(_):
            appendLogToTextView(logMessage: "Connected")
            BLEIMG.tintColor = .blue
            BLEIMG.isEnabled = true
        case .disable:
            break
        case .disconnect(let error):
            BLEIMG.tintColor = .black
            BLEIMG.isEnabled = false
            switch error {
            case .deviceRefused:
                
                appendLogToTextView(logMessage: "Connection failed")
            case .illegalToken:
                appendLogToTextView(logMessage: "You don\'t have access to this lock")
            case .normal:
                break
            default:
                appendLogToTextView(logMessage: "Disconnected")
              
            }
        }
    }
    
    func DeviceStatus(value: DeviceStatusModel?) {
        status = value
        var msg = ""
        if let a = value?.A2 {
            
        }
        
        if let d = value?.D6 {
            msg = "lockDirection: \(d.lockDirection.rawValue)\n soundOn: \(d.soundOn)\n vacationMode: \(d.vacationModeOn)\n autoLockOn: \(d.autoLockOn)\n autoLockTime: \(d.autoLockTime ?? 0000)\n guidingCode: \(d.guidingCode)\n isLocked: \(d.isLocked)\n battery: \(d.battery ?? 0000)\n batteryWarning: \(d.batteryWarning.rawValue)\n timestamp: \(d.timestamp ?? 0000)"
        }
        
        if let n = value?.N82 {
            
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func AdminCode(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "adminCode set successfully")
        } else {
            appendLogToTextView(logMessage: "adminCode setting failed")
        }
    }
    
    func EditAdminCode(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "adminCode edit successfully")
        } else {
            appendLogToTextView(logMessage: "adminCode edit failed")
        }
    }
    
    func AdminCodeExist(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "adminCode exists")
        } else {
            appendLogToTextView(logMessage: "adminCode does not exist")
        }
    }
    
    func FactoryReset(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "factoryRest successfully")
        } else {
            appendLogToTextView(logMessage: "factoryRest failed")
        }
    }
    
    func DeviceName(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "set device name successfully")
        } else {
            appendLogToTextView(logMessage: "set device name failed")
        }
    }
    
    func DeviceNameData(value: String?) {
        if let value = value {
            appendLogToTextView(logMessage: "get device name successfully: \(value)")
        } else {
            appendLogToTextView(logMessage: "get device name failed")
        }
    }
    
    func TimeZone(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "set timezone successfully")
        } else {
            appendLogToTextView(logMessage: "set timezone failed")
        }
    }
    
    func DeviceConfig(value: DeviceSetupResultModel?) {
        config = value
        var msg = ""
        if let value = value {
            if let d = value.D4 {
                msg = "lockDirection: \(d.lockDirection.rawValue)\n soundOn: \(d.soundOn)\n vacationMode: \(d.vacationModeOn)\n autoLockOn: \(d.autoLockOn)\n autoLockTime: \(d.autoLockTime ?? 0000)\n guidingCode: \(d.guidingCode)\n latitude: \(d.latitude ?? 0000)\n longitude: \(d.longitude ?? 0000)"
            }
            
            if let a = value.A0 {
                
            }
            
            if let n = value.N80 {
                
            }
            
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "get device config failed")
        }
    }
    
    func Config(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "set device config successfully")
        } else {
            appendLogToTextView(logMessage: "set device config failed")
        }
    }
    
    func LogCount(value: Int?) {
        if let value = value {
            appendLogToTextView(logMessage: "get log count successfully: \(value)")
        } else {
            appendLogToTextView(logMessage: "get log count failed")
        }
    }
    
    func LogData(value: LogModel?) {
        if let value = value {
            let msg = "timestamp: \(value.timestamp)\n event: \(value.event)\n name: \(value.name)\n message: \(value.message ?? "")"
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "get log data failed")
        }
    }
    
    func TokenArray(value: [Int]?) {
        if let value = value {
            appendLogToTextView(logMessage: "get user array successfully: \(value)")
        } else {
            appendLogToTextView(logMessage: "get user array failed")
        }
    }
    
    func TokenData(value: TokenModel?) {
        if let value = value {
            token = value
            if value.isOwnerToken == .notOwner {
                token?.indexOfToken = tokenIndex
            }
            let msg = "isenable: \(value.isEnable)\n tokenmode: \(value.tokenMode.rawValue)\n isowner: \(value.isOwnerToken.rawValue)\n tokenpermission: \(value.tokenPermission.rawValue)\n token: \(value.token?.toHexString() ?? "")\n name: \(value.name ?? "")\n indexoftoken: \(value.indexOfToken ?? 0000)"
            
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "get user data failed")
        }
    }
    
    func TokenOption(value: AddTokenResult?) {
        if let value = value {
            let msg = "isSuccess: \(value.isSuccess)\n token: \(value.token?.toHexString() ?? "")\n index: \(value.index ?? 0000)"
            tokenIndex = value.index
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "add user failed")
        }
    }
    
    func Token(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "del user successfully")
        } else {
            appendLogToTextView(logMessage: "del user failed")
        }
    }
    
    func EditToken(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "edit user successfully")
        } else {
            appendLogToTextView(logMessage: "edit user failed")
        }
    }
    
    func PinCodeArray(value: PinCodeArrayModel?) {
        if let value = value {
            let msg = "count: \(value.count)\n data: \(value.data)\n firstemptyindex: \(value.firstEmptyIndex)"
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "get access array failed")
        }
    }
    
    func PinCodeData(value: PinCodeModelResult?) {
        if let value = value {
            let msg = "isenable: \(value.isEnable)\n code: \(value.PinCode ?? [0000])\n length: \(value.PinCodeLength ?? 0x00)\n name: \(value.name ?? "")\n schedule: \(value.schedule?.scheduleOption.scheduleName ?? "")"
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "get access data failed")
        }
    }
    
    func PinCode(bool: Bool?) {
        if let bool = bool {
            appendLogToTextView(logMessage: "add/edit/del access data successfully")
        } else {
            appendLogToTextView(logMessage: "add/edit/edl access data failed")
        }
    }
    

    
}
