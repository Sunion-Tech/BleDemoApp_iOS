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
    private var pickerData: PickerOption?
    private var cmd10Datas = Picker1Option.allCases
    private var cmd20Datas = Picker2Option.allCases
    private var cmd30Datas = Picker3Option.allCases
    
    private var selectedRow = 0
    var isAdminCode = false
    
    var modelName = ""
    var config: DeviceSetupResultModel?
    var status: DeviceStatusModel?
    var token: TokenModel?
    var tokenIndex: Int?
    var accessFirstEmptyIndex: Int?
    var accessData: PinCodeModelResult?
    var accessData2: AccessDataResponseModel?
    
    var timezonetextField: UITextField?
    let timezonepickerView = UIPickerView()
    

    var supportCode: Int?
    var supportCard: Int?
    var supportFace: Int?
    var supportFinger: Int?
    
    var isV2 = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.isEnabled = false
    }
    
    
    // MARK: - QrCode Data
    func QrCodeData(model: BluetoothToolModel?, uuid: String?) {
        if let token = model?.token,
           let aes1 = model?.aes1Key,
           let mac = model?.macAddress,
           let name = model?.modelName {
            isAdminCode = false
            let msg = "token: \(token.toHexString())\n aes1Key: \(aes1.toHexString())\n macAddress: \(mac)\n modelName: \(name)"
            SunionBluetoothTool.shared.initBluetooth(macAddress: mac, aes1Key: Array(aes1), token: Array(token), v3udid: nil)
            if SunionBluetoothTool.shared.delegate == nil {
                SunionBluetoothTool.shared.delegate = self
            }
            modelName = name
            switch modelName {
            case "KD0", "TD0":
                isV2 = false
                pickerData = .cmd1O
            case "TLR0":
                isV2 = true
                pickerData = .cmd2O
            case "KD01":
                pickerData = .cmd30
            default:
                break
            }
            
            setupPickerView()
            appendLogToTextView(logMessage: msg)
            textField.isEnabled = true
        }
        
        if let uuid = uuid {
            fetchProductionData(code: uuid) { result in
                switch result {
                case .success(let success):
                    // 成功获取到数据，尝试解析JSON
                    do {
                        // 尝试将Data对象解码为JSON对象
                        if let jsonObject = try JSONSerialization.jsonObject(with: success, options: []) as? [String: Any] {
                            // 成功解码，jsonObject现在是一个[String: Any]字典
                            print(jsonObject)
                            // TODO: cmd30
                            self.pickerData = .cmd30
                          //  let aes1 = (jsonObject["key"] as! String).data(using: .utf8)
                         //   let token = (jsonObject["token"] as! String).data(using: .utf8)
                            let aes1 =   Data.init((jsonObject["key"] as! String).hexStringTobyteArray).bytes
                            let token = Data.init((jsonObject["token"] as! String).hexStringTobyteArray).bytes
                            SunionBluetoothTool.shared.initBluetooth(macAddress: nil, aes1Key: Array(aes1), token: Array(token), v3udid: uuid)
                            if SunionBluetoothTool.shared.delegate == nil {
                                SunionBluetoothTool.shared.delegate = self
                            }
                            DispatchQueue.main.async {
                                self.appendLogToTextView(logMessage: self.convertDictionaryToString(jsonObject)!)
                                self.setupPickerView()
                                self.textField.isEnabled = true
                            }
                            
                        } else {
                            self.appendLogToTextView(logMessage: "get qrcode data failed")
                        }
                    } catch {
                        // 处理解码过程中出现的错误
                        self.appendLogToTextView(logMessage: "get qrcode data failed")
                    }
                  
                case .failure(let failure):
                    // 处理错误
                    self.appendLogToTextView(logMessage: "get qrcode data failed")
                    
                }
            }
        }

        
    }
    
    func convertDictionaryToString(_ dictionary: [String: Any]) -> String? {
        do {
            // 将字典转换为JSON Data
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            // 将JSON Data转换为String
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Error converting dictionary to string: \(error)")
            return nil
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
        var data: Any? = nil
      
        if pickerData == .cmd1O {
            data = cmd10Datas[selectedRow]
        }
        
        if pickerData == .cmd2O {
            data = cmd20Datas[selectedRow]
        }
        
        if pickerData == .cmd30 {
            data = cmd30Datas[selectedRow]
        }
        
        
        
        
        if let data = data as? Picker1Option {
            
            if data == .adminCodeExist ||
                data == .setAdminCode ||
                data == .connecting {
                switch data {
                case .connecting:
                    appendLogToTextView(logMessage: "Connecting...")
                    SunionBluetoothTool.shared.connectingBluetooth()
                case .adminCodeExist:
                    SunionBluetoothTool.shared.isAdminCode()
                case .setAdminCode:
                    showsetAdminCodeAlert()
                default:
                    break
                }
            } else if !isAdminCode{
                showAlert(title: "Please Set Admin Code first", message: "")
            } else {
                switch data {
                case .adminCodeExist:
                    SunionBluetoothTool.shared.isAdminCode()
                case .setAdminCode:
                    showsetAdminCodeAlert()
                case .editAdminCode:
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
                    SunionBluetoothTool.shared.getDeviceConfigD4()
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
                    if status?.D6?.isLocked == .locked {
                        lockMode = .unlock
                    }else {
                        lockMode = .lock
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
                    showgetAccessDataAlert()
                case .addAccess:
                    if let firstEmptyIndex = accessFirstEmptyIndex, accessData == nil {
                        self.performSegue(withIdentifier: "access", sender: true)
                    } else {
                        showAlert(title: "Please Get Access Array first", message: "")
                    }
                 

                case .editAccess:
                    if let data = accessData {
                        self.performSegue(withIdentifier: "access", sender: false)
                    } else {
                        showAlert(title: "Please Get Access Data first", message: "")
                    }

                case .delAccess:
                    showdelAccesAlert()
                
                case .disconnected:
                    SunionBluetoothTool.shared.disconnectBluetooth()
                    appendLogToTextView(logMessage: "Disconnected")
                default:
                    break
                }
            }
        }
        
        if let data = data as? Picker2Option {
            if data == .adminCodeExist ||
                data == .setAdminCode ||
                data == .connecting {
                switch data {
                case .connecting:
                    appendLogToTextView(logMessage: "Connecting...")
                    SunionBluetoothTool.shared.connectingBluetooth()
                case .adminCodeExist:
                    SunionBluetoothTool.shared.isAdminCode()
                case .setAdminCode:
                    showsetAdminCodeAlert()
                default:
                    break
                }
            } else if !isAdminCode{
                showAlert(title: "Please Set Admin Code first", message: "")
            } else {
                switch data {
                case .adminCodeExist:
                    SunionBluetoothTool.shared.isAdminCode()
                case .setAdminCode:
                    showsetAdminCodeAlert()
                case .editAdminCode:
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
                    SunionBluetoothTool.shared.getDeviceConfigA0()
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
                    if status?.A2?.lockState == .lockedUnlinked {
                        lockMode = .unlock
                    } else {
                        lockMode = .lock
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
                    if let card = supportCard, let code = supportCode, let face = supportFace, let finger = supportFinger {
                        self.performSegue(withIdentifier: "accessarray", sender: nil)
                    } else {
                        showAlert(title: "Please Get Supported Access first", message: "")
                    }
                   
                    
                case .getSupportAccess:
                    SunionBluetoothTool.shared.getSupportType()
                  
                case .getAccessData:
                    
                    if let card = supportCard, let code = supportCode, let face = supportFace, let finger = supportFinger {
                        self.performSegue(withIdentifier: "accessdata", sender: nil)
                    } else {
                        showAlert(title: "Please Get Supported Access first", message: "")
                    }
                
                case .addAccess:
                    
                    if accessFirstEmptyIndex != nil, accessData2 == nil, let card = supportCard, let code = supportCode, let face = supportFace, let finger = supportFinger {
                        self.performSegue(withIdentifier: "access", sender: true)
                    } else {
                        showAlert(title: "Please Get Access Array/ Supported Access first", message: "")
                    }
                 

                case .editAccess:
                    if let data = accessData2 {
                        self.performSegue(withIdentifier: "access", sender: false)
                    } else {
                        showAlert(title: "Please Get Access Data first", message: "")
                    }

                case .delAccess:
              
                
                    if let card = supportCard, let code = supportCode, let face = supportFace, let finger = supportFinger {
                        self.performSegue(withIdentifier: "del", sender: nil)
                    } else {
                        showAlert(title: "Please Get Supported Access first", message: "")
                    }
                case .disconnected:
                    SunionBluetoothTool.shared.disconnectBluetooth()
                    appendLogToTextView(logMessage: "Disconnected")
                default:
                    break
                }
            }
        }
      
        if let data = data as? Picker3Option {
            if data == .adminCodeExist ||
                data == .setAdminCode ||
                data == .connecting {
                switch data {
                case .connecting:
                    appendLogToTextView(logMessage: "Connecting...")
                    SunionBluetoothTool.shared.connectingBluetooth()
                case .adminCodeExist:
                    SunionBluetoothTool.shared.isAdminCode()
                case .setAdminCode:
                    showsetAdminCodeAlert()
                default:
                    break
                }
            } else if !isAdminCode{
                showAlert(title: "Please Set Admin Code first", message: "")
            } else {
                switch data {
                case .adminCodeExist:
                    SunionBluetoothTool.shared.isAdminCode()
                case .setAdminCode:
                    showsetAdminCodeAlert()
                case .editAdminCode:
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
                    SunionBluetoothTool.shared.getDeviceConfigA0()
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
                    if status?.A2?.lockState == .lockedUnlinked {
                        lockMode = .unlock
                    } else {
                        lockMode = .lock
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
                    if let card = supportCard, let code = supportCode, let face = supportFace, let finger = supportFinger {
                        self.performSegue(withIdentifier: "accessarray", sender: nil)
                    } else {
                        showAlert(title: "Please Get Supported Access first", message: "")
                    }
                   
                    
                case .getSupportAccess:
                    SunionBluetoothTool.shared.getSupportType()
                  
                case .getAccessData:
                    
                    if let card = supportCard, let code = supportCode, let face = supportFace, let finger = supportFinger {
                        self.performSegue(withIdentifier: "accessdata", sender: nil)
                    } else {
                        showAlert(title: "Please Get Supported Access first", message: "")
                    }
                
                case .addAccess:
                    
                    if accessFirstEmptyIndex != nil, accessData2 == nil, let card = supportCard, let code = supportCode, let face = supportFace, let finger = supportFinger {
                        self.performSegue(withIdentifier: "access", sender: true)
                    } else {
                        showAlert(title: "Please Get Access Array/ Supported Access first", message: "")
                    }
                 

                case .editAccess:
                    if let data = accessData2 {
                        self.performSegue(withIdentifier: "access", sender: false)
                    } else {
                        showAlert(title: "Please Get Access Data first", message: "")
                    }

                case .delAccess:
              
                
                    if let card = supportCard, let code = supportCode, let face = supportFace, let finger = supportFinger {
                        self.performSegue(withIdentifier: "del", sender: nil)
                    } else {
                        showAlert(title: "Please Get Supported Access first", message: "")
                    }
                case .disconnected:
                    SunionBluetoothTool.shared.disconnectBluetooth()
                    appendLogToTextView(logMessage: "Disconnected")
                default:
                    break
                }
            }
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
        
        if let id = segue.identifier, id == "access",
           let vc = segue.destination as? AccessCodeViewController,
            let isCreate = sender as? Bool {
            vc.isCreate = isCreate
            vc.positionIndex = accessFirstEmptyIndex
            vc.data = accessData
            vc.data2 = accessData2
            vc.delegate = self
            vc.bleStatus = status
            vc.isV2 = isV2
            
            if let supportCode = supportCode, supportCode > 0 {
                vc.code = true
            }
            if let supportcard = supportCard, supportcard > 0 {
                vc.card = true
            }
            if let supportface = supportFace, supportface > 0 {
                vc.face = true
            }
            if let supportFinger = supportFinger, supportFinger > 0 {
                vc.finger = true
            }
        }
        
        if let id = segue.identifier, id == "accessarray",
           let vc = segue.destination as? GetAccessArrayViewController {
            if let supportCode = supportCode, supportCode > 0 {
                vc.code = true
            }
            if let supportcard = supportCard, supportcard > 0 {
                vc.card = true
            }
            if let supportface = supportFace, supportface > 0 {
                vc.face = true
            }
            if let supportFinger = supportFinger, supportFinger > 0 {
                vc.finger = true
            }
            vc.delegate = self
        }
        
        if let id = segue.identifier, id == "accessdata",
           let vc = segue.destination as? GetAccessDataViewController {
            if let supportCode = supportCode, supportCode > 0 {
                vc.code = true
            }
            if let supportcard = supportCard, supportcard > 0 {
                vc.card = true
            }
            if let supportface = supportFace, supportface > 0 {
                vc.face = true
            }
            if let supportFinger = supportFinger, supportFinger > 0 {
                vc.finger = true
            }
            vc.delegate = self
        }
        
        if let id = segue.identifier, id == "del",
           let vc = segue.destination as? DelAccessDataViewController {
            if let supportCode = supportCode, supportCode > 0 {
                vc.code = true
            }
            if let supportcard = supportCard, supportcard > 0 {
                vc.card = true
            }
            if let supportface = supportFace, supportface > 0 {
                vc.face = true
            }
            if let supportFinger = supportFinger, supportFinger > 0 {
                vc.finger = true
            }
            vc.delegate = self
        }
        
        
    }
    
    
    // MARK: - API
    

    func fetchProductionData(code: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://apii.ikey-lock.com/v1/production/get") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // 设置请求头部
        request.setValue("ifUgJuF98l2eIUMy50sM118j3itVOewO8YF9xztJ", forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // 准备你的JSON数据
        let requestBody: [String: Any] = [
            "code": code,
            "clientToken": UUID().uuidString
        ]
        
        // 将字典转换为JSON Data
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        // 发起请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }


    
}

extension ViewController: DelAccessDataViewControllerDelegate {
    func delAccessData(model:DelAccessRequestModel) {
        SunionBluetoothTool.shared.delAccess(model: model)
    }
    
    
}

extension ViewController: GetAccessDataViewControllerDelegate {
    func getAccessData(name: String, index: Int) {
        var model = SearchAccessRequestModel(type: .AccessCode, index: index)
        switch name {
        case "code":
            model.accessType = .AccessCode
        case "card":
            model.accessType = .AccessCard
        case "face":
            model.accessType = .Face
        case "finger":
            model.accessType = .Fingerprint
        default:
            break
        }
        
        SunionBluetoothTool.shared.searchAccess(model:  model)
    }
    
    
}

extension ViewController: GetAccessArrayViewControllerDelegate {
    func getAccessArray(name: String) {
        switch name {
        case "code":
            SunionBluetoothTool.shared.getAccessArray(type: .AccessCode)
        case "card":
            SunionBluetoothTool.shared.getAccessArray(type: .AccessCard)
        case "face":
            SunionBluetoothTool.shared.getAccessArray(type: .Face)
        case "finger":
            SunionBluetoothTool.shared.getAccessArray(type: .Fingerprint)
        default:
            break
        }
    }
    
    
}

extension ViewController: AccessCodeViewControllerDelegate {
    func optionData2(model: AccessRequestModel) {
        accessData2 = nil
        accessFirstEmptyIndex = nil
 
        SunionBluetoothTool.shared.delegate = self
        SunionBluetoothTool.shared.accessAction(model: model)
    }
    
    func optionData(model: PinCodeManageModel) {
        accessFirstEmptyIndex = nil
        accessData = nil
        SunionBluetoothTool.shared.pinCodeOption(model: model)
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
        switch pickerData {
        case .cmd1O:
            return cmd10Datas.count
        case .cmd2O:
            return cmd20Datas.count
        case .cmd30:
            return cmd30Datas.count
        default:
            return 0
        }
     
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerData {
        case .cmd1O:
            return cmd10Datas[row].description
        case .cmd2O:
            return cmd20Datas[row].description
        case .cmd30:
            return cmd30Datas[row].description
        default:
            return ""
        }
      
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
            msg = "lockDirection: \(a.lockDirection.rawValue)\n vacationMode: \(a.vacationModeOn)\n deadbolt: \(a.deadBolt.rawValue)\n doorState: \(a.doorState.rawValue)\n isLocked: \(a.lockState.rawValue)\n securitybolt: \(a.securityBolt.rawValue)\n battery: \(a.battery ?? 0000)\n batteryWarning: \(a.batteryWarning.rawValue)"
        }
        
        if let d = value?.D6 {
            msg = "lockDirection: \(d.lockDirection.rawValue)\n soundOn: \(d.soundOn)\n vacationMode: \(d.vacationModeOn)\n autoLockOn: \(d.autoLockOn)\n autoLockTime: \(d.autoLockTime ?? 0000)\n guidingCode: \(d.guidingCode)\n isLocked: \(d.isLocked)\n battery: \(d.battery ?? 0000)\n batteryWarning: \(d.batteryWarning.rawValue)\n timestamp: \(d.timestamp ?? 0000)"
        }
        
        if let n = value?.N82 {
            msg = "mainVersion: \(n.mainVersion)\n subVersion: \(n.subVersion)\n lockDirection: \(n.lockDirection.rawValue)\n vacationMode: \(n.vacationModeOn.rawValue)\n deadbolt: \(n.deadBolt.rawValue)\n doorState: \(n.doorState.rawValue)\n lockState: \(n.lockState.rawValue)\n securitybole: \(n.securityBolt.rawValue) \n battery: \(n.battery ?? 0000)\n batteryWarning: \(n.batteryWarning.rawValue)"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func AdminCode(bool: Bool?) {
        if let bool = bool, bool {
            isAdminCode = true
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
            accessData = nil
            let msg = "count: \(value.count)\n data: \(value.data)\n firstemptyindex: \(value.firstEmptyIndex)"
            self.accessFirstEmptyIndex = value.firstEmptyIndex
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "get access array failed")
        }
    }
    
    func PinCodeData(value: PinCodeModelResult?) {
        if let value = value {
            accessData = value
            var schemsg = ""
            if let sche = value.schedule {
                switch sche.scheduleOption {
                    
                case .all:
                    break
                case .none:
                    break
                case .once:
                    break
                case .weekly(let week,let start, let end):
                    
                    
                    let weekmsg = "week: \(convertWeekArrayToString(week: week))"
                    
                    let startValue = start.components(separatedBy: ":")
                    let endValue = end.components(separatedBy: ":")
                    let startmsg = "START: \(startValue.first!.appendLeadingZero + ":" + startValue.last!.appendLeadingZero)"
                    let endmsg = "END: \(endValue.first!.appendLeadingZero + ":" + endValue.last!.appendLeadingZero)"
                    schemsg = weekmsg + "\n \(startmsg)" + "\n \(endmsg)"
                case .validTime(let start, let end):
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
                   
                    let startmsg = dateformatter.string(from: start)
                    let endmsg = dateformatter.string(from: end)
                    schemsg = "START: \(startmsg)" + "\n END: \(endmsg)"
                case .error:
                    break
                }
            }
            
            let msg = "index: \(value.index) \nisenable: \(value.isEnable)\n code: \(value.PinCode ?? [0000])\n length: \(value.PinCodeLength ?? 0x00)\n name: \(value.name ?? "")\n schedule: \(value.schedule?.scheduleOption.scheduleName ?? "")\n" + schemsg
          
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "get access data failed")
        }
    }
    
    func convertWeekArrayToString(week: [Int]) -> String {

        
        // 星期的缩写，与你的要求相匹配
        let days = ["Sa", "Fr", "Th", "We", "Tu", "Mo", "Su"]
        
        var resultString = ""
        
        for (index, value) in week.enumerated() {
            if value == 1 {
                // 添加对应的天到结果字符串
                resultString += days[index] + " "
            }
        }
        
        // 移除最后一个空格并返回结果
        return resultString.trimmingCharacters(in: .whitespaces)
    }
    
    func PinCode(bool: Bool?) {
        if let bool = bool {
            appendLogToTextView(logMessage: "add/edit/del access data successfully")
        } else {
            appendLogToTextView(logMessage: "add/edit/edl access data failed")
        }
    }
    
    func SupportType(value: SupportDeviceTypesResponseModel?) {
        if let value = value {
            if let card = value.AccessCard {
                supportCard = card
            } else {
                supportCard = 0
            }
            
            if let code = value.AccessCode {
                supportCode = code
            } else {
                supportCode = 0
            }
             
            if let face = value.Face {
                supportFace = face
                
            } else {
                supportFace = 0
            }
            
            if let finger = value.Fingerprint {
                supportFinger = finger
            } else {
                supportFinger = 0
            }
            
            
            appendLogToTextView(logMessage: "code: \(supportCode!) \ncard: \(supportCard!)\n finger: \(supportFinger!)\n face: \(supportFace!)")
        } else {
            appendLogToTextView(logMessage: "get supported access failed")
        }
    }
    
    func AccessArray(value: AccessArrayResponseModel?) {
        if let value = value {
            var index = 1
            
            switch value.type {
            case .AccessCard:
                while value.hasDataAIndex.contains(index) {
                    // 如果包含，则index加1
                    index += 1
                }
                accessFirstEmptyIndex = index
            case .AccessCode:
                while value.hasDataAIndex.contains(index) {
                    // 如果包含，则index加1
                    index += 1
                }
                accessFirstEmptyIndex = index
            default:
                break
            }
            
            appendLogToTextView(logMessage: "type: \(value.type.rawValue)\n hasDataIndex:\(value.hasDataAIndex)")
        } else {
            appendLogToTextView(logMessage: "get access array failed")
        }
    }
    
    func SearchAccess(value: AccessDataResponseModel?) {
        if let value = value, value.type.rawValue != "error" {
            accessData2 = value
            var schemsg = ""
            if let sche = value.schedule {
                switch sche.scheduleOption {
                    
                case .all:
                    break
                case .none:
                    break
                case .once:
                    break
                case .weekly(let week,let start, let end):
                    
                    
                    let weekmsg = "week: \(convertWeekArrayToString(week: week))"
                    
                    let startValue = start.components(separatedBy: ":")
                    let endValue = end.components(separatedBy: ":")
                    let startmsg = "START: \(startValue.first!.appendLeadingZero + ":" + startValue.last!.appendLeadingZero)"
                    let endmsg = "END: \(endValue.first!.appendLeadingZero + ":" + endValue.last!.appendLeadingZero)"
                    schemsg = weekmsg + "\n \(startmsg)" + "\n \(endmsg)"
                case .validTime(let start, let end):
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
                   
                    let startmsg = dateformatter.string(from: start)
                    let endmsg = dateformatter.string(from: end)
                    schemsg = "START: \(startmsg)" + "\n END: \(endmsg)"
                case .error:
                    break
                }
            }
            
            appendLogToTextView(logMessage: "type: \(value.type.rawValue)\n index: \(value.index)\n enable: \(value.isEnable)\n name: \(value.name) \n data:\(value.codeCard)\n schedule: \(value.schedule?.scheduleOption.scheduleName ?? "")\n" + schemsg)
        } else {
            appendLogToTextView(logMessage: "get access data failed")
        }
    }
    
    func AccessAction(value: AccessResponseModel?) {
        if let value = value, value.isSuccess {
            appendLogToTextView(logMessage: "type:\(value.type.rawValue)\n index:\(value.index)")
        } else {
            appendLogToTextView(logMessage: "add/edit access failed")
        }
    }
    
    
}


extension String {
    var hexStringTobyteArray: [UInt8] {
        let chunkedString = self.chunked(into: 2, separatedBy: ":")
        let arrayString = chunkedString.components(separatedBy: ":")
        let byteArray = arrayString.map { UInt8($0, radix: 16) ?? 0x00 }
        return byteArray
    }
    
    func chunked(into size: Int, separatedBy separator: String) -> String {
        let array = Array(self)
        let newArray = array.chunked(into: size)
        var newString = ""
        for (index, item) in newArray.enumerated() {
            if index == 0 {
                newString = String(item)
            } else {
                newString += separator + String(item)
            }
        }
        return newString
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
