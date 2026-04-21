package cz.soboltech.dyos

import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        // Register plugins BEFORE super so platform views (e.g. Google Maps) are available
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            MAPS_CONFIG_CHANNEL,
        ).setMethodCallHandler { call, result ->
            if (call.method == "getGeoApiKey") {
                result.success(readGeoApiKeyFromManifest())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun readGeoApiKeyFromManifest(): String {
        return try {
            val appInfo =
                packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
            (appInfo.metaData?.getString("com.google.android.geo.API_KEY") ?: "").trim()
        } catch (_: Exception) {
            ""
        }
    }

    companion object {
        private const val MAPS_CONFIG_CHANNEL = "com.dyos.app/maps_config"
    }
}
