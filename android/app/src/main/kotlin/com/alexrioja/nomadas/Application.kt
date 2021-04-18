package com.alexrioja.nomadas
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
// Add this line
import io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin
import io.flutter.view.FlutterMain
import rekab.app.background_locator.IsolateHolderService
import rekab.app.background_locator.BackgroundLocatorPlugin
import io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin
import io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin
import com.baseflow.geolocator.GeolocatorPlugin
import com.baseflow.location_permissions.LocationPermissionsPlugin
import io.flutter.plugins.googlesignin.GoogleSignInPlugin
class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
        IsolateHolderService.setPluginRegistrant(this)
        FlutterMain.startInitialization(this)
    }

    override fun registerWith(registry: PluginRegistry?) {

// Add this section
        if (!registry!!.hasPlugin("io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin")) {
            FlutterFirebaseFirestorePlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin"))
        }
        if (!registry!!.hasPlugin("rekab.app.background_locator.BackgroundLocatorPlugin")) {
            BackgroundLocatorPlugin.registerWith(registry!!.registrarFor("rekab.app.background_locator.BackgroundLocatorPlugin"))
        }
        if (!registry!!.hasPlugin("io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin")) {
            FlutterFirebaseAuthPlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin"))
        }
        if (!registry!!.hasPlugin("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin")) {
            FlutterFirebaseCorePlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin"))
        }
        if (!registry!!.hasPlugin("com.baseflow.geolocator.GeolocatorPlugin")) {
            GeolocatorPlugin.registerWith(registry!!.registrarFor("com.baseflow.geolocator.GeolocatorPlugin"))
        }
        if (!registry!!.hasPlugin("io.flutter.plugins.googlesignin.GoogleSignInPlugin")) {
            GoogleSignInPlugin.registerWith(registry!!.registrarFor("io.flutter.plugins.googlesignin.GoogleSignInPlugin"))
        }
        if (!registry!!.hasPlugin("com.baseflow.location_permissions.LocationPermissionsPlugin")) {
            LocationPermissionsPlugin.registerWith(registry!!.registrarFor("com.baseflow.location_permissions.LocationPermissionsPlugin"))
        }

    }
}