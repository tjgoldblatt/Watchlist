//
//  ProviderView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/11/23.
//

import NukeUI
import SafariServices
import SwiftUI

struct ProviderView: View {
    @State var provider: Provider
    @State var providerType: String
    @State var link: String

    @State private var showSafari: Bool = false

    var body: some View {
        Button {
            showSafari.toggle()
        } label: {
            HStack {
                if let path = provider.logoPath {
                    LazyImage(url: URL(string: TMDBConstants.imageURL + path)) { state in
                        if let image = state.image {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 40)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.3), radius: 5)
                        } else {
                            ProgressView()
                                .frame(height: 20)
                        }
                    }
                }

                VStack(alignment: .leading) {
                    if let name = provider.providerName {
                        Text(name.truncated(length: 10))
                            .font(.subheadline)
                            .foregroundColor(Color.theme.text)
                            .fontWeight(.medium)
                    }

                    Text(providerType.uppercased())
                        .font(.caption2)
                        .foregroundColor(Color.theme.text)
                        .fontWeight(.light)
                }
                .lineLimit(1)
                .truncationMode(.tail)
            }
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(Color.theme.secondary)
            .cornerRadius(10)
        }
        .sheet(isPresented: $showSafari) {
            if let url = URL(string: link) {
                SFSafariViewWrapper(url: url).ignoresSafeArea(edges: .bottom)
            }
        }
    }
}

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL
    func makeUIViewController(context _: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(
        _: SFSafariViewController,
        context _: UIViewControllerRepresentableContext<SFSafariViewWrapper>) { }
}

extension String {
    func truncated(length: Int, trailing: String = "…") -> String {
        let maxLength = length - trailing.count
        guard maxLength > 0, !isEmpty, count > length else {
            return self
        }
        return prefix(maxLength) + trailing
    }
}

struct ProviderView_Previews: PreviewProvider {
    static var provider = Provider(
        logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
        providerID: 8,
        providerName: "Cinemax Amazon Channel",
        displayPriority: 0)

    static var providers: [Provider] = {
        var arr: [Provider] = []
        for i in 0 ... 10 {
            arr
                .append(Provider(
                    logoPath: "/t2yyOv40HZeVlLjYsCsPHnWLk4W.jpg",
                    providerID: 8,
                    providerName: "Netflix",
                    displayPriority: 0))
        }
        return arr
    }()

    static var previews: some View {
        ProviderView(provider: provider, providerType: "Stream", link: "")
//        ProviderView(providers: providers, providerType: "stream", link: "")
                .previewLayout(.sizeThatFits)
    }
}
