//
//  AccessCodeViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/11.
//

import UIKit

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
    
    private var textFieldSelected: UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()

        // 監聽鍵盤彈出事件
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // 添加一個 tap gesture recognizer 來關閉鍵盤
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGesture)
       
    
    }
    
    deinit {
        // 移除通知監聽
        NotificationCenter.default.removeObserver(self)
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
        
        if let activeField = textFieldSelected {
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
        // 在此處執行確認操作
        view.endEditing(true)
    }

    @IBAction func buttonCardAction(_ sender: UIButton) {
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
        textFieldSelected = textField
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
    }
}
