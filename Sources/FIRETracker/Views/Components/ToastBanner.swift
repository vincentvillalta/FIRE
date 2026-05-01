import SwiftUI

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
    let systemImage: String
}

struct ToastBanner: View {
    let toast: ToastMessage

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: toast.systemImage)
                .font(.headline)
                .foregroundStyle(AppDesign.negative)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 3) {
                Text(toast.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text(toast.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(4)
            }

            Spacer(minLength: 8)
        }
        .padding(14)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.cardRadius, style: .continuous)
                .stroke(AppDesign.border, lineWidth: 0.5)
        }
        .shadow(color: .black.opacity(0.18), radius: 18, y: 8)
        .accessibilityElement(children: .combine)
    }
}

