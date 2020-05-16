import AVFoundation
import UIKit

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
   // @IBOutlet weak var scanView: UIView!
    
    @IBOutlet weak var grView: UIImageView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    //var productSCanVC: ProductScanViewController!
    
    let systemSoundID: SystemSoundID = 1016
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        //grView.layer.borderWidth = 2
        //grView.layer.borderColor = UIColor.green.cgColor
       // grView.backgroundColor = .cyan
        cancelBtn.layer.cornerRadius = 7
        cancelBtn.addTarget(self, action: #selector(goBackAgain), for: .touchUpInside)
        reStart()
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipe))
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.right
        self.view.addGestureRecognizer(swipeLeft)
        view.isUserInteractionEnabled = true
    
    }
                     
    @objc func swipe(){
        self.dismiss(animated: true, completion: nil)
    }

    func reStart(){
        //view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            //productSCanVC.didScannerOpen = false
            
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            //FORMATS OF BARCODE
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .code39, .code128, .qr]
        } else {
            failed()
           // productSCanVC.didScannerOpen = false
            
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = self.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        
       
        view.bringSubviewToFront(grView)
        view.bringSubviewToFront(cancelBtn)
        captureSession.startRunning()
    }
    
    @objc func goBackAgain(){
        //CODE FOR CANCEL BUTTON ACTION
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
           
        }

        dismiss(animated: true)
    }

    func found(code: String) {
        
        AudioServicesPlaySystemSound(systemSoundID)
        print("CODE => \(code)")
        
        let ac = UIAlertController(title: "Scanning Success", message: "\(code)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            _ in

        }))
        
        self.present(ac, animated: true)
        self.code = code
       // self.goBack(code: code)
         self.reStart()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    var code: String!
}

