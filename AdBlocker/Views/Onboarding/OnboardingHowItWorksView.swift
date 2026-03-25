import SwiftUI

struct OnboardingHowItWorksView: View {
    let onNext: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "gearshape.2")
                .font(.system(size: 60))
                .foregroundStyle(.blue)

            Text("How It Works")
                .font(.largeTitle.bold())

            VStack(alignment: .leading, spacing: 20) {
                featureRow(
                    icon: "safari",
                    title: "Safari Content Blocker",
                    description: "Uses Apple's native API for maximum performance and privacy."
                )

                featureRow(
                    icon: "bolt.shield",
                    title: "On-Device Processing",
                    description: "All filtering happens locally. No data leaves your device."
                )

                featureRow(
                    icon: "slider.horizontal.3",
                    title: "Customizable Filters",
                    description: "Choose which categories to block: ads, trackers, social, or annoyances."
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: onNext) {
                Text("Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
    }

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
