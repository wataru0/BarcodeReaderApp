//
//  BarcodeReader.swift
//  BarcodeReaderApp
//
//  Created by 岡本航昇 on 2020/09/07.
//  Copyright © 2020 wataru okamoto. All rights reserved.
//

import UIKit
import AVFoundation // 画像や音声の細かい作業を行うAPI

// AVFoundationの各メソッドを定義するクラス
// AVFoundationは三つの構成になっている
// 入力デバイス（AVCaptureDevice）-> セッション（AVCaptureSession）-> 出力（AVCaptureOutput）
class BarcodeReader {
    // セッションのインスタンス生成,AVCaptureSession:キャプチャ系の全体を管理する
    let captureSession = AVCaptureSession()
    
    // 背面カメラを入力として使用する，デバイスの初期化.
    // AVCaptureDeviceInputでAVCaptureSessionに繋ぐ
    let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    
    // 出力の初期化．（メタデータ）
    var metadataOutput = AVCaptureMetadataOutput()
    
    var forwardDelegate: AVCaptureMetadataOutputObjectsDelegate?
    var delegate: AVCaptureMetadataOutputObjectsDelegate? {
        // getterとsetter
        // get:値を取得するときに呼ばれる, set:値をセットするときに呼ばれる
        get{
            return self.forwardDelegate
        }
        set(v) {
            self.forwardDelegate = v
            self.metadataOutput.setMetadataObjectsDelegate(v, queue: DispatchQueue.main)
        }
    }
    
    var preview: UIView?
    // リアルタイムにカメラに写っている映像を見せるためのインスタンス
    var previewLayer = AVCaptureVideoPreviewLayer()
    let qrView = UIView()
    
    func setupCamera(view:UIView, borderWidth:Int = 1, borderColor:CGColor = UIColor.red.cgColor) {
        self.preview = view
        
        // デバイスからの入力
        // do catch 文はエラーを受け取り対処する．catch文でエラーが発生した場合の処理を書く
        do {
            // AVCaptureDeviceInputを使ってAVCaptureSessionにデバイスを接続
            let videoInput = try! AVCaptureDeviceInput(device: self.videoDevice!) as AVCaptureDeviceInput
            self.captureSession.addInput(videoInput)
        }
        
        // 出力
        self.captureSession.addOutput(self.metadataOutput)
        
        // 読み込み対象タイプ, 検出対象のメタデータタイプを指定する処理．QRになっている．
//        self.metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        self.metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
        
        // カメラ映像を表示
        self.cameraPreview(view)
        
        // 認識QRの確認表示
        self.targetCapture(borderWidth:borderWidth, borderColor: borderColor)
        
        // バーコードの読み取り開始. 重いため非同期処理？
        // AVCaptureSessionに入力と出力を接続したら，startRunning()を呼び出して入力から出力までのデータフローを開始し，stopRunning()でフローを停止する．
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
    }
    
    // カメラ映像を画面に表示
    private func cameraPreview(_ view: UIView) {
        // プレビューレイヤーの生成
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        //view.layer.insertSublayer(previewLayer, at: 0)
    }
    
    private func targetCapture(borderWidth: Int, borderColor: CGColor) {
        self.qrView.layer.borderWidth = CGFloat(borderWidth)
        qrView.layer.borderColor = borderColor
        qrView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        if let v = self.preview {
            v.addSubview(qrView)
        }
    }
    
    // 読み取り範囲の指定
    public func readRange(frame: CGRect = CGRect(x: 0.15, y: 0.3, width: 0.6, height: 0.2)) {
        self.metadataOutput.rectOfInterest = CGRect(x: frame.minY,y: 1-frame.minX-frame.size.width, width: frame.size.height,height: frame.size.width)
        
        let v = UIView()
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor.red.cgColor
        if let preview = self.preview {
            v.frame = CGRect(x: preview.frame.size.width * frame.minX, y:  preview.frame.size.height * frame.minY, width: preview.frame.size.width * frame.size.width, height: preview.frame.size.height * frame.size.height )
            preview.addSubview(v)
        }
    }
    
    func delegate(_ delegate:AVCaptureMetadataOutputObjectsDelegate) {
        self.metadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
    }
}
