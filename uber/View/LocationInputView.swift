//
//  LocationInputView.swift
//  uber
//
//  Created by 오국원 on 2022/04/09.
//

import UIKit

class LocationInputView: UIView {

    //MARK: - Properties
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "baseline_arrow_back_black_36dp")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left:leftAnchor,paddingTop: 44,paddingLeft: 12,width: 24, height: 25)
    
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func handleBackTapped() {
        
    }
    
}
