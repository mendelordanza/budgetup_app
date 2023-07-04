package com.ralphordanza.budgetupapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider


class UpcomingBillsWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val isSubscribed = widgetData.getBoolean("isSubscribed", false)

            val intent = Intent(context, ListWidgetService::class.java).apply {
                // Add the widget ID to the intent extras.
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }

            val views = RemoteViews(context.packageName, R.layout.upcoming_bills_layout).apply {
                setRemoteAdapter(R.id.bills_list, intent)
            }

            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            if (isSubscribed) {
                views.setViewVisibility(R.id.content, View.VISIBLE)
                views.setViewVisibility(R.id.paywall, View.INVISIBLE)
            } else {
                views.setViewVisibility(R.id.content, View.INVISIBLE)
                views.setViewVisibility(R.id.paywall, View.VISIBLE)
            }

            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.bills_list);
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}

data class RecurringBill(
    val id: Int,
    val title: String,
    val amount: String,
    val reminderDate: String,
)