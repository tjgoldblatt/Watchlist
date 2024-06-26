//
//  FriendWatchlistView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/3/23.
//

import SwiftUI

struct FriendWatchlistView: View {
    @StateObject private var vm: FriendWatchlistViewModel
    @FocusState private var isFocused: Bool
    @Namespace private var animation

    var options: [Tab] = [.movies, .tvShows]
    @State private var selectedOption: Tab = .movies
    @State private var selectedSorting: SortingOptions = .personalRating

    @State private var filterText: String = ""

    init(userId: String, forPreview: Bool = false) {
        let vm = forPreview ? FriendWatchlistViewModel(forPreview: true) : FriendWatchlistViewModel(userId: userId)
        _vm = StateObject(wrappedValue: vm)
    }

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            VStack(spacing: 10) {
                AddFriendsFilterView(filterText: $filterText)
                    .padding(.horizontal)

                segmentController

                if !filteredMedia.isEmpty {
                    list
                } else {
                    Color.theme.background
                }
                Spacer()
            }
            .onChange(of: selectedOption) { _ in
                filterText = ""
                hideKeyboard()
            }
            .padding(.top)
            .navigationTitle(firstName + "'s Watchlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    ForEach(SortingOptions.allCases, id: \.self) { options in
                        Button {
                            withAnimation(.easeInOut) {
                                selectedSorting = options
                            }
                        } label: {
                            if selectedSorting == options {
                                Label(options.rawValue, systemImage: "checkmark")
                            } else {
                                Text(options.rawValue)
                            }
                        }
                    }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color.theme.red)
                }
            }
        }
    }

    var filteredMedia: [DBMedia] {
        var filteredMedia: [DBMedia] = []
        switch selectedOption {
            case .tvShows:
                filteredMedia = vm.tvList
            case .movies:
                filteredMedia = vm.movieList
            default:
                break
        }

        filteredMedia = filteredMedia.sorted { media1, media2 in
            switch selectedSorting {
                case .alphabetical:
                    if let title1 = media1.title, let title2 = media2.title {
                        return title1 < title2
                    } else if let name1 = media1.name, let name2 = media2.name {
                        return name1 < name2
                    } else {
                        return false
                    }
                case .imdbRating:
                    if let voteAverage1 = media1.voteAverage, let voteAverage2 = media2.voteAverage {
                        return voteAverage1 > voteAverage2
                    }
                case .personalRating:
                    return (media1.personalRating ?? 0, media1.voteAverage ?? 0) >
                        (media2.personalRating ?? 0, media2.voteAverage ?? 0)
            }
            return false
        }

        if !filterText.isEmpty {
            switch selectedOption {
                case .tvShows:
                    filteredMedia = filteredMedia.filter { $0.name?.lowercased().contains(filterText.lowercased()) ?? false }
                case .movies:
                    filteredMedia = filteredMedia.filter { $0.title?.lowercased().contains(filterText.lowercased()) ?? false }
                default:
                    break
            }
        }

        return filteredMedia
    }
}

extension FriendWatchlistView {
    var firstName: String {
        if let displayName = vm.user?.displayName {
            return displayName.components(separatedBy: " ")[0]
        } else {
            return ""
        }
    }

    var segmentController: some View {
        HStack {
            ForEach(options, id: \.self) { option in
                Text(option.rawValue)
                    .foregroundColor(selectedOption == option ? .watchlistGenreText : .watchlistText.opacity(0.8))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .frame(width: 110, height: 35)
                    .contentShape(Capsule())
                    .frame(maxWidth: .infinity)
                    .background {
                        if selectedOption == option {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.theme.red)
                                .matchedGeometryEffect(id: "ACTIVE_OPTION", in: animation)
                        }
                    }
                    .padding(3)
                    .onTapGesture {
                        if selectedOption != option {
                            withAnimation(.interactiveSpring()) {
                                AnalyticsManager.shared.logEvent(name: "FriendWatchlistView_\(option.rawValue)_Tapped")
                                selectedOption = option
                                vm.filterText = ""
                            }
                        }
                    }
            }
        }
        .frame(maxWidth: 500)
        .background(Color.theme.secondaryBackground)
        .cornerRadius(12)
        .dynamicTypeSize(.medium ... .xLarge)
        .padding(.horizontal)
    }

    private var list: some View {
        List {
            ForEach(filteredMedia) { media in
                FriendRowView(friendMedia: media, friendName: firstName)
                    .listRowBackground(Color.theme.background)
            }
        }
        .background(.clear)
        .scrollContentBackground(.hidden)
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.immediately)
    }
}

struct FriendWatchlistView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FriendWatchlistView(userId: "abc123", forPreview: true)
        }
        .environmentObject(dev.homeVM)
    }
}
