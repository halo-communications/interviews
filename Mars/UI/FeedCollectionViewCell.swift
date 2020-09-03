//
//  FeedCollectionViewCell.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {

  // MARK: - Outlets

  @IBOutlet private(set) weak var imageView: UIImageView?
  @IBOutlet private weak var roverContainer: UIView? {
    didSet {

      roverContainer?.layer.cornerRadius = 5
      roverContainer?.layer.maskedCorners = .all
    }
  }
  @IBOutlet private weak var rover: UILabel?

  // MARK: - Private

  private func setupUI() {

    contentView.layer.cornerRadius = 5
    contentView.layer.maskedCorners = .all
  }

  // MARK: - Internal

  func set(image: UIImage, rover: String, sol: Int16) {

    guard let iv = imageView else { return }

    UIView.transition(
      with: iv,
      duration: 0.24,
      options: .transitionCrossDissolve,
      animations: { iv.image = image },
      completion: nil)

    self.rover?.text = rover + "\nsol: \(sol)"
  }

  // MARK: - Overrides

  override func awakeFromNib() {

    super.awakeFromNib()
    setupUI()
  }
}
