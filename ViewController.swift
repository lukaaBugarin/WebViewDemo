//
//  ViewController.swift
//  WebViewDemoApp
//
//  Created by Luka Bugarin on 28.04.2023..
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    private var webView: WKWebView?
    private var overlayView: UIView?
    private var isOverlayAnimating = false
    
    let javaScriptCode = """
    function addSwipeEventListener() {
        let startX = 0;
        let endX = 0;
        let windowWidth = window.innerWidth;

        window.addEventListener('touchstart', (event) => {
            startX = event.touches[0].clientX;
        }, { passive: false });

        window.addEventListener('touchmove', (event) => {
            endX = event.touches[0].clientX;
        }, { passive: false });

        window.addEventListener('touchend', () => {
            const threshold = 20;
            if (Math.abs(startX - endX) > threshold && startX < windowWidth / 4 && endX >= windowWidth / 4) {
                window.webkit.messageHandlers.swipeDetected.postMessage('swipeDetected');
            }
        });
    }

    addSwipeEventListener();
    """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "swipeDetected")
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        let webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        view.addSubview(webView)
        self.webView = webView
            
        if let url = URL(string: "https://www.youtube.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        let overlayFrame = CGRect(x: 0, y: view.bounds.height - 100, width: view.bounds.width, height: 100)
        let overlayView = UIView(frame: overlayFrame)
        overlayView.backgroundColor = .red
        overlayView.alpha = 0.0
        view.addSubview(overlayView)
        self.overlayView = overlayView
    }
}
extension ViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript(javaScriptCode, completionHandler: nil)
    }
}

extension ViewController {
    private func showOverlay() {
        guard let overlayView = overlayView, !isOverlayAnimating else { return }
        isOverlayAnimating = true
        UIView.animate(withDuration: 0.3, animations: {
            overlayView.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 3.0, options: [], animations: {
                overlayView.alpha = 0.0
            }, completion: { _ in
                self.isOverlayAnimating = false
            })
        })
    }
}

extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "swipeDetected" {
            print("Left gesture detected")
            showOverlay()
        }
    }
}
