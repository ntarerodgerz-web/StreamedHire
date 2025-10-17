import SwiftUI
import Combine

/// Auto-advancing pager for any items.
/// Usage:
///   AutoPagingTabView(items: array, interval: 4) { item in
///       MyCard(item: item)
///   }
struct AutoPagingTabView<Item, Content: View>: View {
    let items: [Item]
    let interval: TimeInterval
    let content: (Item) -> Content

    @State private var currentIndex = 0
    @State private var isActive = true
    private var timer: Publishers.Autoconnect<Timer.TimerPublisher>

    init(items: [Item], interval: TimeInterval = 4, @ViewBuilder content: @escaping (Item) -> Content) {
        self.items = items
        self.interval = interval
        self.content = content
        self.timer = Timer.publish(every: interval, on: .main, in: .common).autoconnect()
    }

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(items.indices, id: \.self) { i in
                content(items[i]).tag(i)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .onReceive(timer) { _ in
            guard isActive, items.count > 1 else { return }
            withAnimation(.easeInOut) { currentIndex = (currentIndex + 1) % items.count }
        }
        .onAppear { isActive = true }
        .onDisappear { isActive = false }
    }
}
#Preview {
    LandingView()
}
