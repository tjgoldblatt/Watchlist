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
//    @State var providers: [Provider]
    @State var providerType: String
    @State var link: String

    @State private var showSafari: Bool = false

//    var body: some View {
//        VStack {
//            HStack {
//                Text(providerType.capitalized)
//                    .font(.headline)
//                    .fontWeight(.medium)
//
//                Capsule()
//                    .frame(height: 2)
//                    .foregroundColor(Color.theme.secondary)
//            }
//            .frame(maxWidth: .infinity, alignment: .leading)
//
//            ScrollView(.horizontal, showsIndicators: false) {
//                HStack {
//                    ForEach(providers, id: \.self) { provider in
//                        if let path = provider.logoPath {
//                            LazyImage(url: URL(string: "https://image.tmdb.org/t/p/original\(path)")) { state in
//                                if let image = state.image {
//                                    image
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 40, height: 40)
//                                        .cornerRadius(10)
//                                        .shadow(color: Color.black.opacity(0.3), radius: 5)
//                                        .frame(maxWidth: .infinity, alignment: .leading)
//                                        .padding(.trailing)
//                                        .onTapGesture {
//                                            showSafari.toggle()
//                                        }
//                                        .sheet(isPresented: $showSafari) {
//                                            if let url = URL(string: link) {
//                                                SFSafariViewWrapper(url: url).ignoresSafeArea(edges: .bottom)
//                                            }
//                                        }
//                                } else {
//                                    ProgressView()
//                                        .frame(width: 40, height: 40)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }

    var body: some View {
        HStack {
            if let path = provider.logoPath {
                LazyImage(url: URL(string: "https://image.tmdb.org/t/p/original\(path)")) { state in
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
        .onTapGesture {
            showSafari.toggle()
        }
        .sheet(isPresented: $showSafari) {
            if let url = URL(string: link) {
                SFSafariViewWrapper(url: url).ignoresSafeArea(edges: .bottom)
            }
        }
    }

//    var body: some View {
//        VStack(spacing: 0) {
//            ZStack {
//                Rectangle()
//                    .foregroundColor(Color.theme.secondary)
//                    .frame(height: 100)
//                if let path = provider.logoPath {
//                    LazyImage(url: URL(string: "https://image.tmdb.org/t/p/original\(path)")) { state in
//                        if let image = state.image {
//                            image
//                                .resizable()
//                                .scaledToFit()
//                                .frame(height: 50)
//                                .cornerRadius(10)
//                                .shadow(color: Color.black.opacity(0.3), radius: 5)
//                        } else {
//                            ProgressView()
//                                .frame(height: 50)
//                        }
//                    }
//                }
//            }
//
//            ZStack {
//                Rectangle()
//                    .foregroundColor(Color.theme.secondaryBackground)
//                .frame(height: 50)
//
//                VStack {
//                    if let name = provider.providerName {
//                        Text(name)
//                            .font(.headline)
//                            .foregroundColor(Color.theme.text)
//                            .fontWeight(.semibold)
//                    }
//
//                    Text(providerType.uppercased())
//                        .font(.subheadline)
//                        .foregroundColor(Color.theme.text)
//                        .fontWeight(.light)
//                }
//            }
//        }
//        .frame(width: 100)
//        .cornerRadius(10)
//    }
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
