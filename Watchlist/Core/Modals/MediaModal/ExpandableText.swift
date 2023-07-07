//
//  ExpandableText.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 7/7/23.
//

import SwiftUI

struct ExpandableText: View {
    let text: String
    let lineLimit: Int

    @State private var isExpanded: Bool = false
    @State private var isTruncated: Bool?
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !isExpanded {
                Text(text)
                    .lineLimit(lineLimit)
                    .background(calculateTruncation(text: text))
                    .multilineTextAlignment(.leading)
                    .onTapGesture {
                        withAnimation(.interactiveSpring(response: 0.3)) {
                            isExpanded = true
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(.clear).matchedGeometryEffect(id: "text", in: animation))

                if isTruncated == true {
                    button
                }
            } else {
                Text(text)
                    .background(calculateTruncation(text: text))
                    .multilineTextAlignment(.leading)
                    .onTapGesture {
                        withAnimation(.interactiveSpring(response: 0.3)) {
                            isExpanded.toggle()
                        }
                    }
                    .background(RoundedRectangle(cornerRadius: 10).fill(.clear).matchedGeometryEffect(id: "text", in: animation))

                if isTruncated == true {
                    button
                }
            }
        }
        .multilineTextAlignment(.leading)
        // Re-calculate isTruncated for the new text
        .onChange(of: text, perform: { _ in isTruncated = nil })
    }

    func calculateTruncation(text: String) -> some View {
        // Select the view that fits in the background of the line-limited text.
        ViewThatFits(in: .vertical) {
            Text(text)
                .hidden()
                .onAppear {
                    // If the whole text fits, then isTruncated is set to false and no button is shown.
                    guard isTruncated == nil else { return }
                    isTruncated = false
                }
            Color.clear
                .hidden()
                .onAppear {
                    // If the whole text does not fit, Color.clear is selected,
                    // isTruncated is set to true and button is shown.
                    guard isTruncated == nil else { return }
                    isTruncated = true
                }
        }
    }

    var button: some View {
        Button(isExpanded ? "Less" : "More") {
            withAnimation(.interactiveSpring()) {
                isExpanded.toggle()
            }
        }
        .foregroundColor(Color.theme.red)
        .font(.body)
        .fontWeight(.semibold)
        .buttonStyle(.plain)
    }
}

struct ExpandableText_Previews: PreviewProvider {
    static var previews: some View {
        ExpandableText(text: "This is a long text that should be truncated", lineLimit: 2)
    }
}
