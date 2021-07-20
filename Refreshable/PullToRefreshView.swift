//
//  PullToRefreshView.swift
//  PullToRefreshView
//
//  Created by 风起兮 on 2021/7/17.
//

import SwiftUI

struct PullToRefreshView<Header, Content, Footer> {
    
    private let header: Header
    private let footer: Footer
    
    private let content: () -> Content
    
    @Environment(\.headerRefreshData) private var headerRefreshData
    @Environment(\.footerRefreshData) private var footerRefreshData
    
}

extension PullToRefreshView: View where Header: View, Content: View, Footer: View {
    
    init(header: Header, footer: Footer, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.footer = footer
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
                .opacity(dynamicHeaderOpacity)
                .frame(maxWidth: .infinity)
                .anchorPreference(key: HeaderBoundsPreferenceKey.self, value: .bounds, transform: {[.init(bounds: $0)]})
            content()
            footer
                .opacity(dynamicFooterOpacity)
                .frame(maxWidth: .infinity)
                .anchorPreference(key: FooterBoundsPreferenceKey.self, value: .bounds, transform: {[.init(bounds: $0)]})
        }
        .padding(.top, dynamicHeaderPadding)
        .padding(.bottom, dynamicFooterPadding)
        .animation(dynamicHeaderPadding < 0 ? /*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/ : nil)
    }
    
    var dynamicHeaderOpacity: Double {
        if headerRefreshData.refreshState == .invaild {
            return 0.0
        }
        
        if headerRefreshData.refreshState == .stopped {
            return headerRefreshData.progress
        }
        return 1.0
    }
    
    var dynamicFooterOpacity: Double {
        if footerRefreshData.refreshState == .invaild {
            return 0.0
        }
        
        if footerRefreshData.refreshState == .stopped {
            return footerRefreshData.progress
        }
        return 1.0
    }
    
    var dynamicHeaderPadding: CGFloat {
        return (headerRefreshData.refreshState == .loading) ? 0.0 : -headerRefreshData.thresold
    }

    var dynamicFooterPadding: CGFloat {
        return (footerRefreshData.refreshState == .loading) ? 0.0 : -footerRefreshData.thresold
    }
}

extension PullToRefreshView where Header: View, Content: View, Footer == EmptyView {
    
    init(header: Header, @ViewBuilder content: @escaping () -> Content) {
        self.init(header: header, footer: EmptyView(), content: content)
    }
}


extension PullToRefreshView where Header == EmptyView, Content: View, Footer: View {
    
    init(footer: Footer, @ViewBuilder content: @escaping () -> Content) {
        self.init(header: EmptyView(), footer: footer, content: content)
    }
}


extension PullToRefreshView where Header == RefreshDefaultHeader, Content: View, Footer == RefreshDefaultFooter {
    
    init(content: @escaping () -> Content) {
        self.init(header: RefreshDefaultHeader(), footer: RefreshDefaultFooter(), content: content)
    }
}
