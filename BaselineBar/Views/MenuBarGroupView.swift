import SwiftUI

struct MenuBarGroupView: View {
    @EnvironmentObject private var model: AppModel
    let visibility: MenuBarVisibility

    private var items: [MenuBarItem] {
        model.menuBarItems
            .filter { $0.visibility == visibility }
            .sorted { $0.order < $1.order }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(visibility.rawValue)
                    .font(.headline)
                Spacer()
                Text("\(items.count)")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            if items.isEmpty {
                Text("Drop items here")
                    .foregroundStyle(.tertiary)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                ForEach(items) { item in
                    MenuBarItemRow(item: item)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 14))
        .dropDestination(for: String.self) { droppedIDs, _ in
            guard let raw = droppedIDs.first, let id = UUID(uuidString: raw) else { return false }
            model.moveItem(id, to: visibility)
            return true
        }
    }
}

private struct MenuBarItemRow: View {
    @EnvironmentObject private var model: AppModel
    let item: MenuBarItem

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "line.3.horizontal")
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .lineLimit(1)
                if !item.canBeManaged {
                    Text("Observed only")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Menu {
                ForEach(MenuBarVisibility.allCases) { visibility in
                    Button(visibility.rawValue) {
                        model.moveItem(item.id, to: visibility)
                    }
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .menuStyle(.borderlessButton)
        }
        .padding(10)
        .background(.background, in: RoundedRectangle(cornerRadius: 10))
        .draggable(item.id.uuidString)
    }
}
