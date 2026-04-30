import Charts
import SwiftUI

struct ProjectionChart: View {
    let points: [ProjectionPoint]

    var body: some View {
        Chart(points) { point in
            AreaMark(
                x: .value("Year", point.year),
                y: .value("Value", point.value.doubleValue)
            )
            .foregroundStyle(.linearGradient(colors: [.teal.opacity(0.42), .teal.opacity(0.08)], startPoint: .top, endPoint: .bottom))

            LineMark(
                x: .value("Year", point.year),
                y: .value("Value", point.value.doubleValue)
            )
            .foregroundStyle(.teal)
            .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 220)
        .accessibilityLabel("Future portfolio projection chart")
    }
}
