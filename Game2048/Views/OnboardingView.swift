import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage = 0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                WelcomePage()
                    .tag(0)
                
                HowToPlayPage()
                    .tag(1)
                
                FeaturesPage()
                    .tag(2)
                
                ReadyPage(onStart: {
                    TutorialManager.shared.markOnboardingComplete()
                    isPresented = false
                })
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("🎮")
                .font(.system(size: 100))
            
            Text("Welcome to")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("2048 Evolution")
                .font(.system(size: 40, weight: .bold))
                .multilineTextAlignment(.center)
            
            Text("Merge birds to create stronger ones!")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Text("Swipe to continue →")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.bottom, 50)
        }
        .padding()
    }
}

// MARK: - How to Play Page
struct HowToPlayPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("How to Play")
                .font(.system(size: 36, weight: .bold))
            
            VStack(alignment: .leading, spacing: 20) {
                HowToPlayItem(
                    icon: "hand.draw",
                    title: "Swipe to Move",
                    description: "Swipe in any direction to move all tiles"
                )
                
                HowToPlayItem(
                    icon: "arrow.triangle.merge",
                    title: "Merge Same Birds",
                    description: "When two tiles with the same bird touch, they merge into one"
                )
                
                HowToPlayItem(
                    icon: "trophy.fill",
                    title: "Reach 2048",
                    description: "Keep merging to reach the 2048 tile and win!"
                )
            }
            .padding()
            
            // Tile progression
            VStack(spacing: 12) {
                Text("Evolution Path")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(["2", "4", "8", "16", "32", "64", "128", "256", "512", "1024", "2048", "4096", "8192", "16384"].enumerated()), id: \.offset) { index, tile in
                            Image(tile)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .cornerRadius(6)
                            
                            if index < 13 {
                                Image(systemName: "arrow.right")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }

            
            Spacer()
        }
        .padding()
    }
}

struct HowToPlayItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Features Page
struct FeaturesPage: View {
    var body: some View {
        VStack(spacing: 30) {
            Text("Features")
                .font(.system(size: 36, weight: .bold))
            
            VStack(alignment: .leading, spacing: 20) {
                FeatureItem(
                    icon: "arrow.uturn.backward.circle.fill",
                    title: "Undo Moves",
                    description: "Made a mistake? Use undo (3 per game)"
                )
                
                FeatureItem(
                    icon: "square.grid.3x3",
                    title: "Grid Sizes",
                    description: "Choose 4×4, 5×5, or 6×6 for different challenges"
                )
                
                FeatureItem(
                    icon: "calendar",
                    title: "Track Progress",
                    description: "View your game history in the calendar"
                )
                
                FeatureItem(
                    icon: "speaker.wave.2.fill",
                    title: "Background Music",
                    description: "Enjoy music (respects silent mode)"
                )
            }
            .padding()
            
            Spacer()
        }
        .padding()
    }
}

struct FeatureItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 25))
                .foregroundColor(.green)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Ready Page
struct ReadyPage: View {
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Text("🎉")
                .font(.system(size: 80))
            
            Text("You're Ready!")
                .font(.system(size: 40, weight: .bold))
            
            Text("Time to start your evolution journey")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onStart) {
                Text("Start Evolution")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView(isPresented: .constant(true))
}
