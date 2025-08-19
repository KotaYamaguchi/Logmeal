//
//  YouTubeViewRepresentable.swift
//  LogmealApp
//
//  Created by Kota Yamaguchi on 2025/08/19.
//
import SwiftUI
import Network
import WebKit
import AVKit

struct YouTubeViewRepresentable: UIViewRepresentable {
    let videoID: String
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false  // Disable scrolling
        webView.contentMode = .scaleAspectFit  // Adjust content scaling
        
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        let htmlString = """
        <html>
        <body style="margin:0;padding:0;">
        <iframe width="100%" height="100%" src="https://www.youtube.com/embed/\(videoID)?playsinline=1" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
        </body>
        </html>
        """
        uiView.loadHTMLString(htmlString, baseURL: nil)
    }
}
