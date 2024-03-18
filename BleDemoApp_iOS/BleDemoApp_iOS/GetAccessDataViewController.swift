//
//  GetAccessDataViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/18.
//

import UIKit

protocol GetAccessDataViewControllerDelegate: AnyObject {
    func getAccessData(name: String, index: Int)
}

class GetAccessDataViewController: UIViewController {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var textField: UITextField!
    
    var code = false
    var card = false
    var face = false
    var finger = false
    
    weak var delegate: GetAccessDataViewControllerDelegate?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextField()
        
        let options = ["code", "card", "face", "finger"]
        let values = [code, card, face, finger]
        
        var currentSegmentIndex = 0
        
        for (index, value) in values.enumerated() {
            if value {
                // 如果当前索引的分段已存在，更新标题；如果不存在，插入新的分段
                if currentSegmentIndex < segment.numberOfSegments {
                    segment.setTitle(options[index], forSegmentAt: currentSegmentIndex)
                } else {
                    segment.insertSegment(withTitle: options[index], at: currentSegmentIndex, animated: false)
                }
                currentSegmentIndex += 1
            }
        }
        
        // 如果UISegmentedControl中的分段比需要的多，删除多余的分段
        while segment.numberOfSegments > currentSegmentIndex {
            segment.removeSegment(at: segment.numberOfSegments - 1, animated: false)
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
        textField.inputAccessoryView = toolBar

        
        // 如果你的UITextField已经在Storyboard或者XIB中定义了，可以忽略创建UITextField的部分
        // 直接将上述代码添加到配置UITextField的地方
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func confirmAction(_ sender: UIButton) {
        if let index = textField.text {
            delegate?.getAccessData(name: segment.titleForSegment(at: segment.selectedSegmentIndex)!, index: Int(index)!)
          
            self.dismiss(animated: true)
        }

       
    }


}
