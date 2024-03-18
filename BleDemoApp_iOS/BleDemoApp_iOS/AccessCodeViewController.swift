//
//  AccessCodeViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/11.
//

import UIKit
import SunionBluetoothTool

protocol AccessCodeViewControllerDelegate: AnyObject {
    func optionData(model: PinCodeManageModel)
    func optionData2(model: AccessRequestModel)
}

class AccessCodeViewController: UIViewController {

    @IBOutlet weak var switchEnable: UISwitch!
    @IBOutlet weak var textFieldName: UITextField!
    
    @IBOutlet weak var switchCode: UISwitch!
    @IBOutlet weak var textFieldCode: UITextField!
    
    @IBOutlet weak var switchCard: UISwitch!
    @IBOutlet weak var textFieldCard: UITextField!
    @IBOutlet weak var buttonCard: UIButton!
    
    
    @IBOutlet weak var swtichPermanent: UISwitch!
    
    @IBOutlet weak var switchValidTimeRange: UISwitch!
    @IBOutlet weak var textFieldValidTimeRangeSTART: UITextField!
    @IBOutlet weak var textFieldValidTimeRangeEND: UITextField!
    
    @IBOutlet weak var switchScheduledEntry: UISwitch!

    @IBOutlet weak var switchSu: UISwitch!
    @IBOutlet weak var switchMo: UISwitch!
    @IBOutlet weak var switchTu: UISwitch!
    @IBOutlet weak var switchWe: UISwitch!
    @IBOutlet weak var switchTh: UISwitch!
    @IBOutlet weak var switchFr: UISwitch!
    @IBOutlet weak var switchSa: UISwitch!
    
    
    @IBOutlet weak var textFieldScheduledEntrySTART: UITextField!
    @IBOutlet weak var textFieldScheduledEntryEND: UITextField!
    
    @IBOutlet weak var switchSingleEntry: UISwitch!
    
    @IBOutlet weak var stackViewSingleEntry: UIStackView!
    
    @IBOutlet weak var stackViewCard: UIStackView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    private var selectedTextField: UITextField?
    
    var model: PinCodeManageModel?
    var model2: AccessRequestModel?
    var positionIndex: Int?
    var positionCardIndex: Int?
    
    var data: PinCodeModelResult?
    var data2: AccessDataResponseModel?
    
    var isCreate: Bool?
    var isV2: Bool? = false
    
    weak var delegate: AccessCodeViewControllerDelegate?
    
    private let timePicker = UIDatePicker()
    private let timeformatter = DateFormatter()
    private let datePicker = UIDatePicker()
    private let dateformatter = DateFormatter()
    
    var bleStatus: DeviceStatusModel?
    

    var code = false
    var card = false
    var face = false
    var finger = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SunionBluetoothTool.shared.delegate = self
        // 監聽鍵盤彈出事件
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // 添加一個 tap gesture recognizer 來關閉鍵盤
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
        initUI()
        setupTimePicker()
        setupDatePicker()
       
        // init data
        if let data = data {
            switchEnable.isOn = data.isEnable
            textFieldName.text = data.name
            textFieldCode.text = data.PinCode?.map{String($0)}.joined()
            swtichPermanent.isOn  = false
            if let sche = data.schedule {
                switch sche.scheduleOption {
                case .none:
                    break
                case .once:
              
                    switchSingleEntry.isOn = true
                case .weekly(let week,let start, let end):
                    switchScheduledEntry.isOn = true
                    let startValue = start.components(separatedBy: ":")
                    let endValue = end.components(separatedBy: ":")
                   
                   textFieldScheduledEntrySTART.text = startValue.first!.appendLeadingZero + ":" + startValue.last!.appendLeadingZero
                   textFieldScheduledEntryEND.text = endValue.first!.appendLeadingZero + ":" + endValue.last!.appendLeadingZero
                    
                    let switches = [switchSa, switchFr, switchTh, switchWe, switchTu, switchMo, switchSu] // 注意顺序与问题描述相匹配
                       
                    for (index, day) in week.enumerated().reversed() {
                        if index < 7 {
                            switches[index]!.isOn = (day == 1)
                        }
                    }
                    
                    switches.forEach { element in
                        element?.isEnabled = true
                    }
                    
                case .validTime(let start, let end):
                    switchValidTimeRange.isOn  = true
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
          
                    textFieldValidTimeRangeSTART.text = dateformatter.string(from: start)
                    textFieldValidTimeRangeEND.text = dateformatter.string(from: end)
                case .error:
                    break
                case .all:
                    swtichPermanent.isOn  = true
                }
            }
        }
        
        if let data = data2 {
            switchEnable.isOn = data.isEnable
            textFieldName.text = data.name
            textFieldCode.text = data.codeCard?.map{String($0)}.joined()
            swtichPermanent.isOn  = false
            if let sche = data.schedule {
                switch sche.scheduleOption {
                case .none:
                    break
                case .once:
              
                    switchSingleEntry.isOn = true
                case .weekly(let week,let start, let end):
                    switchScheduledEntry.isOn = true
                    let startValue = start.components(separatedBy: ":")
                    let endValue = end.components(separatedBy: ":")
                   
                   textFieldScheduledEntrySTART.text = startValue.first!.appendLeadingZero + ":" + startValue.last!.appendLeadingZero
                   textFieldScheduledEntryEND.text = endValue.first!.appendLeadingZero + ":" + endValue.last!.appendLeadingZero
                    
                    let switches = [switchSa, switchFr, switchTh, switchWe, switchTu, switchMo, switchSu] // 注意顺序与问题描述相匹配
                       
                    for (index, day) in week.enumerated().reversed() {
                        if index < 7 {
                            switches[index]!.isOn = (day == 1)
                        }
                    }
                    
                    switches.forEach { element in
                        element?.isEnabled = true
                    }
                    
                case .validTime(let start, let end):
                    switchValidTimeRange.isOn  = true
                    let dateformatter = DateFormatter()
                    dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
          
                    textFieldValidTimeRangeSTART.text = dateformatter.string(from: start)
                    textFieldValidTimeRangeEND.text = dateformatter.string(from: end)
                case .error:
                    break
                case .all:
                    swtichPermanent.isOn  = true
                }
            }
        }
    
    }
    
    deinit {
        // 移除通知監聽
        NotificationCenter.default.removeObserver(self)
    }
    
    private func initUI() {
        if let ble = bleStatus {
            if let d = ble.D6 {
                stackViewCard.isHidden = true
            }
            
            if let a = ble.A2 {
                stackViewSingleEntry.isHidden = true
                if card  {
                    stackViewCard.isHidden = false
                }
              
               
            }
        }
    }
    
    // MARK: - timePikcer
    private func setupTimePicker() {
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 15
        timePicker.date = Date()
        
        if #available(iOS 13.4, *) {
            timePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
      
        timeformatter.dateFormat = "HH:mm"
        
        textFieldScheduledEntrySTART.inputView = timePicker
        textFieldScheduledEntryEND.inputView = timePicker
    }
    // MARK: - datePicker
    private func setupDatePicker() {
        datePicker.datePickerMode = .dateAndTime
        datePicker.minuteInterval = 15
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        datePicker.date = Date()
        
      
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        textFieldValidTimeRangeSTART.inputView = datePicker
        textFieldValidTimeRangeEND.inputView = datePicker
    }
    
    @objc func dismissKeyboard() {
         view.endEditing(true)
     }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        // 獲取鍵盤的尺寸
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        // 計算 scrollView 需要滾動的距離
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        
        // 讓目標元件在鍵盤的上方
        var visibleRect = scrollView.frame
        visibleRect.size.height -= keyboardFrame.height
        
        if let activeField = selectedTextField {
            let textFieldRect = activeField.convert(activeField.bounds, to: scrollView)
            if !visibleRect.contains(textFieldRect.origin) {
                scrollView.scrollRectToVisible(textFieldRect, animated: true)
            }
        }
    }
    
    @objc func cancelButtonTapped(_ sender: UIButton) {
        
        view.endEditing(true)
    }
    
    @objc func confirmButtonTapped() {
        
        if switchValidTimeRange.isOn {
            selectedTextField?.text = dateformatter.string(from: datePicker.date)
        }
        
        if switchScheduledEntry.isOn {
            selectedTextField?.text =  timeformatter.string(from: timePicker.date)
        }
        
        // 在此處執行確認操作
        view.endEditing(true)
    }
    
    @IBAction func buttonCancelAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonConfirmAction(_ sender: UIButton) {
 
        
        if textFieldName.text == nil || (switchCode.isOn && textFieldCode.text == nil) || (switchCard.isOn && textFieldCard.text == nil) {
            showAlert(title: "Fill in the correct information", message: "")
            return
        }
        
        if !swtichPermanent.isOn && !switchValidTimeRange.isOn && !switchScheduledEntry.isOn && !switchSingleEntry.isOn {
            showAlert(title: "Selected a Schedule ", message: "")
            return
        }
        var scheduleValue: PinCodeScheduleModel?
        var scheduleValue2: scheduleModel?
        
        if swtichPermanent.isOn {
            scheduleValue  = PinCodeScheduleModel(availableOption: .all)
            scheduleValue2 = scheduleModel(availableOption: .all)
        }
        
        if switchValidTimeRange.isOn, let Start = textFieldValidTimeRangeSTART.text, let End = textFieldValidTimeRangeEND.text {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            scheduleValue = PinCodeScheduleModel(availableOption: .validTime(dateFormatter.date(from: Start)!, dateFormatter.date(from: End)!))
            scheduleValue2 = scheduleModel(availableOption: .validTime(dateFormatter.date(from: Start)!, dateFormatter.date(from: End)!))
        }
        
        if switchScheduledEntry.isOn {
            var scheduleWeekday = [1, 1, 1, 1, 1, 1, 1]
            let switches = [switchSu, switchMo, switchTu, switchWe, switchTh, switchFr, switchSa]
            for (index, switchControl) in switches.enumerated() {
                scheduleWeekday[index] = switchControl?.isOn ?? false ? 1 : 0
            }
            let scheduleWeekdayString = scheduleWeekday.map { String($0) }.joined()
            let weekSelection = UInt8(scheduleWeekdayString, radix: 2) ?? 0x00
            
            scheduleValue = PinCodeScheduleModel(availableOption: .weekly(weekSelection, UInt8(getTimeSelection().first ?? 100), UInt8(getTimeSelection().last ?? 100)))
            scheduleValue2 = scheduleModel(availableOption: .weekly(weekSelection, UInt8(getTimeSelection().first ?? 100), UInt8(getTimeSelection().last ?? 100)))
        }
        
        if switchSingleEntry.isOn {
            scheduleValue  = PinCodeScheduleModel(availableOption: .once)
        }
        
        
        var vodeValue = [0]
        
        
        if isV2 ?? false {
            vodeValue = (switchCard.isOn ? textFieldCard : textFieldCode).text!.map { Int(String($0)) ?? -1 }.filter{$0 != -1}
            model2 = AccessRequestModel(type: switchCard.isOn ? .AccessCard : .AccessCode, index: switchCard.isOn ? positionCardIndex ?? 1 : positionIndex ?? 1, isEnable: switchEnable.isOn, codecard: vodeValue, name: textFieldName.text!, schedule: scheduleValue2!, accessOption: isCreate ?? false ? .add : .edit)
            delegate?.optionData2(model: model2!)
            
        } else {
            vodeValue = textFieldCode.text!.map { Int(String($0)) ?? -1 }.filter{$0 != -1}
            model = PinCodeManageModel(index: positionIndex!, isEnable: switchEnable.isOn, PinCode: vodeValue, name: textFieldName.text!, schedule: scheduleValue!, PinCodeManageOption: isCreate ?? false ? .add : .edit)
            
            delegate?.optionData(model: model!)
        }
      
  
        self.navigationController?.popViewController(animated: true)
        
    }
    
    private func getTimeSelection() -> [Int]{
        guard let startHour = textFieldScheduledEntrySTART.text!.components(separatedBy: ":").first else { return [ 0, 0 ]}
        guard let startMinute = textFieldScheduledEntrySTART.text!.components(separatedBy: ":").last else { return [ 0, 0 ]}
        
        guard let startHourIndex = Int(startHour) else {return [0,0]}
        guard let startMinuteIndex = Int(startMinute) else {return [0,0]}
     
        
        guard let endHour = textFieldScheduledEntryEND.text!.components(separatedBy: ":").first else { return [ 0, 0 ]}
        guard let endMinute = textFieldScheduledEntryEND.text!.components(separatedBy: ":").last else { return [ 0, 0 ]}
        
        guard let endHourIndex = Int(endHour) else {return [0,0]}
        guard let endMinuteIndex = Int(endMinute) else {return [0,0]}
        
    
        let startIndex = (startHourIndex * 4) + (startMinuteIndex / 15)
        let endIndex = (endHourIndex * 4) + (endMinuteIndex / 15)
        
        return [startIndex, endIndex]
    }

    @IBAction func buttonCardAction(_ sender: UIButton) {
 
        SunionBluetoothTool.shared.setupAccess(model: SetupAccessRequestModel(type: .AccessCard, index: positionCardIndex ?? 1, state: .start))
    }
    
    @IBAction func switchCodeAction(_ sender: UISwitch) {
        if sender.isOn {
            switchCard.isOn = false
            buttonCard.isEnabled = false
            textFieldCard.text = nil
            
            textFieldCode.isEnabled = true
          
        } else {
         
            textFieldCode.isEnabled = false
        }
    }
    
    
    @IBAction func switchCardAction(_ sender: UISwitch) {
        
        if sender.isOn {
            switchCode.isOn = false
            textFieldCode.isEnabled = false
            textFieldCode.text = nil
            
            buttonCard.isEnabled = true
            
        } else {
          
            buttonCard.isEnabled = false
        }
    }
    
    @IBAction func switchPermanentAction(_ sender: UISwitch) {
        
        if sender.isOn {
            validTimeRangeOption(enable: !sender.isOn)
             scheduledEntryOption(enable: !sender.isOn)
             switchSingleEntry.isOn = !sender.isOn
        }


    }
    
    
    @IBAction func switchValidTimeRangeAction(_ sender: UISwitch) {
        validTimeRangeOption(enable: sender.isOn)
        
        if sender.isOn {
            swtichPermanent.isOn = !sender.isOn
            scheduledEntryOption(enable: !sender.isOn)
            switchSingleEntry.isOn = !sender.isOn
        }
     
    }
    
    
    @IBAction func switchScheduledEntryAction(_ sender: UISwitch) {
        scheduledEntryOption(enable: sender.isOn)
        
        if sender.isOn {
            swtichPermanent.isOn = !sender.isOn
            switchSingleEntry.isOn = !sender.isOn
            validTimeRangeOption(enable: !sender.isOn)
        }
     
    }
    
    
    @IBAction func switchSingleEntryAction(_ sender: UISwitch) {
        if sender.isOn {
            swtichPermanent.isOn = !sender.isOn
            validTimeRangeOption(enable: !sender.isOn)
            scheduledEntryOption(enable: !sender.isOn)
        }
    }
    
    
    private func scheduledEntryOption(enable: Bool) {
        
        switchScheduledEntry.isOn = enable
        switchSu.isOn = enable
        switchSu.isEnabled = enable
        
        switchMo.isOn = enable
        switchMo.isEnabled = enable
        
        switchTu.isOn = enable
        switchTu.isEnabled = enable
        
        switchWe.isOn = enable
        switchWe.isEnabled = enable
        
        switchTh.isOn = enable
        switchTh.isEnabled = enable
        
        switchFr.isOn = enable
        switchFr.isEnabled = enable
        
        switchSa.isOn = enable
        switchSa.isEnabled = enable
        
        textFieldScheduledEntrySTART.isEnabled = enable
        textFieldScheduledEntryEND.isEnabled = enable
        
        if !enable {
            textFieldScheduledEntrySTART.text = nil
            textFieldScheduledEntryEND.text = nil
        }
        

        
    }
    
    private func validTimeRangeOption(enable: Bool) {
        
        switchValidTimeRange.isOn = enable
        textFieldValidTimeRangeSTART.isEnabled = enable
        textFieldValidTimeRangeEND.isEnabled = enable
        
        if !enable {
            textFieldValidTimeRangeSTART.text = nil
            textFieldValidTimeRangeEND.text = nil
        }
    }
    
    
}


extension AccessCodeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        selectedTextField = textField
        // 創建自定義 accessory view
        let accessoryView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        accessoryView.backgroundColor = .lightGray
        
        // 創建 Cancel 按鈕
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        cancelButton.frame = CGRect(x: 10, y: 0, width: 80, height: 44)
        accessoryView.addSubview(cancelButton)
        
        // 創建 Confirm 按鈕
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("Confirm", for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        confirmButton.frame = CGRect(x: accessoryView.frame.width - 90, y: 0, width: 80, height: 44)
        accessoryView.addSubview(confirmButton)
        
        // 將 accessory view 設置為 textfield 的 inputAccessoryView
        textField.inputAccessoryView = accessoryView
        
        if let text = textField.text {
            if textField == textFieldScheduledEntrySTART || textField == textFieldScheduledEntryEND  {
                timePicker.date = timeformatter.date(from: text) ?? Date()
            }
            if textField == textFieldValidTimeRangeSTART || textField == textFieldValidTimeRangeEND {
                datePicker.date = dateformatter.date(from: text) ?? Date()
            }
        }
    }
}


extension String {
    // 時間轉換
    var appendLeadingZero:String {
        if self == "0" {
            return "00"
        } else {
            return self
        }
    }
}




extension AccessCodeViewController: SunionBluetoothToolDelegate {
    func BluetoothState(State: bluetoothState) {
        
    }
    func SetupAccess(value: SetupAccessResponseModel?) {
        if let value = value {
            textFieldCard.text = value.data?.toHexString()
        }
    }
    
}
