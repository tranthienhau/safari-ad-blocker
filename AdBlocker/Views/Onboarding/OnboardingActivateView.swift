import SwiftUI

struct OnboardingActivateView: View {
    let onFinish: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 60))
                .foregroundStyle(.green)

            Text("Activate in Safari")
                .font(.largeTitle.bold())

            SafariActivationGuideView()
                .padding(.horizontal, 24)

            Spacer()

            Button(action: onFinish) {
                Text("I've Enabled It - Let's Go!")
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
}
