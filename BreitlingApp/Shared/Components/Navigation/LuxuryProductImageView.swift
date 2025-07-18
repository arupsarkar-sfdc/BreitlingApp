//
//  LuxuryProductImageView.swift
//  BreitlingApp
//
//  Created by Arup Sarkar (TA) on 7/11/25.
//

// Add this to your Shared/Components/ folder:

import SwiftUI

struct LuxuryProductImageView2: View {
    let imageURL: String
    let aspectRatio: CGFloat
    let cornerRadius: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: imageURL)) { image in
            image
                .resizable()
                .aspectRatio(aspectRatio, contentMode: .fit)
        } placeholder: {
            RectangleShimmer()
                .aspectRatio(aspectRatio, contentMode: .fit)
        }
        .cornerRadius(cornerRadius)
    }
}

struct RectangleShimmer: View {
    @State private var isAnimating = false
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [
                        BreitlingColors.lightGray.opacity(0.3),
                        BreitlingColors.lightGray.opacity(0.1),
                        BreitlingColors.lightGray.opacity(0.3)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(x: isAnimating ? 200 : -200)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}
