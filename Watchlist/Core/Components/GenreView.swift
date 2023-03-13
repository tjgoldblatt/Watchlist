//
//  GenreView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/11/23.
//

import SwiftUI
import TMDb

/// Creates a Genre View
///
/// Parameters
/// - genreName: String
struct GenreView: View {
    @State var genreName: String
    
    @State var size: CGFloat = 10
    
    var body: some View {
        Text(genreName)
            .foregroundColor(Color.theme.genreText)
            .font(.system(size: size, design: .default))
            .padding(.vertical, 3)
            .padding(.horizontal, 10)
            .background {
                Capsule()
                    .fill(Color.theme.red)
            }
            
    }
}

struct GenreView_Previews: PreviewProvider {
    static var previews: some View {
        GenreView(genreName: "Science Fiction")
            .previewLayout(.sizeThatFits)
    }
}
