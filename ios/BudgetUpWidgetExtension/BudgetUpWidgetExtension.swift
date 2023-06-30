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
        let isSubscribed = data?.bool(forKey: "isSubscribed") ?? false
        
        let entry = ExampleEntry(date: Date(), filter: filter, total: total, isSubscribed: isSubscribed)
        completion(entry)
    }
    
    func getTimeline(for configuration: BudgetUpConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(for: configuration, in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .never)
            completion(timeline)
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





//Total Spent Widget
//struct TotalSpentProvider: IntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), filter: "This Month", isSubscribed: false, total: "$100.00")
//    }
//
//    func getSnapshot(for configuration: BudgetUpConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//
//        let sharedDefaults = UserDefaults.init(suiteName: widgetGroupId)
//        let filter = convertToString(using: configuration.dateFilter)
//        sharedDefaults?.setValue(configuration.dateFilter, forKey: "_filter")
//        let isSubscribed = sharedDefaults?.bool(forKey: "_isSubscribed") ?? false
//        let total = sharedDefaults?.string(forKey: "_total") ?? "0.00"
//
//        let entry = SimpleEntry(date: Date(),filter: filter, isSubscribed: isSubscribed, total: total)
//        completion(entry)
//    }
//
//    func getTimeline(for configuration: BudgetUpConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        getSnapshot(for: configuration, in: context) { (entry) in
//            let timeline = Timeline(entries: [entry], policy: .atEnd)
//            completion(timeline)
//        }
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let filter: String
//    let isSubscribed: Bool
//    let total: String
//}
//
//struct BudgetUpWidgetExtensionEntryView : View {
//    let entry: TotalSpentProvider.Entry
//
//    var body: some View {
//
//        VStack(alignment: .leading) {
//            Text(entry.filter)
//                .font(.system(size: CGFloat(14.0)))
//            Spacer()
//            VStack(alignment: .leading) {
//                Text("Total Spent")
//                    .font(.system(size: CGFloat(14.0)))
//                Text(entry.total)
//                    .font(.system(size: CGFloat(28.0)))
//                    .fontWeight(Font.Weight.bold)
//                    .widgetURL(URL(string: "homeWidgetExample://message?message=\(entry.total)&homeWidget"))
//            }
//        }.padding(16)
//    }
//}
//
//struct BudgetUpWidgetExtension: Widget {
//    let kind: String = "BudgetUpWidgetExtension"
//
//    var body: some WidgetConfiguration {
//        IntentConfiguration(kind: kind, intent: BudgetUpConfigurationIntent.self, provider: TotalSpentProvider()) { entry in
//            BudgetUpWidgetExtensionEntryView(entry: entry)
//        }
//        .configurationDisplayName("Total Spent")
//        .description("Shows total balance based on date filter")
//        .supportedFamilies([
//            .systemSmall])
//    }
//}
//
//struct BudgetUpWidgetExtension_Previews: PreviewProvider {
//    static var previews: some View {
//        BudgetUpWidgetExtensionEntryView(entry: SimpleEntry(date: Date(), filter: "This Month", isSubscribed: false, total: "$100.00"))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
//
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
