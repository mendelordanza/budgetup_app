//
//  BudgetUpWidgetExtension.swift
//  BudgetUpWidgetExtension
//
//  Created by Ralph Ordanza on 6/28/23.
//

import WidgetKit
import SwiftUI
import Intents


private let widgetGroupId = "group.G53UVF44L3.com.ralphordanza.budgetupapp"

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> ExampleEntry {
        let data = UserDefaults.init(suiteName:widgetGroupId)
        let isSubscribed = data?.bool(forKey: "isSubscribed") ?? false
        return ExampleEntry(date: Date(), filter: "This Month", total: "$100.00", isSubscribed: isSubscribed)
    }
    
    func getSnapshot(for configuration: BudgetUpConfigurationIntent, in context: Context, completion: @escaping (ExampleEntry) -> ()) {
        let data = UserDefaults.init(suiteName:widgetGroupId)
        let filter = convertToString(using: configuration.dateFilter)
        
        data?.setValue(filter, forKey: "filter")
        
        let total = data?.string(forKey: "total") ?? "No Total"
        let isSubscribed = data?.bool(forKey: "isSubscribed") ?? true
        
        let entry = ExampleEntry(date: Date(), filter: filter, total: total, isSubscribed: isSubscribed)
        completion(entry)
    }
    
    func getTimeline(for configuration: BudgetUpConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        
        let data = UserDefaults.init(suiteName:widgetGroupId)
        let filter = convertToString(using: configuration.dateFilter)
        
        data?.setValue(filter, forKey: "filter")
        
        let total = data?.string(forKey: "total") ?? "No Total"
        let isSubscribed = data?.bool(forKey: "isSubscribed") ?? true
        
        let entry = ExampleEntry(date: Date(), filter: filter, total: total, isSubscribed: isSubscribed)
        completion(entry)
        
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
        
        getSnapshot(for: configuration, in: context) { (entry) in
            
        }
    }
}

struct ExampleEntry: TimelineEntry {
    let date: Date
    let filter: String
    let total: String
    let isSubscribed: Bool
}

struct BudgetUpWidgetExtensionEntryView : View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName:widgetGroupId)
    
    var body: some View {
        if(entry.isSubscribed) {
            VStack.init(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Text(entry.filter)
                    .font(.system(size: 14))
                Spacer()
                VStack (alignment: .leading) {
                    Text("Total Spent")
                        .font(.system(size: 14))
                    Text(entry.total).font(.system(size: 28, weight: .bold)).widgetURL(URL(string: "homeWidgetExample://total?total=\(entry.total)&homeWidget"))
                }
            }).padding(16)
        }
        else {
            VStack.init(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Image(systemName: "lock.fill")
                Text("Get BudgetUp Pro to view this widget")
                    .font(.body)
            }).padding(16)
            
        }
    }
}

struct BudgetUpWidgetExtension: Widget {
    let kind: String = "BudgetUpWidgetExtension"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: BudgetUpConfigurationIntent.self, provider: Provider()) { entry in
            BudgetUpWidgetExtensionEntryView(entry: entry)
        }
        .configurationDisplayName("Total Spent")
        .description("Shows total spent based on date")
    }
}

struct BudgetUpWidgetExtension_Previews: PreviewProvider {
    static var previews: some View {
        BudgetUpWidgetExtensionEntryView(entry: ExampleEntry(date: Date(), filter: "This Month", total: "$100.00", isSubscribed: false))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

private func convertToString(using dateFilter: DateFilter) -> String {
    switch dateFilter {
    case .month:
        return "This Month"
    case .today:
        return "Today"
    case .week:
        return "This Week"
    case .unknown:
            fatalError("Unknow color")
    }
}
