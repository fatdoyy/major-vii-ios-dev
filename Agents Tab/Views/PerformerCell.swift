//
//  PerformerCell.swift
//  major-7-ios
//
//  Created by jason on 12/8/2022.
//  Copyright © 2022 Major VII. All rights reserved.
//

import SwiftUI
import Kingfisher

struct PerformerCell: View {
    var performer: OrganizerProfile
    
    var body: some View {
        
        HStack {
            KFImage(URL(string: performer.coverImages.first?.url ?? ""))
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
                .frame(width: 100, height: 100)
                .aspectRatio(contentMode: .fit)
                .clipped()
            
            HStack {
                VStack(alignment: .leading) {
                    Text(performer.name ?? "123")
                        .font(.headline)
                        .foregroundColor(Color(UIColor.m7DarkGray()))
                    //.frame(maxWidth: width, maxHeight: height, alignment: .bottomLeading)
                    

                    Text(performer.genreCodes.joined(separator: " ").lowercased())
                        .font(.subheadline)
                        .foregroundColor(Color(UIColor.m7DarkGray()))
                    //.frame(maxWidth: width, maxHeight: height, alignment: .bottomLeading)
                    
                }
                
                Spacer()
                
                Image(systemName: "heart")
            }
            
            Spacer()
            
        }
        .background(Color.blue)
        .cornerRadius(GlobalCornerRadius.value)
        
    }
}

struct PerformerCell_Previews: PreviewProvider {
    static let performer = OrganizerProfile()
    
    static var previews: some View {
        PerformerCell(performer: performer)
    }
}
