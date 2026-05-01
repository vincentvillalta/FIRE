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
            .foregroundStyle(.linearGradient(colors: [AppDesign.accent.opacity(0.24), AppDesign.accent.opacity(0.02)], startPoint: .top, endPoint: .bottom))

            LineMark(
                x: .value("Year", point.year),
                y: .value("Value", point.value.doubleValue)
            )
            .foregroundStyle(AppDesign.accent)
            .lineStyle(.init(lineWidth: 2, lineCap: .round, lineJoin: .round))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 5))
        }
        .frame(height: 220)
        .accessibilityLabel("Future portfolio projection chart")
    }
}
