package com.shounakmulay.flutter_sms.utils.enums

import com.shounakmulay.flutter_sms.utils.Constants

enum class ReturnType {
  JSON,
  MAP;
  
  companion object {
    fun fromString(string: String?): ReturnType {
      return when (string) {
        Constants.JSON -> JSON
        Constants.MAP -> MAP
        else -> MAP
      }
    }
  }
}