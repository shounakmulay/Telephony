package com.shounakmulay.flutter_sms

interface ISmsController {
  fun getInbox( projectionList: List<String>? = null): List<Map<String, Any>>
  fun getSent(projectionList: List<String>? = null): List<Map<String, Any>>
  fun getDraft(projectionList: List<String>? = null): List<Map<String, Any>>
}
