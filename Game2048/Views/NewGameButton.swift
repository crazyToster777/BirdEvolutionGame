
import SwiftUI


struct NewGameButton: View {
    let action: VoidCallback
    
    var body: some View {
        Button("Start Evolution", action: action)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(buttonGradient)
            .foregroundColor(.white)
            .cornerRadius(12)
            .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
    }
    
    private var buttonGradient: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.3, green: 0.7, blue: 1.0),
                Color(red: 0.2, green: 0.6, blue: 0.9)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
