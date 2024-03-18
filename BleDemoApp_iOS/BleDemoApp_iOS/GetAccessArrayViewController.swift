//
//  GetAccessArrayViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/18.
//

import UIKit

protocol GetAccessArrayViewControllerDelegate: AnyObject {
    func getAccessArray(name: String)
}


class GetAccessArrayViewController: UIViewController {

    @IBOutlet weak var segment: UISegmentedControl!
    
    var code = false
    var card = false
    var face = false
    var finger = false
    
    weak var delegate: GetAccessArrayViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    

    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func confirmAction(_ sender: UIButton) {

        
        delegate?.getAccessArray(name: segment.titleForSegment(at: segment.selectedSegmentIndex)!)
        self.dismiss(animated: true)
    }
    
}
