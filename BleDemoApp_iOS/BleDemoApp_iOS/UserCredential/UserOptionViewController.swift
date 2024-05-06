//
//  UserOptionViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/8.
//

import UIKit
import SunionBluetoothTool

protocol UserOptionViewControllerDelegate: AnyObject {
    func optionData(add: AddTokenModel?, edit: EditTokenModel?)
    func v3optionData(add: addBleUserModel?, edit: EditBleUserModel?)
}

class UserOptionViewController: UIViewController {

    @IBOutlet weak var permissionSegment: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var titleLabel: UILabel!
    
    weak var delegate: UserOptionViewControllerDelegate?
    
    var data: TokenModel?
    var v3data: BleUserModel?
    var v3 = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if v3 {
            if let data = v3data {
                titleLabel.text = "Edit User"
                nameTextField.text = data.name
                if data.tokenPermission == .manager {
                    permissionSegment.selectedSegmentIndex =  0
                }
                
                if data.tokenPermission == .user {
                    permissionSegment.selectedSegmentIndex =  1
                }
            } else {
                titleLabel.text = "Add User"
            }
        } else {
            if let data = data {
                titleLabel.text = "Edit User"
                nameTextField.text = data.name
                if data.tokenPermission == .manager {
                    permissionSegment.selectedSegmentIndex =  0
                }
                
                if data.tokenPermission == .user {
                    permissionSegment.selectedSegmentIndex =  1
                }
            } else {
                titleLabel.text = "Add User"
            }
        }
       
    }
    

    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func confirmAction(_ sender: UIButton) {
        
        if self.v3 {
            if let data = v3data {
                // edit
           
                let model = EditBleUserModel(tokenName: nameTextField.text!, tokenPermission: permissionSegment.selectedSegmentIndex == 0 ? .all : .limit, tokenIndex: data.indexOfToken!, idenity: "")
                delegate?.v3optionData(add: nil, edit: model)
            } else {
                // add
                let model = addBleUserModel(tokenName: nameTextField.text!, tokenPermission: permissionSegment.selectedSegmentIndex == 0 ? .all : .limit, idenity: "")
                delegate?.v3optionData(add: model, edit: nil)
            }
        } else {
            if let data = data {
                // edit
           
                let model = EditTokenModel(tokenName: nameTextField.text!, tokenPermission: permissionSegment.selectedSegmentIndex == 0 ? .all : .limit, tokenIndex: data.indexOfToken!)
                delegate?.optionData(add: nil, edit: model)
            } else {
                // add
                let model = AddTokenModel(tokenName: nameTextField.text!, tokenPermission: permissionSegment.selectedSegmentIndex == 0 ? .all : .limit)
                delegate?.optionData(add: model, edit: nil)
            }
            
        }
        
      
        self.dismiss(animated: true)
    }

}
