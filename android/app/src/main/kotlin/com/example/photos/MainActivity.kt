package com.example.photos

import com.example.photos.model.ORTImageViewModel
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private lateinit var ortImageViewModel: ORTImageViewModel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        ortImageViewModel = ORTImageViewModel(applicationContext)
        ortImageViewModel.init(flutterEngine)
    }
}