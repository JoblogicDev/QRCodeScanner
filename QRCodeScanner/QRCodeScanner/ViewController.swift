//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Duy Bui on 23/07/2024.
//

import UIKit

class ViewController: UIViewController, QRCodeReaderDelegate {

    @IBOutlet weak var scannerBtn: UIButton!
    @IBOutlet weak var qrContentLbl: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.➜ xcodebuild -scheme JoblogicTTTAttributedLabel -destination 'generic/platform=iOS'
    }


    @IBAction func didTapScanner(_ sender: Any) {
        let reader = QRCodeReader(metadataObjectTypes: [
            AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.aztec])
        
        let viewController = QRCodeReaderViewController(cancelButtonTitle: "Cancel", codeReader: reader, startScanningAtLoad: true, showSwitchCameraButton: false, showTorchButton: false)
        viewController.setCompletionWith({ [weak self] result in
            guard let self = self else {
                return
            }
            
            self.qrContentLbl.text = result
        })
        
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true)
    }
}
