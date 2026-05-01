import SwiftUI

struct ProjectionDetailView: View {
    let currentValue: Decimal
    let annualGrowth: Decimal
    let points: [ProjectionPoint]

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    SectionLabel(title: "Projected value")
                    Text(points.last?.value ?? .zero, format: .portfolioCurrency)
                        .font(.system(.title, design: .rounded, weight: .bold))
                        .monospacedDigit()

                    ProjectionChart(points: points)
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
                .listRowBackground(AppDesign.surface)
            }

            Section("Assumptions") {
                ValueRow(title: "Starting value", value: currentValue.formatted(.portfolioCurrency))
                ValueRow(title: "Annual growth", value: annualGrowth.formatted(.portfolioPercent))
                ValueRow(title: "Projection period", value: "\(points.last?.year ?? 0) years")
            }

            Section("Milestones") {
                milestoneRow(year: 10)
                milestoneRow(year: 20)
                milestoneRow(year: 30)
            }

            Section("Year by year") {
                ForEach(points) { point in
                    ValueRow(title: "Year \(point.year)", value: point.value.formatted(.portfolioCurrency))
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppDesign.background)
        .navigationTitle("Projection")
        .navigationBarTitleDisplayMode(.large)
    }

    private func milestoneRow(year: Int) -> some View {
        let value = points.first { $0.year == year }?.value ?? 0
        return ValueRow(title: "Year \(year)", value: value.formatted(.portfolioCurrency))
    }
}
