import SwiftUI

struct SafariActivationGuideView: View {
    private let steps = [
        "Open the Settings app",
        "Scroll down and tap Safari",
        "Tap Extensions",
        "Find AdBlocker and toggle it on",
        "Grant permission for all websites"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(.blue)
                        .clipShape(Circle())

                    Text(step)
                        .font(.body)
                }
            }
        }
        .padding()
        .background(.quaternary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
