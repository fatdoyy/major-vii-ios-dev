//
//  AgentsMain.swift
//  major-7-ios
//
//  Created by jason on 7/8/2022.
//  Copyright © 2022 Major VII. All rights reserved.
//

import SwiftUI

struct AgentsMain: View {
    @State var events: Events
    @State private var animateGradient = true
    @State private var buttonHeight: CGFloat = 80
    
    var rows =  [GridItem(.fixed(120))]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.m7DarkGray())
                    .ignoresSafeArea()
                VStack {
                    HStack {
                        Text("Top Rated Places Nearby")
                            //.frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        
                        
                        Label("", systemImage: "location.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.leading, 20)

                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 20) {
                            if let list = events.list {
                                ForEach((0 ..< (list.isEmpty ? 2 : list.count)), id: \.self) { index in
                                    NavigationLink { AgentsView(events: $events) } label: {
                                        TopRatedPlaceCell(title: list.isEmpty ? "" : list[index].title!)
                                            .frame(width: 190, height: 120)
                                    }
                                    
                                    
                                }
                            }
                        }
                        .frame(minHeight: 100, maxHeight: 120)
                        .padding(.leading, 20)
                    }
                    
                    Spacer()
                    
                    
                    
                    VStack {
                        NavigationLink {
                        } label: {
                            Label(events.list.first?.title ?? "Loading...", systemImage: "figure.wave")
                                .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: buttonHeight)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: GlobalCornerRadius.value)
                                        .fill(LinearGradient(colors: [Color(.lightPurple()), Color(.darkPurple())], startPoint: animateGradient ? .topLeading : .bottomLeading, endPoint: animateGradient ? .bottomTrailing : .topTrailing))
                                        .saturation(0.8)
                                        .hueRotation(.degrees(animateGradient ? 30 : 0))
                                        .shadow(color: .purple.opacity(0.7), radius: 6))
                                .onAppear {
//                                    withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
//                                        animateGradient.toggle()
//                                    }
                                }
                            
                        }
                        .buttonStyle(.plain)
                        .padding(10)
                        
                        NavigationLink {
                            AgentsView(events: $events)
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
            .onAppear {
                getEvents()
            }
            .navigationTitle("Cooperation")
            .navigationBarTitleTextColor(.white)

        }
    }
}

// MARK: - API Calls
private extension AgentsMain {
    private func getEvents() {
        EventService.getFeaturedEvents().done { response in
            self.events = response
        }.catch { _ in }
    }
}

// MARK: - Previews
struct AgentsMain_Previews: PreviewProvider {
    static let events = Events()
    
    static var previews: some View {
        ForEach(["iPhone 13 Pro", "iPhone 8 Plus", "iPhone SE (3rd generation)"], id: \.self) { deviceName in
            AgentsMain(events: events)
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
