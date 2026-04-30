import Foundation
import SwiftUI

extension Binding where Value == Decimal {
    var doubleValue: Binding<Double> {
        Binding<Double>(
            get: { wrappedValue.doubleValue },
            set: { wrappedValue = Decimal($0) }
        )
    }
}

extension Binding where Value == Int {
    var doubleValue: Binding<Double> {
        Binding<Double>(
            get: { Double(wrappedValue) },
            set: { wrappedValue = Int($0.rounded()) }
        )
    }
}
