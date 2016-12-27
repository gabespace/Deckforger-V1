//
//  Stats Extension.swift
//  MTGPrices
//
//  Created by Gabriele Pregadio on 12/12/16.
//  Copyright © 2016 Gabriele Pregadio. All rights reserved.
//

import Foundation
import UIKit
import Charts

extension DeckViewController: UIScrollViewDelegate, UIPopoverPresentationControllerDelegate {
    
    func setColorPieChartData() {
        var coloredSymbols = Array<Double>(repeatElement(0.0, count: 5))
        
        for card in cards {
            if let manaCost = card.manaCost, !card.isSideboard {
                for color in manaCost.characters {
                    switch color {
                    case "W": coloredSymbols[0] += Double(card.amount)
                    case "U": coloredSymbols[1] += Double(card.amount)
                    case "B": coloredSymbols[2] += Double(card.amount)
                    case "R": coloredSymbols[3] += Double(card.amount)
                    case "G": coloredSymbols[4] += Double(card.amount)
                    default: break
                    }
                }
            }
        }
        let totalColoredSymbols = coloredSymbols.reduce(0.0) { $0 + $1 }
        let colorNames = ["White", "Blue", "Black", "Red", "Green"]
        let colorList = [Colors.manaWhite, UIColor.blue, Colors.manaBlack, UIColor.red, Colors.manaGreen]
        
        var entries = [PieChartDataEntry]()
        var colors = [NSUIColor]()
        
        for (index, color) in coloredSymbols.enumerated() where color > 0 {
            let dataEntry = PieChartDataEntry(value: color / totalColoredSymbols, label: colorNames[index], data: coloredSymbols[index] as AnyObject)
            entries.append(dataEntry)
            colors.append(colorList[index])
        }
        
        let dataSets = PieChartDataSet(values: entries, label: "")
        dataSets.colors = colors
        dataSets.drawValuesEnabled = false
        
        let data = PieChartData(dataSet: dataSets)
        data.setValueTextColor(UIColor.clear)
        colorPieChartView.data = data
        
        colorPieChartView.drawEntryLabelsEnabled = false
        colorPieChartView.chartDescription?.text = "Mana Symbols"
    }
    
    func setTypePieChartData() {
        var cardTypes = Array<Double>(repeatElement(0.0, count: 7))
        cardTypes[0] = Double(creaturesCount)
        cardTypes[6] = Double(landsCount)
        
        for card in spells {
            if card.type.contains("Instant") {
                cardTypes[1] += Double(card.amount)
            } else if card.type.contains("Sorcery") {
                cardTypes[2] += Double(card.amount)
            } else if card.type.contains("Planeswalker") {
                cardTypes[3] += Double(card.amount)
            } else if card.type.contains("Artifact") {
                cardTypes[4] += Double(card.amount)
            } else if card.type.contains("Enchantment") {
                cardTypes[5] += Double(card.amount)
            }
        }
        let totalCards = cardTypes.reduce(0.0) { $0 + $1 }
        let typeNames = ["Creatures", "Instants", "Sorceries", "Planeswalkers", "Artifacts", "Enchantments", "Lands"]
        let colorList = [Colors.creatureColor, Colors.instantColor, Colors.sorceryColor, Colors.planeswalkerColor, Colors.artifactColor, Colors.enchantmentColor, Colors.landColor]
        
        var entries = [PieChartDataEntry]()
        var colors = [NSUIColor]()
        
        for (index, type) in cardTypes.enumerated() where type > 0 {
            let dataEntry = PieChartDataEntry(value: type / totalCards, label: typeNames[index], data: Int(cardTypes[index]) as AnyObject)
            entries.append(dataEntry)
            colors.append(colorList[index])
        }
        
        let dataSets = PieChartDataSet(values: entries, label: "")
        dataSets.colors = colors
        dataSets.drawValuesEnabled = false
        
        let data = PieChartData(dataSet: dataSets)
        data.setValueTextColor(UIColor.clear)
        typePieChartView.data = data
        
        typePieChartView.drawEntryLabelsEnabled = false
        typePieChartView.chartDescription?.text = "Card Types"
    }
    
    func setCostBarChartData() {
        var costs = Array<Double>(repeatElement(0, count: 16))
        for card in cards where !card.isSideboard {
            if let cmc = Int(card.cmc) {
                costs[cmc] += Double(card.amount)
            }
        }
        
        var dataSets: [BarChartDataEntry] = []
        var largestAmount = 0
        var largestCmc = 0
        for (cmc, amount) in costs.enumerated() {
            if amount > 0 {
                dataSets.append(BarChartDataEntry(x: Double(cmc), y: amount))
                largestAmount = max(largestAmount, Int(amount))
                largestCmc = cmc
            }
        }
        let dataSet = BarChartDataSet(values: dataSets, label: "CMC")
        dataSet.drawValuesEnabled = false
        dataSet.valueFormatter = BarChartValueFormatter()
        let data = BarChartData()
        data.addDataSet(dataSet)
        costBarChartView.data = data
        
        costBarChartView.fitBars = true
        costBarChartView.legend.enabled = false
        costBarChartView.chartDescription?.text = "Mana Curve"
        costBarChartView.rightAxis.enabled = false
        
        // Format X-Axis.
        costBarChartView.xAxis.labelPosition = .bottom
        costBarChartView.xAxis.drawGridLinesEnabled = false
        costBarChartView.xAxis.valueFormatter = BarChartFormatter()
        costBarChartView.xAxis.wordWrapEnabled = true
        costBarChartView.xAxis.forceLabelsEnabled = true
        costBarChartView.xAxis.labelCount = largestCmc
        
        // Format Y-Axis.
        costBarChartView.leftAxis.granularityEnabled = true
        costBarChartView.leftAxis.granularity = 1.0
        costBarChartView.leftAxis.forceLabelsEnabled = true
        costBarChartView.leftAxis.labelCount = largestAmount
    }
    
    struct Colors {
        static let background = UIColor(red: 0.94, green: 0.94, blue: 0.94, alpha: 1.0)
        static let manaWhite = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        static let manaBlack = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        static let manaGreen = UIColor(red: 0.18, green: 0.76, blue: 0.36, alpha: 1.0)
        static let creatureColor = UIColor(red: 0.2, green: 0.85, blue: 1.0, alpha: 1.0)
        static let instantColor = UIColor(red: 0.6, green: 1.0, blue: 0.2, alpha: 1.0)
        static let sorceryColor = UIColor(red: 0.3, green: 0.6, blue: 0.8, alpha: 1.0)
        static let planeswalkerColor = UIColor(red: 0.48, green: 0.2, blue: 1.0, alpha: 1.0)
        static let artifactColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        static let enchantmentColor = UIColor(red: 0.94, green: 0.93, blue: 0.4, alpha: 1.0)
        static let landColor = UIColor(red: 0.89, green: 0.59, blue: 0.89, alpha: 1.0)
    }
    
}

extension DeckViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if chartView is BarChartView {
            chartView.data?.dataSets[0].drawValuesEnabled = true
        } else {
            chartView.data?.setDrawValues(true)
            chartView.data?.setValueTextColor(Colors.background)
            chartView.data?.dataSets[0].valueFormatter = ShowTitleOnlyFormatter()
        }
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        costBarChartView.data?.dataSets[0].drawValuesEnabled = false
        chartView.data?.setDrawValues(false)
        chartView.data?.setValueTextColor(UIColor.clear)
    }
}

public class BarChartFormatter: NSObject, IAxisValueFormatter {
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return String(Int(value))
    }
}

public class BarChartValueFormatter: NSObject, IValueFormatter {
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return String(Int(value))
    }
}

public class ShowTitleOnlyFormatter: NSObject, IValueFormatter {
    public func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return "\(entry.data!)"
    }
}
