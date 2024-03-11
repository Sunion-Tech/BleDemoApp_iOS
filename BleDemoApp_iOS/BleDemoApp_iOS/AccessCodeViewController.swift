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
    override func viewDidLoad() {
        super.viewDidLoad()

        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        scrollView.contentSize = (CGSize(width: screenWidth, height: screenHeight))
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
        
        validTimeRangeOption(enable: !sender.isOn)
         scheduledEntryOption(enable: !sender.isOn)
         switchSingleEntry.isOn = !sender.isOn
 
       
    }
    
    
    @IBAction func switchValidTimeRangeAction(_ sender: UISwitch) {
        

        swtichPermanent.isOn = !sender.isOn
        validTimeRangeOption(enable: sender.isOn)
        scheduledEntryOption(enable: !sender.isOn)
        switchSingleEntry.isOn = !sender.isOn
    }
    
    
    @IBAction func switchScheduledEntryAction(_ sender: UISwitch) {
        swtichPermanent.isOn = !sender.isOn
        switchSingleEntry.isOn = !sender.isOn
        validTimeRangeOption(enable: !sender.isOn)
        scheduledEntryOption(enable: sender.isOn)
    }
    
    
    @IBAction func switchSingleEntryAction(_ sender: UISwitch) {
        swtichPermanent.isOn = !sender.isOn
        switchSingleEntry.isOn = !sender.isOn
        validTimeRangeOption(enable: !sender.isOn)
        scheduledEntryOption(enable: !sender.isOn)
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
        textFieldValidTimeRangeSTART.isEnabled = enable
        if !enable {
            textFieldValidTimeRangeSTART.text = nil
            textFieldValidTimeRangeEND.text = nil
        }
      
    }
    
    
}
