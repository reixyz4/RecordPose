/*
extension CaptureProcessor {
    
    func processCapture(pixelBuffer: CVPixelBuffer) {
        let ciimage = CIImage.init(cvPixelBuffer: pixelBuffer)
        frameTranslator.captureSize = ciimage.extent
        
        let detectionRequest = VNDetectFaceRectanglesRequest.init { [weak self] (request, error) in
            
            guard let results = request.results?.compactMap({ $0 as? VNFaceObservation }) else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.processFaceObservations(results, ciimage: ciimage)
            }
        }
        
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer)
        
        try? handler.perform([detectionRequest])
        
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(ciimage, from: ciimage.extent) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let `self` = self else { return }
            self.delegate.didCaptureImage(UIImage.init(cgImage: cgImage))
        }
    }
    func processFaceObservations(_ observations: [VNFaceObservation], ciimage: CIImage) {
        
        let availableViews: [UIImageView] = delegate.boxes
        
        var map: [UIImageView:VNFaceObservation] = [:]
        
        var faceObservations: [VNFaceObservation] = observations
        
        for view in availableViews {
            
            faceObservations = faceObservations.sorted(by: {
                let c1 = frameTranslator.convertBoundingRect($0.boundingBox).center
                let c2 = frameTranslator.convertBoundingRect($1.boundingBox).center
                
                let c = view.frame.center
                
                return c.distance(to: c1) < c.distance(to: c2)
            })
            
            guard !faceObservations.isEmpty else { break }
            
            guard let nearestFace = faceObservations.first else { continue }
            
            faceObservations.remove(at: 0)
            
            map[view] = nearestFace
        }
        
        for observation in faceObservations {
            let view = delegate.getImageView(at: frameTranslator.convertBoundingRect(observation.boundingBox))
            map[view] = observation
        }
        
        let unusedViews = availableViews.filter { !map.keys.contains($0) }
        
        unusedViews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        delegate.boxes = Array(map.keys)
        
        for (view,observation) in map {
            let rect: CGRect = frameTranslator.convertBoundingRect(observation.boundingBox)
            
            delegate.positionFace(at: rect, view: view)
            detectGender(faceObservation: observation, ciimage: ciimage, faceView: view, faceRect: rect)
        }
    }
*/
