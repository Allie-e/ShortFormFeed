//
//  CellReusable.swift
//  ShortFormFeed
//
//  Created by Allie on 2023/07/16.
//

import UIKit

protocol CellReusable {
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String)
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell
}

extension CellReusable {
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }

    func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T? {
        guard let cell = dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath) as? T else {
            return nil
        }

        return cell
    }
}

extension UICollectionView: CellReusable { }
