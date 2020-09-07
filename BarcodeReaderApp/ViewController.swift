//
//  ViewController.swift
//  BarcodeReaderApp
//
//  Created by 岡本航昇 on 2020/09/07.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let barcodeReader = BarcodeReader()
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        barcodeReader.delegate = self
        //barcodeReader.setupCamera(view:self.view) // label 消える
        barcodeReader.setupCamera(view:cameraView)
        
        // 読み込めるカメラ範囲
        barcodeReader.readRange()
        
        textLabel.backgroundColor = .black
    }

}

extension ViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    // バーコードを認識，読み込んだ時に呼ばれる
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 画面上に複数のバーコードがある場合，複数読み込むが，今回は便宜的に先頭のオブジェクトを処理
        if let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject {
            let barCode = barcodeReader.previewLayer.transformedMetadataObject(for: metadata) as! AVMetadataMachineReadableCodeObject
            //読み込んだQRを映像上で枠を囲む。ユーザへの通知。必要な時は記述しなくてよい。
            barcodeReader.qrView.frame = barCode.bounds
            //QRデータを表示
            if let str = metadata.stringValue {
                //print(str)
                textLabel.text = str
                
                textLabel.textColor = .white
            }
        }
    }
}

