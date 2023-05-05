//
//  FriendWatchlistView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 5/3/23.
//

import SwiftUI

struct FriendWatchlistView: View {
	@State var mediaList: [DBMedia]
	
	private var movieList: [DBMedia] { mediaList.filter({ $0.mediaType == .movie }) }
	private var tvList: [DBMedia] { mediaList.filter({ $0.mediaType == .tv }) }
	
    var body: some View {
		List {
			ForEach(tvList) { list in
				RowView(media: list)
			}
		}
    }
}

extension FriendWatchlistView {
	private var list: some View {
		List {
			/// Used to scroll to top of list
//			EmptyView()
//				.id(vm.emptyViewID)
			
			ForEach(movieList) { movie in
				RowView(media: movie)
//					.allowsHitTesting(vm.editMode == .inactive)
					.listRowBackground(Color.theme.background)
			}
//			.onChange(of: homeVM.watchSelected) { _ in
//				if sortedSearchResults.count > 3 {
//					scrollProxy.scrollTo(vm.emptyViewID)
//				}
//			}
//			.listRowBackground(Color.theme.background)
//			.transition(.slide)
		}
//		.toolbar {
//			ToolbarItem(placement: .navigationBarTrailing) {
//				if !sortedSearchResults.isEmpty {
//					Button(vm.editMode == .active ? "Done" : "Edit") {
//						if vm.editMode == .active {
//							vm.editMode = .inactive
//							homeVM.editMode = .inactive
//						} else {
//							vm.editMode = .active
//							homeVM.editMode = .active
//						}
//					}
//					.foregroundColor(Color.theme.red)
//					.padding()
//					.contentShape(Rectangle())
//					.buttonStyle(.plain)
//				}
//			}
//
//			if !watchedSelectedRows.isEmpty && vm.editMode == .active {
//				ToolbarItem(placement: .navigationBarLeading) {
//					Text("Reset")
//						.font(.body)
//						.foregroundColor(Color.theme.red)
//						.padding()
//						.onTapGesture {
//							AnalyticsManager.shared.logEvent(name: "MovieTabView_ResetMedia")
//							Task {
//								for watchedSelectedRow in watchedSelectedRows {
//									try await WatchlistManager.shared.resetMedia(media: watchedSelectedRow)
//								}
//								vm.selectedRows = []
//								vm.editMode = .inactive
//								homeVM.editMode = .inactive
//							}
//						}
//				}
//			}
//		}
		.background(.clear)
		.scrollContentBackground(.hidden)
//		.environment(\.editMode, $vm.editMode)
//		.overlay(alignment: .bottomTrailing) {
//			if !vm.selectedRows.isEmpty && vm.editMode == .active {
//				Image(systemName: "trash.circle.fill")
//					.resizable()
//					.fontWeight(.bold)
//					.scaledToFit()
//					.frame(width: 50)
//					.foregroundStyle(Color.theme.genreText, Color.theme.red)
//					.padding()
//					.onTapGesture {
//						homeVM.hapticFeedback.impactOccurred()
//						vm.deleteConfirmationShowing.toggle()
//					}
//			}
//		}
//		.alert("Are you sure you'd like to delete from your Watchlist?", isPresented: $vm.deleteConfirmationShowing) {
//			Button("Delete", role: .destructive) {
//				Task {
//					for id in vm.selectedRows {
//						try await WatchlistManager.shared.deleteMediaById(mediaId: id)
//						AnalyticsManager.shared.logEvent(name: "MovieTabView_MultiDeleteMedia")
//					}
//					vm.editMode = .inactive
//					homeVM.editMode = .inactive
//				}
//			}
//			.buttonStyle(.plain)
//
//			Button("Cancel", role: .cancel) {}
//				.buttonStyle(.plain)
//		}
		.scrollIndicators(.hidden)
		.listStyle(.plain)
		.scrollDismissesKeyboard(.immediately)
	}
}

struct FriendWatchlistView_Previews: PreviewProvider {
    static var previews: some View {
		FriendWatchlistView(mediaList: dev.mediaMock)
			.environmentObject(dev.homeVM)
    }
}
