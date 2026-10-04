import SwiftUI

struct MenuBarLayoutView: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            menuBarPreview
            layoutColumns
        }
        .padding(28)
        .task { await model.refreshMenuBarItems() }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Menu Bar")
                    .font(.largeTitle.bold())
                Text("Arrange what stays visible and what BaselineBar should keep out of the way.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                Task { await model.refreshMenuBarItems() }
            } label: {
                Label("Refresh", systemImage: "arrow.clockwise")
            }
        }
    }

    private var menuBarPreview: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Desired layout")
                .font(.headline)

            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    ForEach(model.menuBarItems.filter { $0.visibility == .visible }.sorted { $0.order < $1.order }) { item in
                        Label(item.title, systemImage: "circle.fill")
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(.quaternary, in: Capsule())
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var layoutColumns: some View {
        HStack(alignment: .top, spacing: 14) {
            ForEach(MenuBarVisibility.allCases) { visibility in
                MenuBarGroupView(visibility: visibility)
                    .environmentObject(model)
            }
        }
    }
}
