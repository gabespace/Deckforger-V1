//
//  DVC+TabBarDelegate.swift
//  MTGDeckBuilder
//
//  Created by Gabriele Pregadio on 1/18/17.
//  Copyright © 2017 Gabriele Pregadio. All rights reserved.
//

import UIKit

extension DeckViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        tabBar.isUserInteractionEnabled = false
        
        if item == tabBar.items![0] && tableView.isHidden {
            tableView.alpha = 0
            tableView.isHidden = false
            UIView.animate(
                withDuration: 0.35,
                animations: { [weak self] in
                    self?.statsScrollView.alpha = 0
                    self?.tableView.alpha = 1
                },
                completion: { [weak self] finished in
                    self?.statsScrollView.isHidden = true
            })
        } else if item == tabBar.items![1] && !tableView.isHidden {
            setColorPieChartData()
            setTypePieChartData()
            setCostBarChartData()
            statsScrollView.alpha = 0
            statsScrollView.isHidden = false
            UIView.animate(
                withDuration: 0.35,
                animations: { [weak self] in
                    self?.tableView.alpha = 0
                    self?.statsScrollView.alpha = 1
                    self?.colorPieChartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.5)
                    self?.typePieChartView.animate(xAxisDuration: 0.0, yAxisDuration: 0.5)
                    self?.costBarChartView.animate(xAxisDuration: 0.5, yAxisDuration: 0.5)
                },
                completion: { [weak self] finished in
                    self?.tableView.isHidden = true
            })
        }
        
        tabBar.isUserInteractionEnabled = true
    }
}
