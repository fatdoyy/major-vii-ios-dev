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
    @State var performers: BuskerList
    @State private var animateGradient = true
    @State private var buttonHeight: CGFloat = 60

    var rows = [GridItem(.adaptive(minimum: 100, maximum: 170))]
    
    var columns = [
        GridItem()
    ]
    
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
                    .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 0))

                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 20) {
                            if let list = events.list.shuffled() {
                                ForEach((0 ..< (list.isEmpty ? 2 : list.count)), id: \.self) { index in
                                    NavigationLink {
                                        if !list.isEmpty {
                                            AgentsView(event: list[index])
                                        }
                                    } label: {
                                        TopRatedPlaceCell(event: list.isEmpty ? Event() : list[index])
                                           // .frame(maxWidth: 220)
                                    }
                                    
                                }
                            }
                        }
                        .frame(minHeight: 100, maxHeight: 170)
                        .padding(.leading, 20)
                        //.background(Color.red)
                    }

                    
                    HStack {
                        Text("Treding Performers")
                            //.frame(maxWidth: .infinity, alignment: .leading)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 15, leading: 20, bottom: 10, trailing: 0))
                    
                    ScrollView {
                        LazyVGrid(columns: columns) {
                            if let list = performers.list.shuffled() {
                                ForEach((0 ..< (list.isEmpty ? 2 : list.count)), id: \.self) { index in
                                    NavigationLink {
                                        if !list.isEmpty {
                                            //AgentsView(event: list[index])
                                        }
                                    } label: {
                                        PerformerCell(performer: list.isEmpty ? OrganizerProfile() : list[index])
                                           // .frame(maxWidth: 220)
                                    }
                                    
                                }
                                
                            }
                        }
                    }
                    
                    
                    
                    Spacer()
                    
                    VStack {
                        NavigationLink {
                        } label: {
                            Label("Become a Perfomer!!", systemImage: "figure.wave")
                                .font(.headline)
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
                        .padding(20)
            
                    }
                }
            }
            .onAppear {
                getEvents()
                getPerformers()
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
    
    private func getPerformers() {
        BuskerService.getBuskersByTrend().done { response in
            self.performers = response
        }.catch { _ in }
    }
    
}

// MARK: - Previews
struct AgentsMain_Previews: PreviewProvider {
    static let events = Events()
    static let performers = BuskerList()
    
    static var previews: some View {
        ForEach(["iPhone 13 Pro", "iPhone 8 Plus", "iPhone SE (3rd generation)"], id: \.self) { deviceName in
            AgentsMain(events: events, performers: performers)
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
