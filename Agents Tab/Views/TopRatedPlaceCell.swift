//
//  TopRatedPlaceCell.swift
//  major-7-ios
//
//  Created by jason on 9/8/2022.
//  Copyright © 2022 Major VII. All rights reserved.
//

import SwiftUI
import Kingfisher

struct TopRatedPlaceCell: View {
    var event: Event
    private let width: CGFloat = 220
    private let height: CGFloat = 150
    
    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage(URL(string: event.images.first?.url ?? ""))
                .resizable()
                .fade(duration: 0.25)
                .loadDiskFileSynchronously()
                .cacheMemoryOnly()
                .placeholder { value in
                    ZStack{
                        Color.gray
                        ProgressView(value)
                    }
                }
                .onFailure { error in print("failure: \(error)") }
                .retry(maxCount: 3, interval: .seconds(5))
                .aspectRatio(contentMode: .fill)
                .clipped()
            //.scaledToFill()

            HStack {
                VStack(alignment: .leading) {
                    Text(event.address ?? "")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.m7DarkGray()))
                    //.frame(maxWidth: width, maxHeight: height, alignment: .bottomLeading)
                    
                    Text(event.dateTime ?? "Loading...")
                        .font(.subheadline)
                        .foregroundColor(Color(UIColor.m7DarkGray()))
                    //.frame(maxWidth: width, maxHeight: height, alignment: .bottomLeading)
                }
                
                Spacer()
            }
            .padding()
            .frame(height: 60)
            .background(Color.white.opacity(0.8))
            
            
        }
        //.frame(width: width, height: height)
        .cornerRadius(GlobalCornerRadius.value)
        
    }
}

struct TopRatedPlaceCell_Previews: PreviewProvider {
    static let event = Event()
    static let width: CGFloat = 220
    static let height: CGFloat = 150
    
    static var previews: some View {
        TopRatedPlaceCell(event: event)
            .previewLayout(.sizeThatFits)
        //            .previewLayout(.fixed(width: width, height: height))
    }
}

