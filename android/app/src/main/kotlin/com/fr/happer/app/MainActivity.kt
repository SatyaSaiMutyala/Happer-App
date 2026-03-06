package com.fr.happer.app

import android.content.ContentValues
import android.os.Build
import android.os.Bundle
import android.provider.MediaStore
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.OutputStream

class MainActivity: FlutterFragmentActivity() {

    private val CHANNEL = "com.happer_app/save_image"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveImageToGallery") {
                val bytes = call.argument<ByteArray>("bytes")!!
                val filename = call.argument<String>("name")!!
                val saved = saveImage(bytes, filename)
                result.success(saved)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveImage(bytes: ByteArray, filename: String): Boolean {
        val resolver = contentResolver
        val imageCollection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Images.Media.getContentUri(MediaStore.VOLUME_EXTERNAL_PRIMARY)
        } else {
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        }

        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, filename)
            put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/Happer")
            }
        }

        val imageUri = resolver.insert(imageCollection, contentValues) ?: return false
        resolver.openOutputStream(imageUri).use { out: OutputStream? ->
            out?.write(bytes)
        }
        return true
    }
}



