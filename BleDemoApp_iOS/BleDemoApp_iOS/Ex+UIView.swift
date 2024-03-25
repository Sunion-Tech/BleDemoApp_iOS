//
//  Ex+UIView.swift
//  BleDemoApp_iOS
//
//  Created by Cthiisway on 2024/3/6.
//

import AVFoundation
import UIKit

protocol CameraViewDelegate: AnyObject {
    func cameraView(_ cameraView: CameraView, didDetectQRCode code: String)
}

class CameraView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    weak var delegate: CameraViewDelegate?

    override func layoutSubviews() {
        super.layoutSubviews()
        setupCameraSession()
    }
    
    private func setupCameraSession() {
        guard captureSession == nil else { return }
        
        // 创建捕获会话
        let session = AVCaptureSession()
        session.sessionPreset = .high
        
        session.beginConfiguration()
        // 在这里进行会话配置的更改，例如添加输入和输出
        
        // 尝试获取后置相机
        guard let backCamera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: backCamera) else {
            print("无法获取后置相机。")
            return
        }
        
        
        // 将输入添加到会话中
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("无法添加相机输入。")
            return
        }
        
   
        
        // 设置预览图层
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = self.bounds
        previewLayer.videoGravity = .resizeAspectFill
        self.layer.addSublayer(previewLayer)
        videoPreviewLayer = previewLayer
        
     


        session.commitConfiguration()

        
        // 启动会话
        session.startRunning()
      
        captureSession = session
        
        
        // 添加对QR码的支持
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession!.canAddOutput(metadataOutput) {
            captureSession!.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr] // 仅识别QR码
        } else {
            print("无法添加元数据输出。")
            return
        }
    }
    
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if metadataObjects.count == 0 { return }
        
        // 检测到QR码
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           metadataObject.type == AVMetadataObject.ObjectType.qr,
           let scannedString = metadataObject.stringValue {
            captureSession?.stopRunning()
            // 使用代理通知ViewController
            delegate?.cameraView(self, didDetectQRCode: scannedString)
            
            // 可能需要停止会话
            // captureSession?.stopRunning()
        }
    }
}
