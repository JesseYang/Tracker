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
  $("#start_input").val(window.start_str)
  $("#end_input").val(window.end_str)
