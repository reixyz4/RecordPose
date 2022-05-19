//
//  CameraPreview.swift
//  PoseFinder
//
//  Created by DSPLAB on 10/2/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

final class CameraPreview: UIView {
  var previewLayer: AVCaptureVideoPreviewLayer {
    // swiftlint:disable:next force_cast
    layer as! AVCaptureVideoPreviewLayer
  }

  override class var layerClass: AnyClass {
    AVCaptureVideoPreviewLayer.self
  }
}
