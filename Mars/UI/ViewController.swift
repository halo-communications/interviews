//
//  ViewController.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  // MARK: - Properties

  private var dataSource: FeedDataSource?
  private var inset: CGFloat?
  private var dimension: CGFloat?
  
  // MARK: - Outlets

  @IBOutlet private weak var collectionView: UICollectionView? {
    didSet {

      guard let cv = collectionView else { return }
      dataSource = FeedDataSource(collectionView: cv)
    }
  }
  @IBOutlet private weak var status: UIBarButtonItem?
  @IBOutlet private weak var imageStatus: UIBarButtonItem?

  // MARK: - Private

  private func start() {

    _ = FeedManager.current
    collectionView?.delegate = self
  }

  private func becomeDelegate() {

    PhotoMetaCoordinator.current.delegate = self
    FeedManager.current.delegate = self
    ImageManager.current.delegate = self
  }

  // MARK: - View lifecycle

  override func viewDidLoad() {

    super.viewDidLoad()
    becomeDelegate()
    start()
  }
}

extension ViewController: UICollectionViewDelegate {

  func collectionView(
    _ collectionView: UICollectionView,
    willDisplay cell: UICollectionViewCell,
    forItemAt indexPath: IndexPath) {

    guard indexPath.row == collectionView.numberOfItems(inSection: 0)-1 else { return }

    FeedManager.current.makeMoreFeedItems()
  }
}
extension ViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int) -> UIEdgeInsets {

    let inset = self.inset ?? floor(view.frame.size.width * 0.05)

    if self.inset == nil { self.inset = inset }
    return UIEdgeInsets(top: inset, left: inset/2, bottom: inset, right: inset/2)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath) -> CGSize {

    let dimension = self.dimension ?? floor(view.frame.size.width * 0.46)

    if self.dimension == nil { self.dimension = dimension }
    return CGSize(width: dimension, height: dimension)
  }
}

extension ViewController: PhotoMetaCoordinatorDelegate {

  func coordinator(status: String) { self.status?.title = status }
}

extension ViewController: FeedManagerDelegate {

  func feed(status: String) { self.status?.title = status }
}

extension ViewController: ImageManagerDelegate {

  func manager(status: String) { DispatchQueue.main.async { self.status?.title = status } }
}
