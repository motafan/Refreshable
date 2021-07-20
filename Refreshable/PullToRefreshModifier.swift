//
//  PullToRefreshModifier.swift
//  PullToRefreshModifier
//
//  Created by 风起兮 on 2021/7/17.
//

import SwiftUI

extension ScrollView {
    
    func addPullRefresh(isHeaderRefreshing: Binding<Bool>?, onHeaderRefresh: (() -> Void)?) -> some View {
        addPullRefresh(isHeaderRefreshing: isHeaderRefreshing, onHeaderRefresh: onHeaderRefresh, isFooterRefreshing: nil, onFooterRefresh: nil)
    }
    
    func addPullRefresh(isFooterRefreshing: Binding<Bool>?, onFooterRefresh: (() -> Void)?) -> some View {
        addPullRefresh(isHeaderRefreshing: nil, onHeaderRefresh: nil, isFooterRefreshing: isFooterRefreshing, onFooterRefresh: onFooterRefresh)
    }
    
    func addPullRefresh(
        isHeaderRefreshing: Binding<Bool>?,
        onHeaderRefresh: (() -> Void)?,
        isFooterRefreshing: Binding<Bool>?,
        onFooterRefresh: (() -> Void)?
    ) -> some View
    {
        modifier(PullToRefreshModifier(isHeaderRefreshing: isHeaderRefreshing, isFooterRefreshing: isFooterRefreshing, onHeaderRefresh: onHeaderRefresh, onFooterRefresh: onFooterRefresh))
    }
}

struct PullToRefreshModifier: ViewModifier {
    
    @Binding var isHeaderRefreshing: Bool
    @Binding var isFooterRefreshing: Bool
    
    let onHeaderRefresh: (() -> Void)?
    let onFooterRefresh: (() -> Void)?
    
    init(isHeaderRefreshing: Binding<Bool>?, isFooterRefreshing: Binding<Bool>?, onHeaderRefresh: (() -> Void)?, onFooterRefresh: (() -> Void)?) {
        self._isHeaderRefreshing = isHeaderRefreshing ?? .constant(false)
        self._isFooterRefreshing = isFooterRefreshing ?? .constant(false)
        self.onHeaderRefresh = onHeaderRefresh
        self.onFooterRefresh = onFooterRefresh
    }
    
    @State private var headerRefeshData = RefreshData()
    @State private var footerRefeshData = RefreshData()
    
    func body(content: Content) -> some View {
        GeometryReader { proxy in
            content
                .environment(\.headerRefreshData, headerRefeshData)
                .environment(\.footerRefreshData, footerRefeshData)
                .onChange(of: isHeaderRefreshing, perform: { value in
                    if !value {
                        self.headerRefeshData.refreshState = .stopped
                    }
                })
                .onChange(of: isFooterRefreshing, perform: { value in
                    if !value {
                        self.footerRefeshData.refreshState = .stopped
                    }
                })
                .backgroundPreferenceValue(HeaderBoundsPreferenceKey.self) { value -> Color in
                    DispatchQueue.main.async {
                        caculateHeaderRefreshState(proxy, value: value)
                    }
                    
                   return Color.clear
                }
                .backgroundPreferenceValue(FooterBoundsPreferenceKey.self) { value -> Color in
                    DispatchQueue.main.async {
                        caculateFooterRefreshState(proxy, value: value)
                    }
                    
                   return Color.clear
                }
        }
    }
}



extension PullToRefreshModifier {
    
    private func caculateHeaderRefreshState(_ proxy: GeometryProxy, value: [HeaderBoundsPreferenceKey.Item]) {
        guard let bounds = value.first?.bounds else {
            return
        }

        guard headerRefeshData.refreshState != .loading else {
            return
        }
        
        let headerFrame = proxy[bounds] // we need geometry proxy to get real frame
        let y = headerFrame.minY
        let threshold = headerFrame.height
        let topDistance: CGFloat = 0.0
        
        if threshold != headerRefeshData.thresold {
            headerRefeshData.thresold = threshold
        }
        
        if -y == headerRefeshData.thresold && headerFrame.width == proxy.size.width && headerRefeshData.refreshState == .invaild {
            headerRefeshData.refreshState = .stopped
        }
        
        var contentOffset = y + threshold
        
        if contentOffset == 0 {
            headerRefeshData.progress = 0.0
        }
        
        guard contentOffset > topDistance else {
            return
        }
        
        contentOffset -= topDistance
        
        print("the header frame is: \(headerFrame) and scroll view size: \(proxy.size)")
        print("content offset is: \(contentOffset)")
        
        if contentOffset <= threshold && headerRefeshData.refreshState == .stopped {
            let oldProgress = headerRefeshData.progress
            let progress = Double(contentOffset / threshold)
            if progress < oldProgress {
                return
            }
            headerRefeshData.progress = (progress >= 1.0) ? 1.0 : progress
        }
        
        if contentOffset > threshold && headerRefeshData.refreshState == .stopped && headerRefeshData.refreshState != .triggered {
            headerRefeshData.refreshState = .triggered
            headerRefeshData.progress = 1.0
        }
        
        if contentOffset <= threshold && headerRefeshData.refreshState == .triggered && headerRefeshData.refreshState != .loading {
            headerRefeshData.refreshState = .loading
            headerRefeshData.progress = 1.0
            isHeaderRefreshing = true
            onHeaderRefresh?()
        }
    }
    
}


extension PullToRefreshModifier {
    
    private func caculateFooterRefreshState(_ proxy: GeometryProxy, value: [FooterBoundsPreferenceKey.Item]) {
        guard let bounds = value.first?.bounds else {
            return
        }

        guard footerRefeshData.refreshState != .loading else {
            return
        }
        
        let footerFrame = proxy[bounds]
        let y = footerFrame.minY
        let threshold = footerFrame.height
        let bottomDistance: CGFloat = 0.0
        
        let scrollViewHeight = proxy.size.height
        
        if threshold != footerRefeshData.thresold {
            footerRefeshData.thresold = threshold
        }
        
        if y >= proxy.size.height && footerFrame.width == proxy.size.width && footerRefeshData.refreshState == .invaild {
            footerRefeshData.refreshState = .stopped
        }
        
        var contentOffset = scrollViewHeight - y
        
        if  contentOffset == 0 {
            footerRefeshData.progress = 0.0
        }
        
        guard contentOffset > bottomDistance else {
            return
        }
        
        contentOffset -= bottomDistance
        
        print("the footer frame is: \(footerFrame) and scroll view size: \(proxy.size)")
        print("content offset is: \(contentOffset)")
        
        if contentOffset <= threshold && footerRefeshData.refreshState == .stopped {
            let oldProgress = footerRefeshData.progress
            let progress = Double(contentOffset / threshold)
            if progress < oldProgress {
                return
            }
            footerRefeshData.progress = (progress >= 1.0) ? 1.0 : progress
        }
        
        if contentOffset > threshold && footerRefeshData.refreshState == .stopped && footerRefeshData.refreshState != .triggered {
            footerRefeshData.refreshState = .triggered
            footerRefeshData.progress = 1.0
        }
        
        if contentOffset <= threshold && footerRefeshData.refreshState == .triggered && footerRefeshData.refreshState != .loading {
            footerRefeshData.refreshState = .loading
            footerRefeshData.progress = 1.0
            isFooterRefreshing = true
            onFooterRefresh?()
        }
        
    }
}
