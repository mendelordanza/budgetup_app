//
//  BillsWidget.swift
//  BudgetUpWidgetExtension
//
//  Created by Ralph Ordanza on 6/30/23.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.G53UVF44L3.com.ralphordanza.budgetupapp"

struct BillsProvider: TimelineProvider {
    func placeholder(in context: Context) -> BillEntry {
        let data = UserDefaults.init(suiteName:widgetGroupId)
        let isSubscribed = data?.bool(forKey: "isSubscribed") ?? false
        return BillEntry(date: Date(), title: "Placeholder Title", message: "Placeholder Message", isSubscribed: isSubscribed, upcomingBills: [])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (BillEntry) -> ()) {
        let data = UserDefaults.init(suiteName:widgetGroupId)
        let upcomingBillsData = data?.string(forKey: "upcomingBills") ?? ""
        let bills = convertToObject(jsonString: upcomingBillsData);
        let isSubscribed = data?.bool(forKey: "isSubscribed") ?? false
        
        let entry = BillEntry(date: Date(), title: data?.string(forKey: "title") ?? "No Title Set", message: "No message set", isSubscribed: isSubscribed, upcomingBills: bills)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct BillEntry: TimelineEntry {
    let date: Date
    let title: String
    let message: String
    let isSubscribed: Bool
    let upcomingBills: [RecurringBill]
}

struct BillsWidgetEntryView : View {
    var entry: BillsProvider.Entry
    let data = UserDefaults.init(suiteName:widgetGroupId)
    
    let samples = [
        RecurringBill(id: 0, title: "Internet", amount: "$12,000.00", reminderDate: "2023-07-03T18:33:00.000"),
        RecurringBill(id: 0, title: "Internet", amount: "$12,000.00", reminderDate: "2023-07-30T18:33:00.000"),
    ]
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if(entry.isSubscribed) {
            VStack.init(alignment: .leading, spacing: nil, content: {
                Text("Upcoming Bills")
                    .font(.system(size: 14)).multilineTextAlignment(.leading)
                    .padding(.top, 8)
                if(!entry.upcomingBills.isEmpty) {
                    ForEach(entry.upcomingBills) { recurringBill in
                        VStack(alignment: .leading) {
                            Text(recurringBill.title)
                                .font(.system(size: 12).bold())
                                .lineLimit(1)
                            Text(recurringBill.amount)
                                .font(.system(size: 12).bold())
                                .lineLimit(1)
                            Text("due \(formatISODateString(dateString: recurringBill.reminderDate))")
                                .font(.system(size: 10))
                                .lineLimit(1)
                        }.padding(.all, 5).frame(maxWidth: .infinity, alignment: .leading).background(colorScheme == .dark ? Color.orange.opacity(0.8) : Color.orange)
                            .cornerRadius(8)
                    }
                }
                else{
                    Text("No upcoming bills")
                        .font(.system(size: 14)).multilineTextAlignment(.center)
                        .frame(maxHeight: .infinity)
                }
                Spacer()
            }).padding(12)
        } else {
            VStack.init(alignment: .center, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, content: {
                            Image(systemName: "lock.fill")
                            Text("Get BudgetUp Pro to view this widget")
                                .font(.body)
                                .multilineTextAlignment(.center)
                        }).padding(16)
        }
    }
}

struct BillsWidget: Widget {
    let kind: String = "BillsWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BillsProvider()) { entry in
            BillsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Upcoming Bills")
        .description("View 2 of your upcoming bills")
        .supportedFamilies([.systemSmall])
    }
}

struct BillsWidget_Previews: PreviewProvider {
    static var previews: some View {
        BillsWidgetEntryView(entry: BillEntry(date: Date(), title: "Example Title", message: "Example Message",isSubscribed: false, upcomingBills: []))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

struct RecurringBill: Codable, Identifiable {
    let id: Int
    let title: String
    let amount: String
    let reminderDate: String
}

private func convertToObject(jsonString: String) -> [RecurringBill] {
    guard let jsonData = jsonString.data(using: .utf8) else { return [] }
    
    let decoder = JSONDecoder()
    do {
        let myObject = try decoder.decode([RecurringBill].self, from: jsonData)
        return myObject
    } catch {
        // Handle decoding errors
        print("Error decoding JSON: \(error)")
        return []
    }
}

private func formatISODateString(dateString: String) -> String {
    let isoDateFormatter = DateFormatter()
            isoDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            guard let date = isoDateFormatter.date(from: dateString) else {
                return ""
            }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            
            return dateFormatter.string(from: date)
    }
