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
    @State var isKeyboardShowing: Bool = false
    
    var queryToCall: () -> Void
    
    var textFieldString: String {
        return currentTab.searchTextLabel
    }
    
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(!isKeyboardShowing ? Color.theme.red : Color.theme.text)
                    .imageScale(.medium)
                
                TextField(textFieldString, text: $searchText)
                    .foregroundColor(Color.theme.text)
                    .disableAutocorrection(true)
                    .font(.system(size: 16, design: .default))
                    .onReceive(keyboardPublisher) { value in
                        isKeyboardShowing = value
                        
                        withAnimation(.spring()) {
                            if isKeyboardShowing {
                                isTyping = true
                            } else {
                                isTyping = false
                            }
                        }
                    }
                    .onSubmit {
                        isTyping = false
                        isKeyboardShowing = false
                        hideKeyboard()
                    }
                    .overlay(alignment: .trailing, content: {
                        if isTyping {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding()
                                .offset(x: 15)
                                .foregroundColor(Color.theme.text)
                                .opacity(!isTyping ? 0.0 : 1.0)
                                .onTapGesture {
                                    searchText = ""
                                    isTyping = false
                                }
                        } else {
                            Image(systemName: "slider.horizontal.3")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25)
                                .padding()
                                .offset(x: 15)
                                .foregroundColor(Color.theme.red)
                                .opacity(!isKeyboardShowing ? 1.0 : 0.0)
                                .onTapGesture { print("filter") }
                        }
                    })
                    .submitLabel(.search)
                    .onChange(of: self.searchText) { newValue in
                        if(!searchText.isEmpty) {
                            queryToCall()
                        }
                    }
            }
            .font(.headline)
            .padding()
            .frame(height: 50)
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .background(Color.theme.secondary)
            .cornerRadius(20)
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
