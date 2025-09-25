############################
# Payments / Wallet SDKs
############################

# --- Razorpay ---
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# --- Stripe Push Provisioning ---
-keep class com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# --- Google Pay / Bharat QR SDK ---
-keep class com.google.android.apps.nbu.paisa.inapp.** { *; }
-dontwarn com.google.android.apps.nbu.paisa.inapp.**

############################
# Play Core (SplitInstall / Deferred Components)
############################
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.tasks.**

############################
# Nimbus JOSE + Tink (crypto)
############################
# Keep Nimbus public APIs to avoid over-shrinking
-keep class com.nimbusds.jose.** { *; }
-keep class com.nimbusds.jose.jwk.** { *; }

# You already added the dependency (tink-android). Keep this dontwarn to quiet
# optional/reflective references that R8 may still see:
-dontwarn com.google.crypto.tink.**

############################
# OkHttp v2 (used by some grpc okhttp transports)
############################
# Usually unnecessary once the v2 dependency is present, but safe:
-dontwarn com.squareup.okhttp.**

############################
# Misc / Common
############################
# ProGuard annotations
-dontwarn proguard.annotation.Keep
-dontwarn proguard.annotation.KeepClassMembers

# Kotlin metadata (helpful when shrinking)
-keep class kotlin.Metadata { *; }

# If javax.* annotations trigger warnings in your graph (grpc, etc.), uncomment:
# -dontwarn javax.annotation.**
