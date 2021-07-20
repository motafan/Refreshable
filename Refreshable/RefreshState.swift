//
//  RefreshState.swift
//  RefreshState
//
//  Created by 风起兮 on 2021/7/17.
//

import SwiftUI

//  MARK: - Preferences

struct HeaderBoundsPreferenceKey: PreferenceKey {
    struct Item {
        let bounds: Anchor<CGRect>
    }
    
    static var defaultValue: [Item] = []
    
    static func reduce(value: inout [Item], nextValue: () -> [Item]) {
        value.append(contentsOf: nextValue())
    }
}


struct FooterBoundsPreferenceKey: PreferenceKey {
    struct Item {
        let bounds: Anchor<CGRect>
    }
    
    static var defaultValue: [Item] = []
    
    static func reduce(value: inout [Item], nextValue: () -> [Item]) {
        value.append(contentsOf: nextValue())
    }
}

//  MARK: - Environment
struct HeaderRefreshDataKey: EnvironmentKey {
    static var defaultValue: RefreshData = .init()
}

extension EnvironmentValues {
    var headerRefreshData: RefreshData {
        get { self[HeaderRefreshDataKey.self] }
        set { self[HeaderRefreshDataKey.self] = newValue}
    }
}

struct FooterRefreshDataKey: EnvironmentKey {
    static var defaultValue: RefreshData = .init()
}

extension EnvironmentValues {
    var footerRefreshData: RefreshData {
        get { self[FooterRefreshDataKey.self] }
        set { self[FooterRefreshDataKey.self] = newValue}
    }
}

//  MARK: - Refresh State Data

enum RefreshState: Int {
    case invaild
    case stopped
    case triggered
    case loading
}

struct RefreshData {
    var thresold: CGFloat = 0
    var progress: Double = 0
    var refreshState: RefreshState = .invaild
}
