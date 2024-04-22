//
//  WifiViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/4/22.
//

import UIKit
import SunionBluetoothTool

protocol WifiViewControllerDelegate: AnyObject {
    func setupWifi(Bool: Bool)
  
}

class WifiViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var ssids:[SSIDModel] = []

    weak var delegate: WifiViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        SunionBluetoothTool.shared.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SunionBluetoothTool.shared.UseCase.wifi.list()
    }

}

extension WifiViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ssids.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = ssids[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let ssid = ssids[indexPath.row].name!
        if ssids[indexPath.row].passwordLevel == .required {
            promptForPassword(ssid: ssid)
        } else {
            // connected
            SunionBluetoothTool.shared.UseCase.wifi.configureWiFi(SSIDName: ssid, password: "")
     
        }
       
    }
    
    func promptForPassword(ssid: String) {
        let alertController = UIAlertController(title: "Enter Password", message: "Please enter the password for \(ssid)", preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true // 密码输入框
        }

        let connectAction = UIAlertAction(title: "Connect", style: .default) { [weak alertController] _ in
            guard let textField = alertController?.textFields?.first, let password = textField.text else { return }
            print("Password for \(ssid): \(password)") // 实际应用中这里可以做进一步处理，如尝试连接网络等
            SunionBluetoothTool.shared.UseCase.wifi.configureWiFi(SSIDName: ssid, password: password)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        alertController.addAction(connectAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true)
    }
    
}


extension WifiViewController: SunionBluetoothToolDelegate {
    func BluetoothState(State: bluetoothState) {
        
    }
    
    
    func v3Wifi(value: resWifiUseCase?) {
        if let value = value {
            if let list = value.list {
     
                
                if let _ = list.name {
                    ssids.append(list)
                    
         
                }
                
                
                if list.passwordLevel == .completed {
                    let ssidsorted = ssids.sorted { $0.signal! > $1.signal! }
                    ssids = ssidsorted

                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
            
            if let isWifi = value.isWifi {
                delegate?.setupWifi(Bool: isWifi)
                self.navigationController?.popViewController(animated: true)
            }

        }
    }
    
}
