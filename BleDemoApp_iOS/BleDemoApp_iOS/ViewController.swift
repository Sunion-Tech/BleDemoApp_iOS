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
            switch name {
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
        
        // 添加一个确认按钮
        let doneButton = UIBarButtonItem(title: "Confirm", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        
        toolBar.setItems([doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        // 将pickerView和工具条设置为textField的inputView和inputAccessoryView
        textField.inputView = pickerView
        textField.inputAccessoryView = toolBar
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
        case .addAdminCode:
            SunionBluetoothTool.shared.setupAdminCode(Code: "0000")
        case .adminCodeExist:
            SunionBluetoothTool.shared.isAdminCode()
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
    
    func AdminCode(bool: Bool?) {
        if let bool = bool {
            appendLogToTextView(logMessage: "adminCode set successfully: `0000`")
        } else {
            appendLogToTextView(logMessage: "adminCode setting failed")
        }
    }
    
    func AdminCodeExist(bool: Bool?) {
        if let bool = bool, bool {
            appendLogToTextView(logMessage: "adminCode exists")
        } else {
            appendLogToTextView(logMessage: "adminCode does not exist")
        }
    }
    
    
}
