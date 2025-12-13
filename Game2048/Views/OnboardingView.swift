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
                
                PowerUpsPage()
                    .tag(3)
                
                EnergyPage()
                    .tag(4)
                
                ReadyPage(onStart: {
                    TutorialManager.shared.markOnboardingComplete()
                    isPresented = false
                })
                .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

// MARK: - Energy Page
struct EnergyPage: View {
    var body: some View {
        VStack(spacing: 30 * DeviceInfo.paddingMultiplier) {
            Image(systemName: "bolt.batteryblock.fill")
                .font(.system(size: 80 * DeviceInfo.fontMultiplier))
                .foregroundColor(.yellow)
                .symbolEffect(.pulse)
            
            Text("Survival Mode")
                .font(.system(size: 36 * DeviceInfo.fontMultiplier, weight: .bold))
            
            VStack(alignment: .leading, spacing: 25 * DeviceInfo.paddingMultiplier) {
                
                EnergyInfoRow(
                    icon: "figure.walk",
                    color: .red,
                    title: "Moves Cost Energy",
                    description: "Every swipe drains your energy. Don't waste moves!"
                )
                
                EnergyInfoRow(
                    icon: "battery.100.bolt",
                    color: .green,
                    title: "Merges Restore It",
                    description: "Merge tiles to recharge. Combos give huge bonuses."
                )
                
                EnergyInfoRow(
                    icon: "skull",
                    color: .primary,
                    title: "Don't Hit Zero",
                    description: "If energy reaches 0%, it's Game Over. Stay charged!"
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}

struct EnergyInfoRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 30 * DeviceInfo.paddingMultiplier) {
            Spacer()
            
            Text("🎮")
                .font(.system(size: 100 * DeviceInfo.fontMultiplier))
            
            Text("Welcome to")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Bird Evolution")
                .font(.system(size: 40 * DeviceInfo.fontMultiplier, weight: .bold))
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
        VStack(spacing: 30 * DeviceInfo.paddingMultiplier) {
            Text("How to Play")
                .font(.system(size: 36 * DeviceInfo.fontMultiplier, weight: .bold))
            
            VStack(alignment: .leading, spacing: 20 * DeviceInfo.paddingMultiplier) {
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
                    title: "Reach the Top",
                    description: "Keep merging to create the ultimate bird and win!"
                )
            }
            .padding()
            
            // Tile progression
            VStack(spacing: 12 * DeviceInfo.paddingMultiplier) {
                Text("Evolution Path")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8 * DeviceInfo.spacingMultiplier) {
                        ForEach(Array(["2", "4", "8", "16", "32", "64", "128", "256", "512", "1024", "2048", "4096", "8192", "16384"].enumerated()), id: \.offset) { index, tile in
                            Image(tile)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50 * DeviceInfo.sizeMultiplier, height: 50 * DeviceInfo.sizeMultiplier)
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
        VStack(spacing: 30 * DeviceInfo.paddingMultiplier) {
            Text("Features")
                .font(.system(size: 36 * DeviceInfo.fontMultiplier, weight: .bold))
            
            VStack(alignment: .leading, spacing: 20 * DeviceInfo.paddingMultiplier) {
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

// MARK: - Power-Ups Page
struct PowerUpsPage: View {
    var body: some View {
        VStack(spacing: 30 * DeviceInfo.paddingMultiplier) {
            Text("Power-Ups & Combos")
                .font(.system(size: 36 * DeviceInfo.fontMultiplier, weight: .bold))
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20 * DeviceInfo.paddingMultiplier) {
                    Text("💥 Power-Ups")
                        .font(.title2.bold())
                        .padding(.top)
                    
                    PowerUpItem(
                        emoji: "💣",
                        title: "Bomb",
                        description: "Clears surrounding tiles"
                    )
                    
                    PowerUpItem(
                        emoji: "🌈",
                        title: "Rainbow",
                        description: "Merges with any tile"
                    )
                    
                    PowerUpItem(
                        emoji: "✖️2",
                        title: "Multiplier",
                        description: "Doubles next merge value"
                    )
                    
                    PowerUpItem(
                        emoji: "🔀",
                        title: "Shuffle",
                        description: "Randomizes the board"
                    )
                    
                    Divider()
                        .padding(.vertical)
                    
                    Text("🔥 Combo System")
                        .font(.title2.bold())
                    
                    Text("Make multiple merges in one move to earn combo bonuses and increase power-up chances!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 15) {
                        ComboLevelBadge(level: "2x", color: .blue, bonus: "+50")
                        ComboLevelBadge(level: "3x", color: .purple, bonus: "+150")
                        ComboLevelBadge(level: "4x+", color: .orange, bonus: "+500")
                    }
                }
                .padding()
            }
            
            Spacer()
        }
        .padding()
    }
}

struct PowerUpItem: View {
    let emoji: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Text(emoji)
                .font(.system(size: 40))
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

struct ComboLevelBadge: View {
    let level: String
    let color: Color
    let bonus: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(level)
                .font(.caption.bold())
                .foregroundColor(.white)
            Text(bonus)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color)
        .cornerRadius(8)
    }
}

// MARK: - Ready Page
struct ReadyPage: View {
    let onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 40 * DeviceInfo.paddingMultiplier) {
            Spacer()
            
            Text("🎉")
                .font(.system(size: 80 * DeviceInfo.fontMultiplier))
            
            Text("You're Ready!")
                .font(.system(size: 40 * DeviceInfo.fontMultiplier, weight: .bold))
            
            Text("Time to start your evolution journey")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onStart) {
                Text("Start Evolution")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 40 * DeviceInfo.paddingMultiplier)
                    .padding(.vertical, 16 * DeviceInfo.paddingMultiplier)
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
