package com.idudu.dudu;

import android.os.Build;
import android.os.Bundle;
import android.view.ViewTreeObserver;
import android.view.WindowManager;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugins.GeneratedPluginRegistrant;
public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    boolean flutter_native_splash = true;
    int originalStatusBarColor = 0;
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        originalStatusBarColor = getWindow().getStatusBarColor();
        getWindow().setStatusBarColor(0xff646fbb);
    }
    int originalStatusBarColorFinal = originalStatusBarColor;

    GeneratedPluginRegistrant.registerWith(this);
    ViewTreeObserver vto = getFlutterView().getViewTreeObserver();
    vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
      @Override
      public void onGlobalLayout() {
        getFlutterView().getViewTreeObserver().removeOnGlobalLayoutListener(this);
        getWindow().clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
          getWindow().setStatusBarColor(originalStatusBarColorFinal);
        }
      }
    });


    new MethodChannel(getFlutterView(), "com.masfto/app_retain").setMethodCallHandler(
            new MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, Result result) {
                if (call.method.equals("sendToBackground") ) {
                    result.success(true);
                  moveTaskToBack(false);

                }
              }
            });


  }
}