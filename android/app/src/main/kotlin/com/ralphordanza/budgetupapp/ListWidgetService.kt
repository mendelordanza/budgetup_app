package com.ralphordanza.budgetupapp

import android.content.Context
import android.content.Intent
import android.util.Log
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import com.google.gson.GsonBuilder
import com.google.gson.reflect.TypeToken
import java.text.SimpleDateFormat
import java.util.Locale

class ListWidgetService : RemoteViewsService() {

    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        val json = intent.getStringExtra("upcomingBills") ?: ""
        val gson = GsonBuilder().create()
        val list = gson.fromJson<ArrayList<RecurringBill>>(json, object :
            TypeToken<ArrayList<RecurringBill>>(){}.type)
        return ListRemoteViewsFactory(this.applicationContext, list ?: emptyList())
    }
}

class ListRemoteViewsFactory(
    private val context: Context,
    private val upcomingBills: List<RecurringBill>
) : RemoteViewsService.RemoteViewsFactory {

    override fun onCreate() {
        // Initialize data or fetch data from a source
    }

    override fun onDataSetChanged() {
        // Update data if needed
    }

    override fun onDestroy() {
        // Cleanup or release any resources used
    }

    override fun getCount(): Int {
        return upcomingBills.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        val remoteViews = RemoteViews(context.packageName, R.layout.upcoming_bill_item)
        remoteViews.setTextViewText(R.id.tv_title, upcomingBills[position].title)
        remoteViews.setTextViewText(R.id.tv_amount, upcomingBills[position].amount)

        val inputFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS", Locale.getDefault())
        val date = inputFormat.parse(upcomingBills[position].reminderDate)

        val outputFormat = SimpleDateFormat("MMM dd, yyyy", Locale.getDefault())
        val formattedDate = date?.let { outputFormat.format(it) }

        remoteViews.setTextViewText(R.id.tv_date, "due $formattedDate")
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
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return false
    }

}