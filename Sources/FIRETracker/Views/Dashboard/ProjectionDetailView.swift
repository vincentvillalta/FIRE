import SwiftUI

struct ProjectionDetailView: View {
    let currentValue: Decimal
    let annualGrowth: Decimal
    let points: [ProjectionPoint]

    var body: some View {
        List {
            Section {
                ProjectionChart(points: points)
                    .listRowInsets(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 0))
            }

            Section("Assumptions") {
                LabeledContent("Starting value", value: currentValue.formatted(.portfolioCurrency))
                LabeledContent("Annual growth", value: annualGrowth.formatted(.portfolioPercent))
                LabeledContent("Projection period", value: "\(points.last?.year ?? 0) years")
            }

            Section("Milestones") {
                milestoneRow(year: 10)
                milestoneRow(year: 20)
                milestoneRow(year: 30)
            }

            Section("Year by year") {
                ForEach(points) { point in
                    LabeledContent("Year \(point.year)", value: point.value.formatted(.portfolioCurrency))
                }
            }
        }
        .navigationTitle("Projection")
        .navigationBarTitleDisplayMode(.large)
    }

    private func milestoneRow(year: Int) -> some View {
        let value = points.first { $0.year == year }?.value ?? 0
        return LabeledContent("Year \(year)", value: value.formatted(.portfolioCurrency))
    }
}
