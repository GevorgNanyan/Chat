//BaseCells.swift
/*
 * ChatUI
 * Created by Gevor Nanyan on 03.04.24.
 * Is a product created by abnboys
 * For the ChatUI in the ChatUI
 
 * Here the permission is granted to this file with free of use anywhere in the IOS Projects.
*/

import UIKit

class LKBaseCollectionViewCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    /**
     * Overriding a parent method does nothing, but could use for intialising subviews
     * This will be called on at the time of cell intialisation
     */
    func setupViews() {
        
    }
}
