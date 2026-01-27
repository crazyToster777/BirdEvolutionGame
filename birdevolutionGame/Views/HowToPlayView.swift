//
//  HowToPlayView.swift
//  Bird Evolution Puzzle Game
//
//  Created by Dany on 18/08/2025.
//

import SwiftUI

struct HowToPlayView: View {
    let tileSize: CGFloat
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(["2", "4", "8", "16", "32", "64", "128", "256", "512", "1024", "2048", "4096", "8192", "16384"].enumerated()), id: \.offset) { index, tile in
                    Image(tile)
                        .resizable()
                        .scaledToFit()
                        .frame(width: tileSize, height: tileSize)
                        .cornerRadius(tileSize * 0.12) // масштабируем аккуратно

                    
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
}

//#Preview {
//    HowToPlayView()
//        .padding()
//        .background(Color(.systemGroupedBackground))
//}
