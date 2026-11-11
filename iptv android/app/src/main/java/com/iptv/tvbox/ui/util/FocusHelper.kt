package com.iptv.tvbox.ui.util

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.view.View
import android.view.animation.DecelerateInterpolator

object FocusHelper {

    fun setupTvFocusAnimation(view: View, scaleFactor: Float = 1.06f) {
        view.setOnFocusChangeListener { v, hasFocus ->
            val scale = if (hasFocus) scaleFactor else 1.0f
            val elevation = if (hasFocus) 12f else 2f

            v.elevation = elevation
            v.translationZ = if (hasFocus) 8f else 0f

            val animX = ObjectAnimator.ofFloat(v, View.SCALE_X, scale)
            val animY = ObjectAnimator.ofFloat(v, View.SCALE_Y, scale)

            AnimatorSet().apply {
                playTogether(animX, animY)
                duration = 180
                interpolator = DecelerateInterpolator()
                start()
            }
        }
    }
}
