//
//  SwiftUIViewController.swift
//  PoseFinder
//
//  Created by DSPLAB on 10/2/22.
//  Copyright © 2022 Apple. All rights reserved.
//
struct SwiftUIView: View {

    var body: some View {
        VStack {
            Text("Hello World")
        }
    }

}

import Foundation
class SwiftUIViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1.
        let swiftUIView = SwiftUIView()
        
        // 2.
        let hostingController = UIHostingController.init(rootView: swiftUIView)
        
        // 3.
        self.addChild(hostingController)
        
        // 4.
        hostingController.didMove(toParent: self)
        
        // 5.
        self.view.addSubview(hostingController.view)
        
        // 6.
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ])
        
    }
    
}
