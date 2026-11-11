# Proguard rules for IPTV Box
-keep class com.iptv.tvbox.data.model.** { *; }
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep class androidx.media3.** { *; }
