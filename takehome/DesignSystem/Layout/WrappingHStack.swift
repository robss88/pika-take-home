import SwiftUI

/// Flow layout that wraps its children to the next line when they exceed the
/// proposed width. Each line is horizontally centered. Built on SwiftUI's
/// `Layout` protocol (iOS 16+); generic over any `RandomAccessCollection` of
/// `Hashable` elements so callers can flow strings, indices, or domain types.
struct WrappingHStack<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Hashable {
    let data: [Data.Element]
    let spacing: CGFloat
    let lineSpacing: CGFloat
    let content: (Data.Element) -> Content

    init(
        _ data: Data,
        spacing: CGFloat = Spacing.sm,
        lineSpacing: CGFloat = Spacing.sm,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.data = Array(data)
        self.spacing = spacing
        self.lineSpacing = lineSpacing
        self.content = content
    }

    var body: some View {
        FlowLayout(horizontalSpacing: spacing, verticalSpacing: lineSpacing) {
            ForEach(data, id: \.self) { item in
                content(item)
            }
        }
    }
}

private struct FlowLayout: Layout {
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalHeight: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if lineWidth + size.width > maxWidth {
                totalHeight += lineHeight + verticalSpacing
                lineWidth = size.width + horizontalSpacing
                lineHeight = size.height
            } else {
                lineWidth += size.width + horizontalSpacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        totalHeight += lineHeight
        return CGSize(width: maxWidth.isFinite ? maxWidth : lineWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        let maxWidth = bounds.width
        var x: CGFloat = 0
        var y: CGFloat = 0
        var lineHeight: CGFloat = 0
        // Collect indices per line first so each line can be centered after
        // its full width is known.
        var lines: [[(index: Int, size: CGSize)]] = [[]]
        for index in subviews.indices {
            let size = subviews[index].sizeThatFits(.unspecified)
            let lineWidth = lines[lines.count - 1].reduce(0) { $0 + $1.size.width + horizontalSpacing }
            if lineWidth + size.width > maxWidth, !lines[lines.count - 1].isEmpty {
                lines.append([])
            }
            lines[lines.count - 1].append((index, size))
        }
        for line in lines {
            let totalWidth = line.reduce(0) { $0 + $1.size.width } + CGFloat(max(0, line.count - 1)) * horizontalSpacing
            x = bounds.minX + (maxWidth - totalWidth) / 2
            lineHeight = line.map(\.size.height).max() ?? 0
            for entry in line {
                subviews[entry.index].place(
                    at: CGPoint(x: x, y: bounds.minY + y),
                    proposal: ProposedViewSize(entry.size)
                )
                x += entry.size.width + horizontalSpacing
            }
            y += lineHeight + verticalSpacing
        }
    }
}
