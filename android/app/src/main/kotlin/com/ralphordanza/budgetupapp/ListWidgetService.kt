package com.ralphordanza.budgetupapp

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.time.LocalDateTime
import java.time.format.DateTimeFormatter
import java.util.Date
import java.util.Locale

class ListWidgetService : RemoteViewsService() {

    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return ListRemoteViewsFactory(this.applicationContext, intent)
    }
}

class ListRemoteViewsFactory(
    private val context: Context,
    private val intent: Intent
) : RemoteViewsService.RemoteViewsFactory {

    private var data: List<RecurringBill> = emptyList()

    override fun onCreate() {
        // Initialize data or fetch data from a source
        data = fetchData()
    }

    override fun onDataSetChanged() {
        // Update data if needed
        data = fetchData()
    }

    override fun onDestroy() {
        // Cleanup or release any resources used
    }

    override fun getCount(): Int {
        return data.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        val remoteViews = RemoteViews(context.packageName, R.layout.upcoming_bill_item)
        remoteViews.setTextViewText(R.id.tv_title, data[position].title)
        remoteViews.setTextViewText(R.id.tv_amount, data[position].amount)

        val inputFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        val outputFormat = "MMM dd, yyyy"
        val dateTime = LocalDateTime.parse(
            data[position].reminderDate,
            DateTimeFormatter.ofPattern(inputFormat)
        )
        val formattedDate = dateTime.format(DateTimeFormatter.ofPattern(outputFormat))

        remoteViews.setTextViewText(R.id.tv_date, "due ${formattedDate}")
        return remoteViews
    }

    override fun getLoadingView(): RemoteViews? {
        // Return a custom loading view if needed
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return data[position].id.toLong()
    }

    override fun hasStableIds(): Boolean {
        return false
    }

    private fun fetchData(): List<RecurringBill> {
        // Fetch or generate the data for the ListView
        val jsonString = HomeWidgetPlugin.getData(context).getString("upcomingBills", "") ?: ""
        val listType = object : TypeToken<List<RecurringBill>>() {}.type
        return Gson().fromJson(jsonString, listType)
    }

}