//
//  BudgetUpWidget.swift
//  BudgetUpWidget
//
//  Created by Ralph Ordanza on 6/30/23.
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
        let total = getTotalByFilter(data: data, using: configuration.dateFilter)
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

struct BudgetUpWidgetEntryView : View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName:widgetGroupId)
    
    var body: some View {
        if(entry.isSubscribed) {
            VStack.init(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                Text(currentFormattedDate())
                    .font(.system(size: 12)).multilineTextAlignment(.leading)
                Text(entry.filter)
                    .font(.system(size: 12)).multilineTextAlignment(.leading)
                Spacer()
                VStack (alignment: .leading) {
                    Text("Total Spent")
                        .font(.system(size: 14)).multilineTextAlignment(.leading)
                    Text(entry.total).font(.system(size: 28, weight: .bold)).multilineTextAlignment(.leading)
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
    
    func currentFormattedDate() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let currentDate = Date()
            return dateFormatter.string(from: currentDate)
        }
}

struct BudgetUpWidget: Widget {
    let kind: String = "BudgetUpWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: BudgetUpConfigurationIntent.self, provider: Provider()) { entry in
            BudgetUpWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Total Spent")
        .description("Shows total spent based on date")
    }
}

struct BudgetUpWidget_Previews: PreviewProvider {
    static var previews: some View {
        BudgetUpWidgetEntryView(entry: ExampleEntry(date: Date(), filter: "This Month", total: "$100.00", isSubscribed: false))
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

private func getTotalByFilter(data: UserDefaults?, using dateFilter: DateFilter) -> String {
    switch dateFilter {
    case .month:
        return data?.string(forKey: "thisMonthTotal") ?? ""
    case .today:
        return data?.string(forKey: "todayTotal") ?? ""
    case .week:
        return data?.string(forKey: "thisWeekTotal") ?? ""
    case .unknown:
            fatalError("Unknow color")
    }
}
