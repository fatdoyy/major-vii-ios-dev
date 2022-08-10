//
//  TopRatedPlaceCell.swift
//  major-7-ios
//
//  Created by jason on 9/8/2022.
//  Copyright © 2022 Major VII. All rights reserved.
//

import SwiftUI

struct TopRatedPlaceCell: View {
    let title: String
    var body: some View {
        ZStack {
//            Image("cat")
//                .resizable()
//                .scaledToFill()
//                //.aspectRatio(contentMode: .fill)
//                .clipped()
            
            Rectangle()
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                .padding(6)
        }
        .cornerRadius(GlobalCornerRadius.value)
    }
}

struct TopRatedPlaceCell_Previews: PreviewProvider {
    static var previews: some View {
        TopRatedPlaceCell(title: "4356")
            .previewLayout(.fixed(width: 190, height: 120))
        
    }
}
 
