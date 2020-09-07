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
    }

}

