//
//  FeedDataSource.swift
//  Mars
//
//  Created by Fred Faust on 1/12/20.
//  Copyright © 2020 Fred Faust. All rights reserved.
//

import UIKit
import CoreData

class FeedDataSource: NSObject {

  // MARK: - Properites

  private lazy var feed: NSFetchedResultsController<FeedPhoto> = {

    let request: NSFetchRequest<FeedPhoto> = FeedPhoto.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(key: #keyPath(FeedPhoto.sol), ascending: true)]

    return NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: PersistentContainer.viewContext,
      sectionNameKeyPath: nil,
      cacheName: nil)
  }()
  private weak var collectionView: UICollectionView?
  private var images = NSCache<NSIndexPath, UIImage>()
  private var changes = Array<() -> Void>()
  private lazy var placeholderImage = #imageLiteral(resourceName: "mars")

  // MARK: - Private

  private func start() {

    collectionView?.dataSource = self

    do {

      try feed.performFetch()
      collectionView?.reloadData()
      
      feed.delegate = self

    } catch { debugLog(error.localizedDescription, from: self) }
  }

  // MARK: - Lifecycle

  init(collectionView: UICollectionView) {

    self.collectionView = collectionView

    super.init()
    start()
  }
}

extension FeedDataSource: UICollectionViewDataSource {

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int) -> Int {

    return feed.sections?[section].numberOfObjects ?? 0
  }

  private func getImage(indexPath: IndexPath, cell: FeedCollectionViewCell) {

    let url = feed.object(at: indexPath).remoteImageURL

    ImageManager.current.image(at: url) { [weak self] (local) in
      DispatchQueue.main.async {

        guard let image = UIImage.load(at: local, for: cell.imageView ?? UIImageView()) else {

          return
        }

        self?.images.setObject(image, forKey: indexPath as NSIndexPath)

        if self?.collectionView?.indexPath(for: cell) == indexPath {

          let cell = self?.collectionView?.cellForItem(at: indexPath) as? FeedCollectionViewCell
          cell?.imageView?.image = image
          
        } else {

          self?.collectionView?.reloadItems(at: [indexPath])
        }
      }
    }
  }

  private func image(for indexPath: IndexPath, cell: FeedCollectionViewCell) -> UIImage {

    guard let image = images.object(forKey: indexPath as NSIndexPath) else {

      getImage(indexPath: indexPath, cell: cell)
      return placeholderImage
    }

    return image
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt
    indexPath: IndexPath) -> UICollectionViewCell {

    guard let cell = collectionView.dequeueReusableCell(
      withReuseIdentifier: "FeedCollectionViewCell",
      for: indexPath) as? FeedCollectionViewCell else {

        debugLog("returning default cell", from: self)
        return UICollectionViewCell()
    }

    let item = feed.object(at: indexPath)

    cell.set(image: image(for: indexPath, cell: cell), rover: item.rover, sol: item.sol)
    return cell
  }
}

extension FeedDataSource: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    changes = []
  }

  func controller(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>,
    didChange sectionInfo: NSFetchedResultsSectionInfo,
    atSectionIndex sectionIndex: Int,
    for type: NSFetchedResultsChangeType) {

    switch type {

    case .delete:

      changes.append { [weak self] in

        self?.collectionView?.deleteSections(IndexSet(integer: sectionIndex))
      }

    case .insert:

      changes.append { [weak self] in

        self?.collectionView?.insertSections(IndexSet(integer: sectionIndex))
      }

    case .move: break
    case .update:

      changes.append { [weak self] in

        self?.collectionView?.reloadSections(IndexSet(integer: sectionIndex))
      }
    @unknown default: debugLog("Unhandled FRCD case", from: self)
    }
  }

  func controller(
    _ controller: NSFetchedResultsController<NSFetchRequestResult>,
    didChange anObject: Any,
    at indexPath: IndexPath?,
    for type: NSFetchedResultsChangeType,
    newIndexPath: IndexPath?) {

    switch type {

    case .delete:

      guard let path = indexPath else { return }

      changes.append { [weak self] in

        self?.collectionView?.deleteItems(at: [path])
      }

    case .insert:

      guard let path = newIndexPath else { return }

      changes.append { [weak self] in

        self?.collectionView?.insertItems(at: [path])
      }

    case .move:

      guard let path = indexPath, let newPath = newIndexPath else { return }

      changes.append { [weak self] in

        self?.collectionView?.moveItem(at: path, to: newPath)
      }

    case .update:

      guard let path = indexPath else { return }

      changes.append { [weak self] in

        self?.collectionView?.reloadItems(at: [path])
      }

    @unknown default: debugLog("Unhandled FRCD case", from: self)
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

    collectionView?.performBatchUpdates({ changes.forEach { $0() }}, completion: nil)
  }
}
