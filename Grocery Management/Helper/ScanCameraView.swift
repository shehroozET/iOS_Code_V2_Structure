//
//  ScanCameraView.swift
//  Grocery Management
//
//  Created by mac on 06/03/2025.
//

import UIKit
import AVFoundation
import Vision

final class ScanCameraView: UIView {

    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput = AVCapturePhotoOutput()
    private var photoSettings: AVCapturePhotoSettings?
    
    private func setupInputs() {
        var backCamera: AVCaptureDevice?

        /// Get back camera
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            backCamera = device
        } else {
            fatalError("Back camera could not be found")
        }

        /// Enable continuous auto focus
        do {
            try backCamera?.lockForConfiguration()
            backCamera?.focusMode = .continuousAutoFocus
            backCamera?.unlockForConfiguration()
        } catch {
            fatalError("Camera lockConfiguration failed")
        }

        /// Create input from our device
        guard let backCamera = backCamera, let backCameraInput = try? AVCaptureDeviceInput(device: backCamera) else {
            fatalError("Could not create device input from back camera")
        }

        if let captureSession = captureSession, !captureSession.canAddInput(backCameraInput) {
            fatalError("could not add back camera input to capture session")
        }

        captureSession?.addInput(backCameraInput)
    }
    
    private func setupOutput() {
      /// Use HEVC as codec if available to save file space and maintain quality
      if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
        photoSettings = AVCapturePhotoSettings(format:[AVVideoCodecKey: AVVideoCodecType.hevc])
      } else {
        photoSettings = AVCapturePhotoSettings()
      }

      if let captureSession = captureSession, captureSession.canAddOutput(photoOutput) {
        captureSession.addOutput(photoOutput)
      }
    }
    
    func setupCaptureSession() {
        captureSession = AVCaptureSession()
        captureSession?.beginConfiguration()

        if let captureSession = captureSession, captureSession.canSetSessionPreset(.photo) {
          captureSession.sessionPreset = .photo
        }

        setupInputs()
        setupOutput()
//        setupPreviewLayer()

        captureSession?.commitConfiguration()

        /// Start of the capture session must be executed in the background thread
        /// by our extension function so the UI is not blocked in the main thread
        
        DispatchQueue.global().async {
            self.captureSession?.startRunning()
        }
    }
    
    func perspectiveCorrectedImage(from inputImage: CIImage, rectangleObservation: VNRectangleObservation ) -> CIImage? {
        let imageSize = inputImage.extent.size

        /// Verify detected rectangle is valid
        let boundingBox = rectangleObservation.boundingBox.scaled(to: imageSize)
        guard inputImage.extent.contains(boundingBox)
        else { print("invalid detected rectangle"); return nil}

        /// Rectify the detected image and reduce it to inverted grayscale for applying model
        let topLeft = rectangleObservation.topLeft.scaled(to: imageSize)
        let topRight = rectangleObservation.topRight.scaled(to: imageSize)
        let bottomLeft = rectangleObservation.bottomLeft.scaled(to: imageSize)
        let bottomRight = rectangleObservation.bottomRight.scaled(to: imageSize)
        let correctedImage = inputImage
            .cropped(to: boundingBox)
            .applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        return correctedImage
    }

//    func cropDocumentOut(from image: CIImage) {
//        let requestHandler = VNImageRequestHandler(ciImage: image)
//        let documentDetectionRequest = VNDetectDocumentSegmentationRequest()
//
//        do {
//            try requestHandler.perform([documentDetectionRequest])
//        } catch {
//            fatalError("Error while performing documentDetectionRequest")
//        }
//
//        guard let document = documentDetectionRequest.results?.first,
//              let documentImage = perspectiveCorrectedImage(from: image, rectangleObservation: document)?.convertToCGImage() else {
//            fatalError("Unable to get document image")
//        }
//
//        /// Save our captured photo of the id
//        idBackImage = UIImage(cgImage: documentImage)
//    }
}

//extension UIImage {
//
//    /// Returns recognized text from image in the region of interest
//    /// For the machineReadableZone it is important to set the VNRequestTextRecognitionLevel
//    /// to .fast because otherwise it will try to correct the found string and this can lead to wrong results
//    func getRecognizedText(for scanItem: ScanItem,
//                           with imageSize: CGSize,
//                           recognitionLevel: VNRequestTextRecognitionLevel,
//                           minimumTextHeight: Float = 0.03125) -> [String] {
//        var recognizedTexts = [String]()
//
//        guard let imageCGImage = self.cgImage else { return recognizedTexts }
//        let requestHandler = VNImageRequestHandler(cgImage: imageCGImage, options: [:])
//
//        let request = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//
//            for currentObservation in observations {
//                /// The 1 in topCandidates(1) indicates that we only want one candidate.
//                /// After that we take our one and only candidate with the most confidence out of the array.
//                let topCandidate = currentObservation.topCandidates(1).first
//
//                if let scannedText = topCandidate {
//                    let convertedRegionOfInterest = scanItem.boundingBox.getFrame(by: imageSize, subtractY: false)
//                    let convertedObservationBoundingBox = currentObservation.boundingBox.getFrame(by: imageSize, subtractY: false)
//
//                    if convertedRegionOfInterest.intersects(convertedObservationBoundingBox) {
//                        recognizedTexts.append(scannedText.string)
//                    }
//                }
//            }
//        }
//
//        request.recognitionLevel = recognitionLevel
//        request.minimumTextHeight = minimumTextHeight
//
//        /// Turn off language correction because otherwise this could lead to wrong results in the machineReadaleZone
//        request.usesLanguageCorrection = false
//
//        try? requestHandler.perform([request])
//
//        return recognizedTexts
//    }
//
//}
extension CGPoint {
    func scaled(to size: CGSize) -> CGPoint {
        return CGPoint(x: self.x * size.width, y: self.y * size.height)
    }
}
extension CGRect {
    func scaled(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x * size.width,
            y: self.origin.y * size.height,
            width: self.size.width * size.width,
            height: self.size.height * size.height
        )
    }
}

