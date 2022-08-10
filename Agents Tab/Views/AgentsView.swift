//
//  AgentsView.swift
//  major-7-ios
//
//  Created by jason on 1/8/2022.
//  Copyright © 2022 Major VII. All rights reserved.
//

import SwiftUI

struct AgentsView: View {
    @Binding var events: Events
    
    var body: some View {
        if #available(iOS 15.0, *) {
            Color(UIColor.m7DarkGray())
                .ignoresSafeArea()
                .overlay(
                    VStack {
                        MapView()
                            .frame(height: UIScreen.main.bounds.height / 2.5)
                            .ignoresSafeArea()
                        
                        CircleImage()
                            .offset(y: -100)
                            .padding(.bottom, -130)
                            .zIndex(1)
                        
                        VStack(alignment: .leading) {
                            Text(events.list.first?.title ?? "Loading")
                                .bold()
                                .font(.title)
                            HStack {
                                Text(events.list.first?.title ?? "Loading")
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                Spacer()
                                Text("1234")
                                    .bold()
                                    .foregroundColor(.orange)
                            }
                            .background(.purple)
                        }
                        .background(.yellow)
                        
                        .padding()
                        Divider()

                        Text("123456456")
                        Spacer()
                    }
                )
        } else {
            // Fallback on earlier versions
        }
    }
}

struct AgentsView_Previews: PreviewProvider {
    @State static var newsList = Events()
    
    static var previews: some View {
        ForEach(["iPhone 13 Pro", "iPhone 8 Plus", "iPhone SE (3rd generation)"], id: \.self) { deviceName in
            AgentsView(events: $newsList)
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
    }
}
