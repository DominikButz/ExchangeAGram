//
//  FilterCell.swift
//  ExchangeAGram
//
//  Created by Dominik Butz on 30/10/14.
//  Copyright (c) 2014 Duoyun. All rights reserved.
//

import UIKit

class FilterCell: UICollectionViewCell {
    
    // no storyboad setup - collection view created in non-storyboard VC
    
    var imageView: UIImageView!
    
    
    required init(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        

    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        
        self.contentView.addSubview(self.imageView)
        
    }
    
}
