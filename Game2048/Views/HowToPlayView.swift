//
//  HowToPlayView.swift
//  2048 Classic Number Puzzle
//
//  Created by Dany on 18/08/2025.
//

import SwiftUI

struct HowToPlayView: View {
    var body: some View {
        
        let tiles = ["2","4","8","16","32","64","128","256","512","1024","2048"]

        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(0..<tiles.count, id: \.self) { i in
                    Image(tiles[i])
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    if i < tiles.count - 1 {
                        Image(systemName: "arrow.right")
                    }
                }
            }
            .padding()
        }
       
    }
}

#Preview {
    HowToPlayView()
}
