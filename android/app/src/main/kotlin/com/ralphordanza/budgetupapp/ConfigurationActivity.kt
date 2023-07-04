package com.ralphordanza.budgetupapp

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import android.widget.ListView
import android.widget.RemoteViews
import androidx.appcompat.app.AppCompatActivity
import es.antonborri.home_widget.HomeWidgetPlugin
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

enum class DateFilter(val label: String) {
    MONTH("This Month"),
    WEEK("This Week"),
    TODAY("Today");
}

class ConfigurationActivity : AppCompatActivity() {

    var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.config_selection)

        // Get the app widget id from the intent
        appWidgetId = intent.getIntExtra(
            AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID
        )

        if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
        }

        val items = listOf(DateFilter.MONTH.label, DateFilter.WEEK.label, DateFilter.TODAY.label)

        // Retrieve the ListView
        val listView: ListView = findViewById(R.id.listView)

        // Create an ArrayAdapter to populate the ListView with items
        val adapter = ArrayAdapter(this, android.R.layout.simple_list_item_1, items)

        // Set the adapter to the ListView
        listView.adapter = adapter

        listView.onItemClickListener = AdapterView.OnItemClickListener { _, _, position, _ ->
            // Handle item click here
            val selectedItem = items[position]
            saveWidgetOptions(selectedItem)
        }

        // Set the result to indicate that the configuration was canceled
        setResult(Activity.RESULT_CANCELED)
    }

    private fun saveWidgetOptions(dateFilter: String) {
        // Save the widget options based on the user input
        // ...
        val sharedPreferences = getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val editor = sharedPreferences.edit()
        editor.putString("dateFilter", dateFilter)
        editor.apply()

        val appWidgetManager = AppWidgetManager.getInstance(this)
        TotalSpentWidgetProvider.updateAppWidget(
            context = this,
            appWidgetManager = appWidgetManager,
            appWidgetId = appWidgetId,
            dateFilter = dateFilter,
            widgetData = sharedPreferences,
        )

        // Create the result intent and set the app widget id as the result
        val resultValue = Intent().apply {
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
        }

        // Set the result to indicate that the configuration was successful
        setResult(Activity.RESULT_OK, resultValue)

        // Finish the activity
        finish()
    }
}