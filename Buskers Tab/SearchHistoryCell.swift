//
//  SearchHistoryCell.swift
//  major-7-ios
//
//  Created by jason on 25/3/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import UIKit

protocol SearchHistoryCellDelegate: class {
    func removeBtnTapped(cell: SearchHistoryCell)
}

class SearchHistoryCell: UITableViewCell {
    weak var delegate: SearchHistoryCellDelegate?
    
    static let reuseIdentifier = "searchHistoryCell"
    
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var history: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .m7DarkGray()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func removeBtnTapped(_ sender: Any) {
        delegate?.removeBtnTapped(cell: self)
    }
}
