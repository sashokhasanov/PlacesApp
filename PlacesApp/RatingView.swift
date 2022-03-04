//
//  RatingView.swift
//  PlacesApp
//
//  Created by Сашок on 04.03.2022.
//

import UIKit

@IBDesignable class RatingView: UIStackView {
    
    private var ratingButtons: [UIButton] = []
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
            setNeedsLayout()
        }
    }
    
    @IBInspectable var starsCount: Int = 5 {
        didSet {
            
            starsCount = max(1, starsCount)
            
            setupButtons()
            setNeedsLayout()
        }
    }
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButtons()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        
        setupButtons()
    }
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        
        ratingButtons.removeAll()
        
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 1...starsCount {
            
            let button = UIButton()
            
            button.contentMode = .scaleAspectFit
            
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            translatesAutoresizingMaskIntoConstraints = false
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            
            addArrangedSubview(button)
            
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
    }
    
    @objc private func buttonTapped(sender: UIButton) {
        guard let index = ratingButtons.firstIndex(of: sender) else {
            return
        }
        
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    private func updateButtonSelectionState() {
        
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
