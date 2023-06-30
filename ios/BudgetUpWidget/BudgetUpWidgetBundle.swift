//
//  BudgetUpWidgetBundle.swift
//  BudgetUpWidget
//
//  Created by Ralph Ordanza on 6/30/23.
//

import WidgetKit
import SwiftUI

@main
struct BudgetUpWidgetBundle: WidgetBundle {
    
    @WidgetBundleBuilder
    var body: some Widget {
        BudgetUpWidget()
        BillsWidget()
    }
}
