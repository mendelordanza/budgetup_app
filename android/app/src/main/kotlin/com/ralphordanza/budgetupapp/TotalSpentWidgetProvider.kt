package com.ralphordanza.budgetupapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


class TotalSpentWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->

            val dateFilter = widgetData.getString("dateFilter", "This Month") ?: ""

            updateAppWidget(
                context = context,
                appWidgetManager = appWidgetManager,
                appWidgetId = widgetId,
                dateFilter = dateFilter,
                widgetData = widgetData,
            )
        }
    }

    companion object {
        fun updateAppWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            dateFilter: String,
            widgetData: SharedPreferences,
        ) {
            val views = RemoteViews(context.packageName, R.layout.widget_layout)
            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java
            )
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            val total = getTotalByFilter(data = widgetData, dateFilter = dateFilter)
            val isSubscribed = widgetData.getBoolean("isSubscribed", false)

            val sdf = SimpleDateFormat("MMM dd, yyyy", Locale.ENGLISH)
            val formattedDate = sdf.format(Date())

            if (isSubscribed) {
                views.setViewVisibility(R.id.content, View.VISIBLE)
                views.setViewVisibility(R.id.paywall, View.INVISIBLE)

                views.setTextViewText(R.id.tv_current_date, formattedDate)
                views.setTextViewText(R.id.tv_date, dateFilter)
                views.setTextViewText(R.id.tv_balance, total)
            } else {
                views.setViewVisibility(R.id.content, View.INVISIBLE)
                views.setViewVisibility(R.id.paywall, View.VISIBLE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}

fun getTotalByFilter(data: SharedPreferences, dateFilter: String): String {
    return when (dateFilter) {
        DateFilter.MONTH.label -> {
            data.getString("thisMonthTotal", "") ?: ""
        }

        DateFilter.WEEK.label -> {
            data.getString("thisWeekTotal", "") ?: ""
        }

        DateFilter.TODAY.label -> {
            data.getString("todayTotal", "") ?: ""
        }

        else -> {
            "0.00"
        }
    }
}