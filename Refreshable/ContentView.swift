//
//  ContentView.swift
//  Refreshable
//
//  Created by 风起兮 on 2021/7/17.
//

import SwiftUI

struct ContentView: View {
    
    @State private var items: [Item] = []
    
    @State private var headerRefreshing: Bool = false
    @State private var footerRefreshing: Bool = false
    
    var body: some View {
        NavigationView {
            pullToRefreshScrollBody
                .navigationTitle("Refresh Demo")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear(perform: loadData)
        }
    }
    
    var scrollBody: some View {
        ScrollView {
            Button(action: reloadData) {
                Text("Refresh Data")
            }
            ItemList(items: items)
            Button(action: loadMoreData) {
                Text("Load More Data")
            }
        }
        .onAppear(perform: loadData)
    }
    
    var pullToRefreshScrollBody: some View {
        headerFooterRefresh
    }
    
    var headerReresh: some View {
        ScrollView {
            PullToRefreshView(header: RefreshDefaultHeader()){
                ItemList(items: items)
            }
        }
        .addPullRefresh(isHeaderRefreshing: $headerRefreshing, onHeaderRefresh: reloadData)
    }
    
    
    var footerReresh: some View {
        ScrollView {
            PullToRefreshView(footer: RefreshDefaultFooter()){
                ItemList(items: items)
            }
        }
        .addPullRefresh(isFooterRefreshing: $footerRefreshing, onFooterRefresh: loadMoreData)
    }
    
    var headerFooterRefresh: some View {
        ScrollView {
            PullToRefreshView {
                ItemList(items: items)
            }
        }
        .addPullRefresh(isHeaderRefreshing: $headerRefreshing, onHeaderRefresh: reloadData, isFooterRefreshing: $footerRefreshing, onFooterRefresh: loadMoreData)
    }
    
    private func loadData() {
        var tempItems: [Item] = []
        for index in 0..<10 {
            let item = Item(name: "Item \(index)", desc: "Description \(index)")
            tempItems.append(item)
        }
        self.items = tempItems
    }
    
    private func reloadData() {
        print("begin refresh data ... \(headerRefreshing)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            loadData()
            headerRefreshing = false
            print("end refresh data ... \(headerRefreshing)")
        }
    }
    
    private func loadMoreData() {
        print("begin load more data ... \(footerRefreshing)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let startIndex = items.count
            for index in 0..<10 {
                let finalIndex = startIndex + index
                let item = Item(name: "Item \(finalIndex)", desc: "Description \(finalIndex)")
                self.items.append(item)
            }
            footerRefreshing = false
            print("end load more data ... \(footerRefreshing)")
        }
    }
}


struct ItemList: View {
    let items: [Item]
    
    var body: some View {
        ForEach(items, id: \.id) { item in
            itemRow(item)
            Divider()
        }
    }
    
    private func itemRow(_ item: Item) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Color.gray
                .frame(width: 100, height: 100)
                .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("\(item.name)")
                    .font(.title)
                Text("\(item.desc)")
                    .font(.caption)
            }
          
            Spacer()
        }
        .padding()
    }
}

struct Item: Identifiable {
    let id = UUID()
    let name: String
    let desc: String
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}
