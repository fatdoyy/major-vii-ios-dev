//
//  AgentsMain.swift
//  major-7-ios
//
//  Created by jason on 7/8/2022.
//  Copyright © 2022 Major VII. All rights reserved.
//

import SwiftUI

struct AgentsMain: View {
    @State var newsList: NewsList
    @State private var animateGradient = true
    @State private var buttonHeight: CGFloat = 80
    
    var body: some View {

        NavigationView {
            ZStack {
                Color(UIColor.m7DarkGray())
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    VStack {
                        NavigationLink {
                            AgentsView(newsList: $newsList)
                        } label: {
                            Label(newsList.list.first?.heading ?? "Loading...", systemImage: "figure.wave")
                                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: buttonHeight)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: GlobalCornerRadius.value)
                                        .fill(LinearGradient(colors: [Color(.lightPurple()), Color(.darkPurple())], startPoint: animateGradient ? .topLeading : .bottomLeading, endPoint: animateGradient ? .bottomTrailing : .topTrailing))
                                        .saturation(0.8)
                                        .hueRotation(.degrees(animateGradient ? 30 : 0))
                                        .shadow(color: .purple.opacity(0.7), radius: 6))
                                .onAppear {
                                    //getNewsList()
//                                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
//                                        animateGradient.toggle()
//                                    }
                                }
                            
                        }
                        .buttonStyle(.plain)
                        .padding(10)
                        
                        NavigationLink {
                            AgentsView(newsList: $newsList)
                        } label: {
                            Text("SIGN IN")
                                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: buttonHeight)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: GlobalCornerRadius.value)
                                        .fill(Color.red)
                                        .shadow(color: .red.opacity(0.7), radius: 6)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding([.leading, .trailing, .bottom], 10)
                        //.offset(y: -20)
                    }
                    
                }
            }
            .navigationTitle("Cooperation")
            .navigationBarTitleTextColor(.white)

        }
    }
}

// MARK: - API Calls
private extension AgentsMain {
    private func getNewsList(skip: Int? = nil, limit: Int? = nil) {
        NewsService.getList(skip: skip, limit: limit).done { response -> () in
            self.newsList = response
            }.catch { _ in }
    }
}

// MARK: - Previews
struct AgentsMain_Previews: PreviewProvider {
    static let newsList = NewsList()
    
    static var previews: some View {
        ForEach(["iPhone 13 Pro", "iPhone 8 Plus", "iPhone SE (3rd generation)"], id: \.self) { deviceName in
            AgentsMain(newsList: newsList)
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
