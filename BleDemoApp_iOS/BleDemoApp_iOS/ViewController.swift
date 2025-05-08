//
//  ViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/6.
//

import UIKit
import SunionBluetoothTool
import UniformTypeIdentifiers

class ViewController: UIViewController, ScanViewControllerDelegate, UIDocumentPickerDelegate {
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
    var n80: DeviceSetupResultModelN80?
    var status: DeviceStatusModel?
    var statusV3: DeviceStatusModelN82?
    var token: TokenModel?
    var v3Token: BleUserModel?
    var tokenIndex: Int?
    var accessFirstEmptyIndex: Int?
    var userCredentailEmptyIndex: Int?
    var credentailEmptyIndex: Int?
    var accessData: PinCodeModelResult?
    var accessData2: AccessDataResponseModel?
    
    var timezonetextField: UITextField?
    let timezonepickerView = UIPickerView()
    

    var supportCode: Int?
    var supportCard: Int?
    var supportFace: Int?
    var supportFinger: Int?
    
    var isV2 = false
    var isV3 = false
    var isWifi = false
    
    var able: UserableResponseModel?
    
    var userCredentialData: UserCredentialModel?
    var userSupportCount: resUserSupportedCountModel?
    var credentialData: CredentialModel?
    
    var cardFpFaceCredentialRequestModel: CredentialRequestModel?
    
    var plugmode: CommandService.plugMode = .off
    
    private let timerManager = TimerManager()
    
    var otaDatas: [Data] = []
    var otaReqModel: OTAStatusRequestModel?
    var otaUpdateCount = 0
    var allDataCount = 1
    
    var pToken: [UInt8]?
    var pKey: [UInt8]?
    var pMac: String?
    var pUUID: String?
    
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
            let msg = "qrCode資料\ntoken: \(token.toHexString())\n aes1Key: \(aes1.toHexString())\n macAddress: \(mac)\n modelName: \(name)"
            
            pMac = mac
            pKey = aes1
            
            SunionBluetoothTool.shared.initBluetooth(macAddress: mac, aes1Key: Array(aes1), token: Array(token), v3uuid: nil)
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
            pUUID = uuid

            fetchProductionData(code: uuid) { result in
                switch result {
                case .success(let success):
                    // 成功获取到数据，尝试解析JSON
                    do {
                        // 尝试将Data对象解码为JSON对象
                        if let jsonObject = try JSONSerialization.jsonObject(with: success, options: []) as? [String: Any] {
                            // 成功解码，jsonObject现在是一个[String: Any]字典
                            print(jsonObject)
                            self.isV3 = true
                            self.pickerData = .cmd30
                        
                            let aes1 =   Data.init((jsonObject["key"] as! String).hexStringTobyteArray).bytes
                            let token = Data.init((jsonObject["token"] as! String).hexStringTobyteArray).bytes
                            
                            self.pKey = aes1
                            
                            SunionBluetoothTool.shared.initBluetooth(macAddress: nil, aes1Key: Array(aes1), token: Array(token), v3uuid: uuid)
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
                  
                    if let pToken = pToken,
                       let pKey = pKey {
                        appendLogToTextView(logMessage: "⚠️ ReConnecting...")
                        SunionBluetoothTool.shared.initBluetooth(macAddress: pMac, aes1Key: pKey, token: pToken, v3uuid:    pUUID)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            SunionBluetoothTool.shared.connectingBluetooth()
                        }
                    } else {
                        appendLogToTextView(logMessage: "⚠️ Connecting...")
                        SunionBluetoothTool.shared.connectingBluetooth()
                    }
                  
                case .adminCodeExist:
                    SunionBluetoothTool.shared.isAdminCode()
                case .setAdminCode:
                    showsetAdminCodeAlert()
                default:
                    break
                }
            } else if !isAdminCode{
                showAlert(title: "❌ Please Set Admin Code first", message: "")
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
                        SunionBluetoothTool.shared.getDeviceConfigD4()
                        timerManager.start(interval: 0.7) {
                            if let config = self.config {
                                self.timerManager.stop()
                                self.performSegue(withIdentifier: "config", sender: nil)
                            }
                        }
                 
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
                case .gettokenArray:
                    SunionBluetoothTool.shared.getTokenArray()
                case .gettokenData:
                    showgetUserDataAlert()
                case .addtoken:
                    self.performSegue(withIdentifier: "user", sender: "add")
                    
                case .edittoken:
                    if let token = token {
                        if token.isOwnerToken == .owner {
                            showAlert(title: "❌ Editing of the Owner is not allowed", message: "")
                        } else {
                            self.performSegue(withIdentifier: "user", sender: "edit")
                        }
                        
                    } else {
                        showAlert(title: "❌ Please Get User Data first", message: "")
                    }
                    
                case .deltoken:
                    if let token = token {
                        if token.isOwnerToken == .owner {
                            showAlert(title: "❌ Deleting the Owner is not allowed", message: "")
                        } else {
                            SunionBluetoothTool.shared.delToken(model: token)
                        }
                        
                    } else {
                        showAlert(title: "❌ Please Get User Data first", message: "")
                    }
                
                case .getAccessArray:
                    SunionBluetoothTool.shared.getPinCodeArray()
                  
                case .getAccessData:
                    showgetAccessDataAlert()
                case .addAccess:
                    
                    SunionBluetoothTool.shared.getPinCodeArray()
                    timerManager.start(interval: 0.7) {
                        if let firstEmptyIndex = self.accessFirstEmptyIndex, self.accessData == nil {
                            self.timerManager.stop()
                            self.performSegue(withIdentifier: "access", sender: true)
                        }
                    }
                  
                 

                case .editAccess:
                    if let data = accessData {
                        self.performSegue(withIdentifier: "access", sender: false)
                    } else {
                        showAlert(title: "❌ Please Get Access Data first", message: "")
                    }

                case .delAccess:
                    showdelAccesAlert()
                
                case .disconnected:
                    SunionBluetoothTool.shared.disconnectBluetooth()
                    appendLogToTextView(logMessage: "⚠️ Disconnected")
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
                    if let pToken = pToken,
                       let pKey = pKey {
                        appendLogToTextView(logMessage: "⚠️ ReConnecting...")
                        SunionBluetoothTool.shared.initBluetooth(macAddress: pMac, aes1Key: pKey, token: pToken, v3uuid:    pUUID)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            SunionBluetoothTool.shared.connectingBluetooth()
                        }
                    } else {
                        appendLogToTextView(logMessage: "⚠️ Connecting...")
                        SunionBluetoothTool.shared.connectingBluetooth()
                    }
                case .adminCodeExist:
                    SunionBluetoothTool.shared.isAdminCode()
                case .setAdminCode:
                    showsetAdminCodeAlert()
                default:
                    break
                }
            } else if !isAdminCode{
                showAlert(title: "❌ Please Set Admin Code first", message: "")
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
                        self.appendLogToTextView(logMessage: "✅ Set Device Time successfully")
                    }
                case .getDeviceConfig:
                    SunionBluetoothTool.shared.getDeviceConfigA0()
                case .setDeviceConfig:
                    
                    
                    
                    if let config = config {
                        self.performSegue(withIdentifier: "config", sender: nil)
                    } else {
                        SunionBluetoothTool.shared.getDeviceConfigA0()
                        timerManager.start(interval: 0.7) {
                            if let config = self.config {
                                self.timerManager.stop()
                                self.performSegue(withIdentifier: "config", sender: nil)
                            }
                        }
                    
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
                case .gettokenArray:
                    SunionBluetoothTool.shared.getTokenArray()
                case .gettokenData:
                    showgetUserDataAlert()
                case .addtoken:
                    self.performSegue(withIdentifier: "user", sender: "add")
                    
                case .edittoken:
                    if let token = token {
                        if token.isOwnerToken == .owner {
                            showAlert(title: "❌ Editing of the Owner is not allowed", message: "")
                        } else {
                            self.performSegue(withIdentifier: "user", sender: "edit")
                        }
                        
                    } else {
                        showAlert(title: "❌ Please Get User Data first", message: "")
                    }
                    
                case .deltoken:
                    if let token = token {
                        if token.isOwnerToken == .owner {
                            showAlert(title: "❌ Deleting the Owner is not allowed", message: "")
                        } else {
                            SunionBluetoothTool.shared.delToken(model: token)
                        }
                        
                    } else {
                        showAlert(title: "❌ Please Get User Data first", message: "")
                    }
                
                case .getAccessArray:
                    if let card = supportCard,
                       let code = supportCode,
                        let face = supportFace,
                        let finger = supportFinger {
                        self.performSegue(withIdentifier: "accessarray", sender: nil)
                    } else {
                        SunionBluetoothTool.shared.getSupportType()
                        timerManager.start(interval: 0.7) {
                            if let card = self.supportCard,
                               let code = self.supportCode,
                               let face = self.supportFace,
                               let finger = self.supportFinger {
                                self.timerManager.stop()
                                self.performSegue(withIdentifier: "accessarray", sender: nil)
                            }
                        }
                    
                    }
                   
                    
                case .getSupportAccess:
                    SunionBluetoothTool.shared.getSupportType()
                  
                case .getAccessData:
                    
                    if let card = supportCard,
                       let code = supportCode,
                       let face = supportFace,
                        let finger = supportFinger {
                        self.performSegue(withIdentifier: "accessdata", sender: nil)
                    } else {
                        SunionBluetoothTool.shared.getSupportType()
                        timerManager.start(interval: 0.7) {
                            if let card = self.supportCard,
                               let code = self.supportCode,
                               let face = self.supportFace,
                               let finger = self.supportFinger {
                                self.timerManager.stop()
                                self.performSegue(withIdentifier: "accessdata", sender: nil)
                            }
                        }
                       
                    }
                
                case .addAccess:
                    
                    if accessFirstEmptyIndex != nil,
                       accessData2 == nil,
                        let card = supportCard,
                       let code = supportCode,
                        let face = supportFace,
                        let finger = supportFinger {
                        self.performSegue(withIdentifier: "access", sender: true)
                    } else {
                        SunionBluetoothTool.shared.getSupportType()
                        
                        showAlert(title: "❌ Please Get Access Array first", message: "")
                    }
                 

                case .editAccess:
                    if let data = accessData2 {
                        self.performSegue(withIdentifier: "access", sender: false)
                    } else {
                        showAlert(title: "❌ Please Get Access Data first", message: "")
                    }

                case .delAccess:
              
                
                    if let card = supportCard,
                        let code = supportCode,
                        let face = supportFace,
                        let finger = supportFinger {
                        self.performSegue(withIdentifier: "del", sender: nil)
                    } else {
                        showAlert(title: "❌ Please Get Supported Access first", message: "")
                    }
                case .disconnected:
                    SunionBluetoothTool.shared.disconnectBluetooth()
                    appendLogToTextView(logMessage: "⚠️ Disconnected")
                default:
                    break
                }
            }
        }
      
        // MARK: -V3 Action
        if let data = data as? Picker3Option {
            if data == .adminCodeExist ||
                data == .setAdminCode ||
                data == .connecting {
                switch data {
                case .connecting:
                    if let pToken = pToken,
                       let pKey = pKey {
                        appendLogToTextView(logMessage: "⚠️ ReConnecting...")
                        SunionBluetoothTool.shared.initBluetooth(macAddress: pMac, aes1Key: pKey, token: pToken, v3uuid:    pUUID)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            SunionBluetoothTool.shared.connectingBluetooth()
                        }
                    } else {
                        appendLogToTextView(logMessage: "⚠️ Connecting...")
                        SunionBluetoothTool.shared.connectingBluetooth()
                    }
                case .adminCodeExist:
                    SunionBluetoothTool.shared.UseCase.adminCode.exists()
                case .setAdminCode:
                    showsetAdminCodeAlert(v3: true)
             
                default:
                    break
                }
            } else if !isAdminCode{
                if isWifi {
                    switch data {
                    case.conectedWifi:
                        self.performSegue(withIdentifier: "wifi", sender: nil)
                    case .plugstatus:
                        SunionBluetoothTool.shared.UseCase.plug.status()
                    case .setPlugStatus:
                        SunionBluetoothTool.shared.UseCase.plug.set(mode: plugmode)
                    default:
                        break
                    }
                } else {
                    showAlert(title: "❌ Please Set Admin Code first", message: "")
                }
        
            } else {
                switch data {
                case .adminCodeExist:
                    SunionBluetoothTool.shared.UseCase.adminCode.exists()
                case .setAdminCode:
                    showsetAdminCodeAlert(v3: true)
                case .editAdminCode:
                    showEditAdminCodeAlert(v3: true)
                case .boltCheck:
                    SunionBluetoothTool.shared.UseCase.direction.checkDoorDirection()
                case .factoryReset:
                    showfactoryResetAlert(v3: true)
                case .setDeviceName:
                    showsetDeviceNameAlert(v3: true)
                case .getDeviceName:
                    SunionBluetoothTool.shared.UseCase.name.data()
                case .setTimeZone:
                    SunionBluetoothTool.shared.UseCase.time.setTimeZone(value: "Asia/Taipei")
                case .setWIFIDeviceTimeZone:
                    SunionBluetoothTool.shared.UseCase.time.setTimeZoneForWIFIDevice(value: "America/Toronto")
                case .getTimeZone:
                    SunionBluetoothTool.shared.UseCase.time.getTimeZoneValue()
                case .setDeviceTime:
                    SunionBluetoothTool.shared.UseCase.time.syncCurrentTime()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.appendLogToTextView(logMessage: "✅ Set Device Time successfully")
                    }
                case .getDeviceConfig:
                    SunionBluetoothTool.shared.UseCase.config.data()
                case .setDeviceConfig:
                    
                    if let config = n80 {
                        self.performSegue(withIdentifier: "config", sender: true)
                    } else {
                        SunionBluetoothTool.shared.UseCase.config.data()
                        timerManager.start(interval: 0.7) {
                            if let config = self.n80 {
                                self.timerManager.stop()
                                self.performSegue(withIdentifier: "config", sender: true)
                            }
                        }
                       
                    }
                    
                    
                case .getDeviceStatus:
                    SunionBluetoothTool.shared.UseCase.deviceStatus.data()
                case .switchDevice:
                    var lockMode: CommandService.DeviceMode = .unlock
                    if statusV3?.lockState == .lockedUnlinked {
                        lockMode = .unlock
                    } else {
                        lockMode = .lock
                    }
                    SunionBluetoothTool.shared.UseCase.deviceStatus.lockorUnlock(value: lockMode)
                case .getLogCount:
                    SunionBluetoothTool.shared.UseCase.log.count()
                case .getLogData:
                    showgetLogDataAlert(v3: true)
                case .gettokenArray:
                    SunionBluetoothTool.shared.UseCase.bleUser.array()
                case .gettokenData:
                    showgetUserDataAlert(v3: true)
                case .addtoken:
                    self.performSegue(withIdentifier: "user", sender: "add")
                    
                case .edittoken:
                    if let token = v3Token {
                        if token.isOwnerToken == .owner {
                            showAlert(title: "❌ Editing of the Owner is not allowed", message: "")
                        } else {
                            self.performSegue(withIdentifier: "user", sender: "edit")
                        }
                        
                    } else {
                        showAlert(title: "❌ Please Get User Data first", message: "")
                    }
                    
                case .deltoken:
                    if let token = v3Token {
                        if token.isOwnerToken == .owner {
                            showAlert(title: "❌ Deleting the Owner is not allowed", message: "")
                        } else {
                            SunionBluetoothTool.shared.UseCase.bleUser.delete(model: token)
                        }
                        
                    } else {
                        showAlert(title: "❌ Please Get User Data first", message: "")
                    }
                case .getUserCapabilities:
                    SunionBluetoothTool.shared.UseCase.user.able()
                case .isMatterDevice:
                    SunionBluetoothTool.shared.UseCase.utility.isMatter()
                case .getUserCredentialArray:
                    SunionBluetoothTool.shared.UseCase.user.array()
                case .getUserCredentialData:
                    showgetusercredentialDataAlert()
                
                case .addUserCredential:
                    
                    if let data = userCredentialData {
                        self.userCredentialData = nil
                    }
                    
                    if let userCredentailEmptyIndex = userCredentailEmptyIndex,
                       let able = able {
                      
                        self.performSegue(withIdentifier: "usercredential", sender: nil)
                      
                    } else {
                        SunionBluetoothTool.shared.UseCase.user.able()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            SunionBluetoothTool.shared.UseCase.user.array()
                        }
                        
                        timerManager.start(interval: 0.7) {
                            if let userCredentailEmptyIndex = self.userCredentailEmptyIndex,
                               let able = self.able {
                                self.timerManager.stop()
                                self.performSegue(withIdentifier: "usercredential", sender: nil)
                              
                            }
                        }
                       
                    }
                case .editUserCredential:
                    if let data = userCredentialData {
                        self.performSegue(withIdentifier: "usercredential", sender: nil)
                    } else {
                        showAlert(title: "❌ Please Get UserCredentialData first", message: "")
                    }
                case .delUserCredential:
                    showuserCredentialDeleteAlert()
                case .getUserSupportedCount:
                    SunionBluetoothTool.shared.UseCase.user.supportCount()
                case .getCredentialArray:
                    SunionBluetoothTool.shared.UseCase.credential.array()
                case .getCredentialData:
                    self.performSegue(withIdentifier: "searchC", sender: nil)
                case .addCredential:
                    
                    if let data = credentialData  {
                        self.credentialData = nil
                    }
                    
                    if let credentailEmptyIndex = credentailEmptyIndex,
                        let able = able {
                      
                        self.performSegue(withIdentifier: "addeditC", sender: nil)
                      
                    } else {
                        
                        SunionBluetoothTool.shared.UseCase.user.able()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            SunionBluetoothTool.shared.UseCase.credential.array()
                        }
                        
                        timerManager.start(interval: 0.7) {
                            if let credentailEmptyIndex = self.credentailEmptyIndex,
                               let able = self.able {
                                self.timerManager.stop()
                                self.performSegue(withIdentifier: "addeditC", sender: nil)
                              
                            }
                        }
                        
                       
                    }
                case .editCredentail:
                    if let data = credentialData, let able = able {
                        self.performSegue(withIdentifier: "addeditC", sender: nil)
                    } else {
                        SunionBluetoothTool.shared.UseCase.user.able()
                        showAlert(title: "❌ Please Get CredentialData first", message: "")
                    }
                case .delCredential:
                    showDelCredentialAlert()
                case .OTA:
                    if #available(iOS 14.0, *) {
                        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.data], asCopy: true)
                        picker.delegate = self
                        picker.allowsMultipleSelection = false
                        present(picker, animated: true)
                    } else {
                        let picker = UIDocumentPickerViewController(documentTypes: ["public.data"], in: .import)
                        picker.allowsMultipleSelection = false
                        picker.delegate = self
               
                        present(picker, animated: true)
                    }

                  
         
//                case .endpoint:
//                 SunionBluetoothTool.shared.UseCase.utility.setEndpoint(type: .api, data: [0x00,0x01,0x02])
//                    break
                case .disconnected:
                    SunionBluetoothTool.shared.disconnectBluetooth()
                    appendLogToTextView(logMessage: "⚠️ Disconnected")
                default:
                    break
                }
            }
        }
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
         guard let fileURL = urls.first else { return }
         
         // 檢查副檔名是否為 .ota
         if fileURL.pathExtension.lowercased() == "gbl" ||
                fileURL.pathExtension.lowercased() == "bin" {
             presentInputAlert(for: fileURL)
         } else {
             print("選擇的不是 OTA 檔案")
         }
     }
    
    private func presentInputAlert(for fileURL: URL) {
            let alert = UIAlertController(title: "上傳 OTA 檔案", message: "請輸入  IV /Signature /Target ", preferredStyle: .alert)
        

        
        alert.addTextField { textField in
            textField.placeholder = "請輸入 IV"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "請輸入 Signature"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "請輸入 Target 1:wireless, 0:mcu"
        }
            
            let confirmAction = UIAlertAction(title: "確認", style: .default) { [weak self] _ in
                guard let iv = alert.textFields?[0].text,
                      let signature = alert.textFields?[1].text,
                      let target = alert.textFields?[2].text else { return }
                
                print("👉 IV: \(iv)")
                print("👉 Signature: \(signature)")
                print("👉 Target: \(target)")
                
                self?.readFileContent(fileURL: fileURL, iv: iv, signature: signature, target: Int(target) ?? 0)
            }
            
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            
            alert.addAction(confirmAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true)
        }
        
    private func readFileContent(fileURL: URL, iv: String, signature: String, target: Int) {
            do {
                let data = try Data(contentsOf: fileURL)
                print("✅ 成功讀取檔案內容，大小：\(data.count) bytes")
                
                otaDatas = data.split(by: 128)
                allDataCount = otaDatas.count
                
                let reqTarget: otaTarget = target == 0 ? .mcu : .wireless
                let req = OTAStatusRequestModel(target: reqTarget, state: .start, fileSize: data.count, IV: nil, Signature: nil)
                SunionBluetoothTool.shared.UseCase.ota.responseStatus(model: req)
                
                otaReqModel = req
                otaReqModel?.IV = iv
                otaReqModel?.Signature = signature
                otaReqModel?.state = .finish
                otaUpdateCount = 0
                
            } catch {
                print("❌ 讀取檔案失敗：\(error.localizedDescription)")
            }
        }
        
        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("❌ 使用者取消選擇檔案")
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
            vc.v3 = self.isV3
            vc.n80 = self.n80
        }
        
        if let id = segue.identifier, id == "user",
           let vc = segue.destination as? UserOptionViewController {
            if sender as! String == "edit" {
                vc.data = self.token
                vc.v3data = self.v3Token
            }
            vc.delegate = self
            vc.v3 = self.isV3
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
        
        if let id = segue.identifier, id == "usercredential",
           let vc = segue.destination as? AddEditUserCredentialViewController {
            vc.index = userCredentialData?.index ?? userCredentailEmptyIndex ??  1
            vc.able = able
            vc.data = userCredentialData
            vc.isCreate = userCredentialData == nil
            
            
 
       
        }
        
        if let id = segue.identifier, id == "searchC",
           let vc = segue.destination as? SearchCredentialViewController {
            vc.delegate = self
        }
        
        if let id = segue.identifier, id == "addeditC",
           let vc = segue.destination as? AddEditCredentialViewController {
            vc.delegate = self
            vc.credientialIndex = credentailEmptyIndex
            vc.userIndex = userCredentialData?.index!
            vc.able = self.able
            vc.data = self.credentialData
            
           
        }
        
        if let id = segue.identifier, id == "wifi",
           let vc = segue.destination as? WifiViewController {
            vc.delegate = self

        }
        
    }
    
    
    // MARK: - API
    

    func fetchProductionData(code: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: "https://apii-beta.ikey-lock.com/v1-beta/production/get") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // 设置请求头部
        request.setValue("NluZnX8N6s65B62uHqWv63Hy6yyKvdonaEp7YaKl", forHTTPHeaderField: "x-api-key")
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

extension ViewController: AddEditCredentialViewControllerDelegate {
    func setupCardFpFace(model: SetupCredentialRequestModel, credentialreq: CredentialRequestModel) {
        SunionBluetoothTool.shared.UseCase.credential.setCardFpFace(model: model)
        cardFpFaceCredentialRequestModel = credentialreq
    }
    

    
    func addEditCredential(model: CredentialRequestModel) {
        SunionBluetoothTool.shared.UseCase.credential.createorEdit(model: model)
        
    }
    

    
    
}

extension ViewController: SearchCredentialViewControllerDelegate {
    func searchC(model:SearchCredentialRequestModel) {
        SunionBluetoothTool.shared.UseCase.credential.data(model: model)
    }
    
    
}

extension ViewController: DelAccessDataViewControllerDelegate {
    func delAccessData(model:DelAccessRequestModel) {
        SunionBluetoothTool.shared.delAccess(model: model)
    }
    
    
}

extension ViewController: WifiViewControllerDelegate {
    func setupWifi(Bool: Bool) {
        SunionBluetoothTool.shared.delegate = self
        
        var msg = "==V3==\n"
        msg += "wifiSetting: \(Bool)"
        
        appendLogToTextView(logMessage: msg)
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
        SunionBluetoothTool.shared.delegate = self
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
    
    func v3optionData(add: addBleUserModel?, edit: EditBleUserModel?) {
        if let add = add {
            SunionBluetoothTool.shared.UseCase.bleUser.create(model: add)
          
        }
        
        if let edit = edit {
            SunionBluetoothTool.shared.UseCase.bleUser.edit(model: edit)
        }
    }
    

    

    
    
}

extension ViewController: DeviceConfigSettingViewControllerDelegate {
    func config(data: DeviceSetupModel?, v3: Bool, N81: DeviceSetupModelN81?) {
        if v3 {
            SunionBluetoothTool.shared.UseCase.config.set(model: N81!)
        } else {
            SunionBluetoothTool.shared.setupDeviceConfig(data: data!)
        }
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
    
    func debug(level: LogLevel, value: String) {
        appendLogToTextView(logMessage: value)
    }
    
    func BluetoothState(State: bluetoothState) {
        switch State {
        case .enable:
            break
        case .connecting:
            break
        case .connected(_):
            appendLogToTextView(logMessage: "⚠️ Connected")
            BLEIMG.tintColor = .blue
            BLEIMG.isEnabled = true
        case .disable:
            break
        case .disconnect(let error):
            BLEIMG.tintColor = .black
            BLEIMG.isEnabled = false
            switch error {
            case .deviceRefused:
                
                appendLogToTextView(logMessage: "❌ Connection failed")
            case .illegalToken:
                appendLogToTextView(logMessage: "❌ You don't have access to this lock")
            case .normal:
                break
            default:
                appendLogToTextView(logMessage: "⚠️ Disconnected")
                
            }
        }
    }
    
    func DeviceStatus(value: DeviceStatusModel?) {
        status = value
        var msg = ""
        if let a = value?.A2 {
            msg = "Status A2:\nlockDirection: \(a.lockDirection.rawValue)\n vacationMode: \(a.vacationModeOn)\n deadbolt: \(a.deadBolt.rawValue)\n doorState: \(a.doorState.rawValue)\n isLocked: \(a.lockState.rawValue)\n securitybolt: \(a.securityBolt.rawValue)\n battery: \(a.battery ?? 0000)\n batteryWarning: \(a.batteryWarning.rawValue)"
        }
        
        if let d = value?.D6 {
            msg = "Status D6:\nlockDirection: \(d.lockDirection.rawValue)\n soundOn: \(d.soundOn)\n vacationMode: \(d.vacationModeOn)\n autoLockOn: \(d.autoLockOn)\n autoLockTime: \(d.autoLockTime ?? 0000)\n guidingCode: \(d.guidingCode)\n isLocked: \(d.isLocked)\n battery: \(d.battery ?? 0000)\n batteryWarning: \(d.batteryWarning.rawValue)\n timestamp: \(d.timestamp ?? 0000)"
        }
        
        pToken = SunionBluetoothTool.shared.data?.permanentToken
      
        
        appendLogToTextView(logMessage: msg)
    }
    

    
    func AdminCode(bool: Bool?) {
        if let bool = bool, bool {
            isAdminCode = true
            appendLogToTextView(logMessage: "✅ AdminCode set successfully")
        } else {
            appendLogToTextView(logMessage: "❌ AdminCode setting failed")
        }
    }
    
    func EditAdminCode(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ AdminCode edit successfully")
        } else {
            appendLogToTextView(logMessage: "❌ AdminCode edit failed")
        }
    }
    
    func AdminCodeExist(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ AdminCode exists")
        } else {
            appendLogToTextView(logMessage: "❌ AdminCode does not exist")
        }
    }
    

    
    func FactoryReset(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ FactoryRest successfully")
        } else {
            appendLogToTextView(logMessage: "❌ FactoryRest failed")
        }
    }
    
    func DeviceName(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ Set device name successfully")
        } else {
            appendLogToTextView(logMessage: "❌ Set device name failed")
        }
    }
    
    func DeviceNameData(value: String?) {
        if let value = value {
            appendLogToTextView(logMessage: "✅ Get device name successfully: \(value)")
        } else {
            appendLogToTextView(logMessage: "❌ Get device name failed")
        }
    }
    
    func TimeZone(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ Set timezone successfully")
        } else {
            appendLogToTextView(logMessage: "❌ Set timezone failed")
        }
    }
    
    func DeviceConfig(value: DeviceSetupResultModel?) {
        config = value
        var msg = ""
        if let value = value {
            if let d = value.D4 {
                msg = "Config D4:\nlockDirection: \(d.lockDirection.rawValue)\n soundOn: \(d.soundOn)\n vacationMode: \(d.vacationModeOn)\n autoLockOn: \(d.autoLockOn)\n autoLockTime: \(d.autoLockTime ?? 0000)\n guidingCode: \(d.guidingCode)\n latitude: \(d.latitude ?? 0000)\n longitude: \(d.longitude ?? 0000)"
            }
            
            if let a = value.A0 {
                msg = "Config A0:\nlatitude: \(a.latitude ?? 0000)\n longitude: \(a.longitude ?? 0000)\n lockDirection: \(a.direction.rawValue)\n guidingCode: \(a.guidingCode.rawValue)\n virtualCode: \(a.virtualCode.rawValue)\n twoFA: \(a.twoFA.rawValue)\n vacationMode: \(a.vacationMode.rawValue)\n autoLock: \(a.isAutoLock.rawValue)\n autoLockTime: \(a.autoLockTime ?? 0000)\n autoLockMinLimit: \(a.autoLockMinLimit ?? 0000)\n autoLockMaxLimit: \(a.autoLockMaxLimit ?? 0000)\n sound:\(a.sound.rawValue)\n voiceType: \(a.voiceType.rawValue)\n voiceValue: \(a.voiceValue.name)\n fastMode: \(a.fastMode.rawValue)"
            }
            
            
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "❌ Get device config failed")
        }
    }
    
    func Config(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ Set device config successfully")
        } else {
            appendLogToTextView(logMessage: "❌ Set device config failed")
        }
    }
    
    func LogCount(value: Int?) {
        if let value = value {
            appendLogToTextView(logMessage: "✅ Get log count successfully: \(value)")
        } else {
            appendLogToTextView(logMessage: "❌ Get log count failed")
        }
    }
    
    func LogData(value: LogModel?) {
        if let value = value {
            let msg = "Log: \ntimestamp: \(value.timestamp)\n event: \(value.event)\n name: \(value.name)\n message: \(value.message ?? "")"
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "❌ Get log data failed")
        }
    }
    
    func TokenArray(value: [Int]?) {
        if let value = value {
            appendLogToTextView(logMessage: "✅ Get user array successfully: \(value)")
        } else {
            appendLogToTextView(logMessage: "❌ Get user array failed")
        }
    }
    
    func TokenData(value: TokenModel?) {
        if let value = value {
            token = value
            if value.isOwnerToken == .notOwner {
                token?.indexOfToken = tokenIndex
            }
            let msg = "TokenData: \nisenable: \(value.isEnable)\n tokenmode: \(value.tokenMode.rawValue)\n isowner: \(value.isOwnerToken.rawValue)\n tokenpermission: \(value.tokenPermission.rawValue)\n token: \(value.token?.toHexString() ?? "")\n name: \(value.name ?? "")\n indexoftoken: \(value.indexOfToken ?? 0000)"
            
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "❌ Get user data failed")
        }
    }
    
    func TokenOption(value: AddTokenResult?) {
        if let value = value {
            let msg = "TokenOption: \nisSuccess: \(value.isSuccess)\n token: \(value.token?.toHexString() ?? "")\n index: \(value.index ?? 0000)"
            tokenIndex = value.index
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "❌ Add user failed")
        }
    }
    
    func Token(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ Del user successfully")
        } else {
            appendLogToTextView(logMessage: "❌ Del user failed")
        }
    }
    
    func EditToken(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ Edit user successfully")
        } else {
            appendLogToTextView(logMessage: "❌ Edit user failed")
        }
    }
    
    func PinCodeArray(value: PinCodeArrayModel?) {
        if let value = value {
            accessData = nil
            let msg = "PinCodeArray: \ncount: \(value.count)\n data: \(value.data)\n firstemptyindex: \(value.firstEmptyIndex)"
            self.accessFirstEmptyIndex = value.firstEmptyIndex
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "❌ Get access array failed")
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
            
            let msg = "PinCodeData: \nindex: \(value.index) \nisenable: \(value.isEnable)\n code: \(value.PinCode ?? [0000])\n length: \(value.PinCodeLength ?? 0x00)\n name: \(value.name ?? "")\n schedule: \(value.schedule?.scheduleOption.scheduleName ?? "")\n" + schemsg
          
            appendLogToTextView(logMessage: msg)
        } else {
            appendLogToTextView(logMessage: "❌  Get access data failed")
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
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "✅ Add/Edit/Del access data successfully")
        } else {
            appendLogToTextView(logMessage: "❌ Add/Edit/Del access data failed")
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
            
            
            appendLogToTextView(logMessage: "Support Type: \ncode: \(supportCode!) \ncard: \(supportCard!)\n finger: \(supportFinger!)\n face: \(supportFace!)")
        } else {
            appendLogToTextView(logMessage: "❌ Get supported access failed")
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
            
            appendLogToTextView(logMessage: "AccessArray: \ntype: \(value.type.rawValue)\n hasDataIndex:\(value.hasDataAIndex)")
        } else {
            appendLogToTextView(logMessage: "❌ Get access array failed")
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
            
            appendLogToTextView(logMessage: "AccessData: \ntype: \(value.type.rawValue)\n index: \(value.index)\n enable: \(value.isEnable)\n name: \(value.name) \n data:\(value.codeCard)\n schedule: \(value.schedule?.scheduleOption.scheduleName ?? "")\n" + schemsg)
        } else {
            appendLogToTextView(logMessage: "❌ Get access data failed")
        }
    }
    
    func AccessAction(value: AccessResponseModel?) {
        if let value = value, value.isSuccess {
            appendLogToTextView(logMessage: "AccessOption: \ntype:\(value.type.rawValue)\n index:\(value.index)")
        } else {
            appendLogToTextView(logMessage: "❌ Add/Edit access failed")
        }
    }
    
    func OTAData(value: OTADataResponseModel?) {
        if let value = value {
            
         
            let nextOffset = value.Offset + 128
            otaUpdateCount += 1
            let progress = CGFloat(Double(otaUpdateCount)/Double(allDataCount))
            appendLogToTextView(logMessage: "OTA 進度： \(progress)")
          
            
            if otaUpdateCount  >= otaDatas.count,
            let req = otaReqModel {
               
                
                SunionBluetoothTool.shared.UseCase.ota.responseStatus(model: req)
            } else if otaUpdateCount < otaDatas.count {
                let byteArray: [UInt8] = Array(otaDatas[otaUpdateCount])
                let req = OTADataRequestModel(offset: nextOffset, data: byteArray)
                SunionBluetoothTool.shared.UseCase.ota.update(model: req)
             
            }
            
           
            
        } else {
            
            appendLogToTextView(logMessage: "OTA ERROR")
            
        }
    }

    
    
    // MARK: - V3
    func v3deviceStatus(value: DeviceStatusModelN82?) {
        var msg = "==V3==\n"
        if let n = value {
            statusV3 = n
            msg += "Status: \nmainVersion: \(n.mainVersion ?? 9999)\n subVersion: \(n.subVersion ?? 9999)\n lockDirection: \(n.lockDirection.rawValue)\n vacationMode: \(n.vacationModeOn.rawValue)\n deadbolt: \(n.deadBolt.rawValue)\n doorState: \(n.doorState.rawValue)\n lockState: \(n.lockState.rawValue)\n securitybole: \(n.securityBolt.rawValue) \n battery: \(n.battery ?? 0000)\n batteryWarning: \(n.batteryWarning.rawValue)"
            
            pToken = SunionBluetoothTool.shared.data?.permanentToken
      
        } else {
            msg += "❌ Get status Failed"
        }
    
        appendLogToTextView(logMessage: msg)
    }
    
    func v3time(value: resTimeUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let time = value.isSavedTime {
                if time {
                    msg += "✅ Time saved success"
                } else {
                    msg += "❌ Time saved fail"
                }
               
            }
            
            if let timezone = value.isSavedTimeZone {
                if timezone {
                    msg += "✅ TimeZone saved success"
                } else {
                    msg += "❌ TimeZone saved fail"
                }
          
            }
            
            if let wifitimezone = value.isSavedTimeZoneWIFI {
                if wifitimezone {
                    msg += "✅ WiFi timezone saved success"
                } else {
                    msg += "❌ WiFi timezone saved fail"
                }
              
            }
            
            if let val = value.timezoneValue {
                msg += "✅ Get Value: offset - \(val.Offset), data - \(val.data)"
            }
        } else {
            msg += "❌ Time failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func v3adminCode(value: resAdminCodeUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let c = value.isCreated {
                if c {
                    isAdminCode = true
                    msg += "✅ AdminCode Created success"
                } else {
             
                    msg += "❌ AdminCode Created fail"
                }
              
            }
            
            if let e = value.isEdited {
                if e {
                    msg += "✅ AdminCode Edited success"
                } else {
                    msg += "❌ AdminCode Edited fail"
                }
              
            }
            
            if let exi = value.isExisted {
                if exi {
                    isAdminCode = true
                    msg += "✅ AdminCode Existied"
                } else {
                    msg += "❌ AdminCode not Existied"
                }
            
            }
        } else {
           msg += "❌ AdminCode failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func v3Name(value: resNameUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let v = value.data {
                msg += "✅ name Created successfully: \(v)"
            }
            
            if let v = value.isConfigured {
                if v {
                    msg += "✅ name set success"
                } else {
                    msg += "❌ name set fail"
                }
                
            }
        } else {
            msg += "❌ Name failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func v3Config(value: resConfigUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let n = value.data {
           
                self.n80 = n
            
                msg += "Config: \nmainVersion: \(n.mainVersion ?? 9999)\n subVersion: \(n.subVersion ?? 9999)\n formatVersioin: \(n.formatVersion ?? 9999)\n serverversion: \(n.serverversion ?? 9999)\n latitude: \(n.latitude ?? 0000)\n longitude: \(n.longitude ?? 0000)\n lockDirection: \(n.direction.rawValue)\n guidingCode: \(n.guidingCode.rawValue)\n virtualCode: \(n.virtualCode.rawValue)\n twoFA: \(n.twoFA.rawValue)\n vacationMode: \(n.vacationMode.rawValue)\n autoLock: \(n.isAutoLock.rawValue)\n autoLockTime: \(n.autoLockTime ?? 0000)\n autoLockMinLimit: \(n.autoLockMinLimit ?? 0000)\n autoLockMaxLimit: \(n.autoLockMaxLimit ?? 0000)\n sound:\(n.sound.rawValue)\n voiceType: \(n.voiceType.rawValue)\n voiceValue: \(n.voiceValue.name)\n fastMode: \(n.fastMode.rawValue)\n SabbathMode: \(n.sabbathMode.rawValue)\n language: \(n.language)\n supportLanguages: \(n.supportLanguages)"
            }
            
            if let v = value.isConfigured {
                if v {
                    msg += "✅ Config set success"
                } else {
                    msg += "❌ Config set fail"
                }
              
            }
        } else {
            msg += "❌ Config failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func v3utility(value: resUtilityUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let n = value.version {
                msg += "✅ Version successfully: \(n.type?.rawValue), \(n.version)"
            }
            if let n = value.isFactoryReset {
                if n {
                    msg += "✅ FactoryReset success"
                } else {
                    msg += "❌ FactoryReset fail"
                }
               
            }
            
            if let n = value.isMatter {
                
                msg += "✅ isMatter: \(n)"
            }
            
            if let n = value.alert {
                msg += "✅ Alert: \(n.type)"
            }
        } else {
            msg += "❌ Version/FactoryReset/Matter/Alert failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func v3Token(value: resTokenUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let n = value.array {
                msg += "✅ Token array successfully: \(n)"
            }
            if let value = value.data {
           
                v3Token = value
                if value.isOwnerToken == .notOwner {
                    v3Token?.indexOfToken = tokenIndex
                }
                msg += "TokenData: \nisenable: \(value.isEnable)\n tokenmode: \(value.tokenMode.rawValue)\n isowner: \(value.isOwnerToken.rawValue)\n tokenpermission: \(value.tokenPermission.rawValue)\n token: \(value.token?.toHexString() ?? "")\n name: \(value.name ?? "")\n indexoftoken: \(value.indexOfToken ?? 0000) \n identiy: \(value.idenity)"
            }
            
            if let value = value.created {
                 msg += "TokenOption: \nisSuccess: \(value.isSuccess)\n token: \(value.token?.toHexString() ?? "")\n index: \(value.index ?? 0000)"
                tokenIndex = value.index
              
            }
            
            if let n = value.isEdited {
                if n {
                    msg += "✅ Token edited success"
                } else {
                    msg += "❌ Token edited fail"
                }
               
            }
            
            if let n = value.isDeleted {
                if n {
                    msg += "✅ Token deleted success"
                } else {
                    msg += "❌ Token deleted fail"
                }
               
            }
            
        } else {
            msg += "❌ Token failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func v3Log(value: resLogUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let n = value.count {
                msg += "✅ Log count successfully: \(n)"
            }
            
            if let value = value.data {
                 msg += "LogData: \ntimestamp: \(value.timestamp)\n event: \(value.event)\n name: \(value.name)\n message: \(value.message ?? "")"
            }
        } else {
            msg += "❌ Log failed"
        }
        appendLogToTextView(logMessage: msg)
    }
    
    func v3User(value: resUserUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let value = value.able {
                self.able = value
               msg += "Able: \nisMatter: \(value.isMatter)\n weekday: \(value.weekdayCount ?? 9999)\n yeardat: \(value.yeardayCount ?? 9999)\n code: \(value.codeCount ?? 9999)\n card: \(value.cardCount ?? 9999) \n frigerprint: \(value.fpCount ?? 9999)\n face: \(value.faceCount ?? 9999)"
            }
            
            if let value = value.array {
                var index = 1
                
                while value.contains(index) {
                    // 如果包含，则index加1
                    index += 1
                }
                userCredentailEmptyIndex = index
                msg += "✅ User array successfully: \(value)"
            }
            
            if let value = value.data {
                self.userCredentialData = value
                var credentailStucts = ""
                
     
                
                var weeks = ""
                value.weekDayscheduleStruct.forEach({ el in
                    var msg = "---weekDayscheduleStruct---\n status: \(el.status.description)\n daymask: \(el.daymask?.description)\n startHour: \(el.startHour ?? "N/A")\n startMinute: \(el.startMinute ?? "N/A")\n endHour: \(el.endHour ?? "N/A")\n endMinute: \(el.endMinute ?? "N/A")\n --- \n"
                    weeks += msg
                })
                
                // 创建一个DateFormatter
                let dateFormatter = DateFormatter()

                // 设置日期和时间的样式
                // 这里使用自定义格式
                dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
                
             
                
                var years = ""
                value.yearDayscheduleStruct.forEach({ el in
                    var msg = "---yearDayscheduleStruct---\n staus: \(el.status.description) \n start: \(dateFormatter.string(from: el.start ?? Date()))\n end: \(dateFormatter.string(from: el.end ?? Date()))\n"
                    years += msg
                })
                
                
              msg += "UserData: \nindex: \(value.index ?? 999)\n name: \(value.name ?? "N/A") \n status: \(value.status.description)\n type: \(value.type.description)\n credential rule: \(value.credentialRule.description)\n weekDayCount: \(value.weekDayscheduleStruct.count)\n \(weeks) \n yeardayCount: \(value.yearDayscheduleStruct.count )\n \(years)"
            }
            
            if let n = value.isCreatedorEdited {
                self.able = nil
                self.userCredentailEmptyIndex = nil
                self.userCredentialData = nil
                if n {
                    msg += "✅ User CreatedorEdited success"
                } else {
                    msg += "❌ User CreatedorEdited fail"
                }
     
            }
            
            if let n = value.isDeleted {
                self.able = nil
                self.userCredentailEmptyIndex = nil
                self.userCredentialData = nil
                if n {
                    msg += "✅ User Deleted success"
                } else {
                    msg += "❌ User Deleted fail"
                }
           
            }
            
            if let value = value.supportedCounts {
                userSupportCount = value
                msg += "UserSupport: \nMatter: \(value.matter) \n code: \(value.code) \n card: \(value.card) \n fp: \(value.fp)\n face: \(value.face)"
            }
       
            
        } else {
            msg += "❌ User failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func v3Credential(value: resCredentialUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            if let value = value.array {
                var index = 1
                
                while value.contains(index) {
                    // 如果包含，则index加1
                    index += 1
                }
                credentailEmptyIndex = index
                msg += "✅ Credential array successfully: \(value)"
            }
            
            if let value = value.data {
                if value.format == .credential {
                    credentialData = value
                }
                var credentialDetailStruct = ""
                
                value.credentialDetailStruct?.forEach({ el in
                    let msg = "---credentialDetailStruct---\n type: \(el.type.description)\n status: \(el.status.description) \n data: \(el.data ?? "") \n --- \n"
                    credentialDetailStruct += msg
                })
                
                
                msg += "CredentialData: \nformat: \(value.format!.description)\n CredentialIndex: \(value.credientialIndex ?? 999)\n userIndex: \(value.userIndex ?? 999)\n status: \(value.status.description)\n type: \(value.type.description)\n \(credentialDetailStruct)"
            }
            
            if let n = value.isCreatedorEdited {
                self.able = nil
                self.credentailEmptyIndex = nil
                self.credentialData = nil
                if n {
                    msg += "✅ CredentialData CreatedorEdited success"
                } else {
                    msg += "❌ CredentialData CreatedorEdited fail"
                }
         
            }
            
            if let n = value.isDeleted {
                self.able = nil
                self.credentailEmptyIndex = nil
                self.credentialData = nil
                if n {
                    msg += "✅ CredentialData deleted success"
                } else {
                    msg += "❌ CredentialData deleted fail"
                }
              
            }
            
            if let setup = value.setup {
                
                msg += "CredentialData: \nSetup status: \(setup.status.description), data: \(setup.data?.toHexString()), index: \(setup.index), state: \(setup.state.description), type: \(setup.type.description)"
                
                if setup.status == .success, let data =  setup.data, setup.type == .rfid {
                  
                    cardFpFaceCredentialRequestModel?.credentialData.data = setup.data?.toHexString() ?? ""
                    
                    let model = SetupCredentialRequestModel(type: setup.type, index: setup.index!, state: .quit)
                    
                    
                    SunionBluetoothTool.shared.UseCase.credential.setCardFpFace(model: model)
                }
                
                if setup.state == .quit, let model = cardFpFaceCredentialRequestModel {
                    SunionBluetoothTool.shared.UseCase.credential.createorEdit(model: model)
                }
            }
            
         
        } else {
            msg += "❌ CredentialData failed"
        }
        appendLogToTextView(logMessage: msg)
    }
    
    func v3Plug(value: plugStatusResponseModel?) {
        var msg = "==V3==\n"
        if let value = value {
            self.isWifi = true
            msg += "Plug: \nmainVersion: \(value.mainVersion)\n subVersion: \(value.subVersion)\nisWifiSetting: \(value.isWifiSetting) \n isWifiConnecting: \(value.isWifiConnecting)\n isOn: \(value.isOn)"
            
            plugmode = value.isOn ? .off : .on
          
        } else {
            msg += "❌ Plug failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
    func v3Endpoint(value: resEndpointUseCase?) {
        var msg = "==V3==\n"
        if let value = value {
            msg += "Endpoint: \ntype: \(value.type), data: \(value.data)"
        } else {
            msg += "❌ Endpoint failed"
        }
        
        appendLogToTextView(logMessage: msg)
    }
    
  
    func v3OTA(value: resOTAUseCase?) {
        if let value = value?.status {
            if !value.isSuccess || value.state == .cancel{
               
                appendLogToTextView(logMessage: "OTA unSuccess or state is cancel")
            }
            
            // start
            if value.state == .start, value.isSuccess {
                let byteArray: [UInt8] = Array(otaDatas.first!)
                let req = OTADataRequestModel(offset: 0, data: byteArray)
               
                SunionBluetoothTool.shared.UseCase.ota.update(model: req)
            }
            
            // end
            if value.state == .finish, value.isSuccess {
                otaDatas = []
                otaReqModel = nil
                otaUpdateCount = 0
                appendLogToTextView(logMessage: "OTA Finish")
            }
        }
        
        if let value = value?.data {
            
               let nextOffset = value.Offset + 128
               otaUpdateCount += 1
            let progress = CGFloat(Double(otaUpdateCount)/Double(allDataCount))
            appendLogToTextView(logMessage: "OTA 進度： \(progress)")
             
               
               if otaUpdateCount  >= otaDatas.count,
               let req = otaReqModel {
                   SunionBluetoothTool.shared.UseCase.ota.responseStatus(model: req)
               } else if otaUpdateCount < otaDatas.count {
                   let byteArray: [UInt8] = Array(otaDatas[otaUpdateCount])
                   let req = OTADataRequestModel(offset: nextOffset, data: byteArray)
                   SunionBluetoothTool.shared.UseCase.ota.update(model: req)

               }
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

extension Data {
    func split(by chunkSize: Int) -> [Data] {
        var chunks: [Data] = []
        var start = startIndex
        
        while start < endIndex {
            let end = self.index(start, offsetBy: chunkSize, limitedBy: endIndex) ?? endIndex
            chunks.append(self[start..<end])
            start = end
        }
        
        return chunks
    }
    
 
}
