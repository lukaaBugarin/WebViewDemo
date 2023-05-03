//
//  SwipeGestureWebView.swift
//  WebViewDemoApp
//
//  Created by Luka Bugarin on 28.04.2023..
//

import UIKit

class SwipeGestureRecognizer: UISwipeGestureRecognizer {
    private let action: () -> Void
    
    init(direction: UISwipeGestureRecognizer.Direction, action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.direction = direction
        self.addTarget(self, action: #selector(handleGesture))
    }
    
    @objc private func handleGesture() {
        action()
    }
}

