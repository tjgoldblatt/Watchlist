//
//  SearchBarView.swift
//  Watchlist
//
//  Created by TJ Goldblatt on 3/9/23.
//

import SwiftUI

struct SearchBarView: View {
    
    @Binding var searchText: String
    @Binding var currentTab: Tab
    @State var isTyping: Bool = false
    
    var queryToCall: () -> Void
    
    var textFieldString: String {
        return currentTab.searchTextLabel
    }
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(searchText.isEmpty ? Color.theme.red : Color.theme.text)
                    .imageScale(.medium)
                
                TextField(textFieldString, text: $searchText)
                    .foregroundColor(Color.theme.text)
                    .font(.system(size: 16, design: .default))
                
//                    .overlay( isTyping ?
//                              Image(systemName: "xmark.circle.fill")
//                        .padding()
//                        .offset(x: 15)
//                        .foregroundColor(Color.theme.text)
//                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
//                        .onTapGesture { searchText = "" } : nil, alignment: .trailing)
                    .overlay(
                        Image(systemName: "slider.horizontal.3")
//                            .resizable()
//                            .scaledToFit()
                            .imageScale(.large)
                            .padding()
                            .offset(x: 15)
                            .foregroundColor(searchText.isEmpty ? Color.theme.red : Color.theme.text)
                            .onTapGesture {
                                print("Tapped Filter")
                            }
                            
                        , alignment: .trailing)
                
                    .submitLabel(.search)
//                    .onSubmit {
//                        withAnimation {
//                            isTyping = false
//                        }
//                    }
                    .onChange(of: searchText, perform: { newValue in
//                        withAnimation {
//                            isTyping = true
//                        }
                        queryToCall()
                    
                    })
//                    .onTapGesture {
//                        withAnimation(.easeInOut) {
//                            isTyping = true
//                        }
//                    }
            }
            .font(.headline)
            .padding()
            .frame(height: 50)
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .background(Color.theme.secondary)
            .cornerRadius(20)
            
            
            
//            if isTyping {
//                Button(action: {
//                    hideKeyboard()
//                    searchText = ""
//                    withAnimation(.easeInOut) {
//                        isTyping = false
//                    }
//                }, label: {
//                    Image(systemName: "xmark")
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 15, height: 15)
//                        .foregroundColor(Color.theme.genreText)
//                        .background {
//                            Circle()
//                                .foregroundColor(Color.theme.red)
//                                .frame(width: 30, height: 30)
//                        }
//                        .padding(.horizontal, 5)
//                        .onTapGesture {
//                            isTyping = false
//                            searchText = ""
//                            hideKeyboard()
//                        }
//                })
//            } else {
//                Image(systemName: "slider.horizontal.3")
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 15, height: 15)
//                    .foregroundColor(Color.theme.genreText)
//                    .background {
//                        Circle()
//                            .foregroundColor(Color.theme.red)
//                            .frame(width: 30, height: 30)
//                    }
//                    .padding(.horizontal, 5)
//            }
        }
        .padding(.horizontal)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""), currentTab: .constant(Tab.movies)) {
            //
        }
    }
}
