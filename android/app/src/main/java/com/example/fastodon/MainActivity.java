package com.idudu.dudu;

import android.os.Build;
import android.view.ViewTreeObserver;
import android.view.WindowManager;



import io.flutter.plugin.common.MethodChannel;

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.embedding.android.FlutterActivity;

public class MainActivity extends FlutterActivity {
//    @Override
//    protected void onCreate() {
//        boolean flutter_native_splash = true;
//        int originalStatusBarColor = 0;
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
//            originalStatusBarColor = getWindow().getStatusBarColor();
//            getWindow().setStatusBarColor(0xff646fbb);
//        }
//        int originalStatusBarColorFinal = originalStatusBarColor;
//
//
////        ViewTreeObserver vto = getFlutterView().getViewTreeObserver();
////        vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
////            @Override
////            public void onGlobalLayout() {
////                getFlutterView().getViewTreeObserver().removeOnGlobalLayoutListener(this);
////                getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
////                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
////                    getWindow().setStatusBarColor(originalStatusBarColorFinal);
////                }
////            }
////        });
//
//
//    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {

        GeneratedPluginRegistrant.registerWith(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.masfto/app_retain").setMethodCallHandler(
                (call,result) -> {
                    if (call.method.equals("sendToBackground")) {
                        result.success(true);
                        moveTaskToBack(false);

                    }
                });
    }
}