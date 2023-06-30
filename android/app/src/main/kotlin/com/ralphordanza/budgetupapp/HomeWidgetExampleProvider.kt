package com.ralphordanza.budgetupapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.Bundle
import android.transition.Visibility
import android.view.View
import android.widget.RemoteViews
import android.widget.Toast
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HomeWidgetExampleProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            val date = widgetData.getString("_date", "") ?: "No data"
            val title = widgetData.getString("_title", "") ?: "No data"
            val balance = widgetData.getString("_balance", "") ?: "No data"
            val isSubscribed = widgetData.getBoolean("_isSubscribed", false)

            if (isSubscribed) {
                views.setViewVisibility(R.id.content, View.VISIBLE)
                views.setViewVisibility(R.id.paywall, View.INVISIBLE)

                views.setTextViewText(R.id.tv_date, date)
                views.setTextViewText(R.id.tv_title, title)
                views.setTextViewText(R.id.tv_balance, balance)
            } else {
                views.setViewVisibility(R.id.content, View.INVISIBLE)
                views.setViewVisibility(R.id.paywall, View.VISIBLE)
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}