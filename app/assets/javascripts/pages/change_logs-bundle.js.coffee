#= require bootstrap-datetimepicker.js
#= require bootstrap-datetimepicker.zh-CN.js
$ ->
  $(".form_datetime").datetimepicker
    language:  'zh-CN',
    weekStart: 1
    todayBtn: 1
    autoclose: 1
    todayHighlight: 1
    startView: 2
    forceParse: 0
    showMeridian: 1
