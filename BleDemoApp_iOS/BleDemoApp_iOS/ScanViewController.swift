//
//  ScanViewController.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/6.
//

import UIKit
import AVFoundation
import CoreBluetooth
import SunionBluetoothTool

protocol ScanViewControllerDelegate: AnyObject {
    func QrCodeData(model: BluetoothToolModel)
}

class ScanViewController: UIViewController, CBCentralManagerDelegate, CameraViewDelegate {

    
    
    @IBOutlet weak var scanView: CameraView!
    
 
    var centralManager: CBCentralManager!
    weak var delegate: ScanViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
     
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraAuthorizationStatus {
        case .authorized:
            print("已授权，可以访问相机")
        case .denied, .restricted:
            print("访问相机被拒绝或受限")
            showSettingAlert()
        case .notDetermined:
            // 用户还没有做出选择，可以请求权限
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    print("用户授权访问相机")
                } else {
                    print("用户拒绝访问相机")
                    self.showSettingAlert()
                    
                }
            }
        @unknown default:
            fatalError("未知的相机授权状态")
        }
        
    }
    


    private func setupView() {

        scanView.layer.borderWidth = 4
        scanView.layer.borderColor = UIColor.black.cgColor
        scanView.delegate = self
        
    }
    
    // QRCode
    
    func cameraView(_ cameraView: CameraView, didDetectQRCode code: String) {
        print("扫描到的QR码: \(code)")
        
        if let decodeConfig = SunionBluetoothTool.shared.decodeQrCode(barcodeKey: "SoftChefSunion65", qrCode: code),
           let _ = decodeConfig.macAddress,
           let _ = decodeConfig.modelName {
            // 在这里处理扫描到的QR码，比如展示结果或进行下一步操作
            delegate?.QrCodeData(model: decodeConfig)
            self.navigationController?.popViewController(animated: true)
            
        } else {
          
            showAlert(title: "Unable to fetch this code", message: "") {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
    }
    
    // MARK:- Bluetooh
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
           switch central.state {
           case .poweredOn:
               print("蓝牙已开启，并且应用有权限使用。")
           case .poweredOff:
               print("蓝牙已关闭。请在设置中开启。")
           case .unauthorized:
               // 判断具体的权限状态（iOS 13+）
               if #available(iOS 13.0, *) {
                   switch central.authorization {
                   case .allowedAlways:
                       print("应用有权限使用蓝牙。")
                   case .denied:
                       print("用户拒绝了应用使用蓝牙的权限。请在设置中允许。")
                       showSettingAlert()
                   case .restricted:
                       print("蓝牙权限受限制。")
                   default:
                       print("未知的蓝牙权限状态。")
                   }
               } else {
                   // 在iOS 13以下版本中，没有更详细的权限状态可用
                   print("用户未授权应用使用蓝牙或蓝牙权限受限制。")
               }
           case .unknown:
               print("蓝牙状态未知。")
           case .resetting:
               print("蓝牙正在重置，稍后将更新。")
           case .unsupported:
               print("该设备不支持蓝牙。")
           @unknown default:
               print("未知的蓝牙状态。")
           }
       }
    


    private func showSettingAlert(){
        let alert = UIAlertController(title: "", message: "Please turn on Bluetooth or Camera on your device", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "OK", style: .default) { (okPressed) in
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                        
                    })
                } else {
                    //                    Toast.show("請至 App 中設定開啟相機及讀取相簿的權限以掃描 QR-Code")
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alert,animated: true, completion: nil)
        }
    }

}
