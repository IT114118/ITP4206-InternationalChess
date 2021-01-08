//
//  ChessBoardCollectionViewCell.swift
//  InternationalChess
//
//  Created by Battlefield Duck on 5/1/2021.
//

import UIKit

class ChessBoardCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = UIImageView()
    let circleImageView = UIImageView(image: UIImage(named: Chess.circleImage))
    let label: UILabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(label)
        self.addSubview(imageView)
        self.addSubview(circleImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("ChessBoardCollectionViewCell")
    }
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.backgroundColor = color
        subview.tag = 10000
        self.addSubview(subview)
        switch edge {
        case .top, .bottom:
            subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
            subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            subview.heightAnchor.constraint(equalToConstant: thickness).isActive = true
            if edge == .top {
                subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            } else {
                subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            }
        case .left, .right:
            subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
            subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            subview.widthAnchor.constraint(equalToConstant: thickness).isActive = true
            if edge == .left {
                subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
            } else {
                subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
            }
        default:
            break
        }
    }
    
    func removeAllBorders() {
        if let viewWithTag = self.viewWithTag(10000) {
            viewWithTag.removeFromSuperview()
        }
    }
    
    func addBorderRightBottom(color: UIColor, thickness: CGFloat) {
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.backgroundColor = color
        subview.tag = 10000
        self.addSubview(subview)
        subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        subview.heightAnchor.constraint(equalToConstant: thickness).isActive = true
        subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        subview.widthAnchor.constraint(equalToConstant: thickness).isActive = true
    }
    
    func addBorderLeftBottom(color: UIColor, thickness: CGFloat) {
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.backgroundColor = color
        subview.tag = 10000
        self.addSubview(subview)
        subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        subview.heightAnchor.constraint(equalToConstant: thickness).isActive = true
        subview.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        subview.widthAnchor.constraint(equalToConstant: thickness).isActive = true
    }
    
    func addBorderLeftTop(color: UIColor, thickness: CGFloat) {
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.backgroundColor = color
        subview.tag = 10000
        self.addSubview(subview)
        subview.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        subview.heightAnchor.constraint(equalToConstant: thickness).isActive = true
        subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        subview.widthAnchor.constraint(equalToConstant: thickness).isActive = true
    }
    
    func addBorderRightTop(color: UIColor, thickness: CGFloat) {
        let subview = UIView()
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.backgroundColor = color
        subview.tag = 10000
        self.addSubview(subview)
        subview.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        subview.heightAnchor.constraint(equalToConstant: thickness).isActive = true
        subview.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        subview.widthAnchor.constraint(equalToConstant: thickness).isActive = true
    }
}
