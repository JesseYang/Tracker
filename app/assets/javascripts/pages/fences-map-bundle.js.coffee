//= require 'utility/ajax'


$ ->
  points = []
  overlay_ary = []
  status = "plot"

  center = new qq.maps.LatLng(window.center[0], window.center[1])
  map = new qq.maps.Map(document.getElementById('map-div'),{
    center: center,
    zoom: window.zoom})

  if (window.action == "show")
    status = 'finish'
    # initialize points and overlay
    points_ary = window.points.split('-')
    for point_str in points_ary
      value = point_str.split(',')
      points.push [parseFloat(value[0]), parseFloat(value[1])]
    path = []
    for point in points
      path.push new qq.maps.LatLng(point[0], point[1])
    polygon = new qq.maps.Polygon({
      path: path,
      strokeColor: '#000000',
      strokeWeight: 5,
      editable:false,
      map: map
    })
    overlay_ary.push polygon

  listener = qq.maps.event.addListener(map, "click", (event) ->
    console.log('您点击的位置为: [' + event.latLng.getLat() + ', ' + event.latLng.getLng() + ']');
    return if status == 'finish'

    points.push [event.latLng.getLat(), event.latLng.getLng()]

    return if points.length == 1

    p1 = points[points.length - 2]
    p2 = points[points.length - 1]
    polyline = new qq.maps.Polyline({
      path: [
          new qq.maps.LatLng(p1[0], p1[1]),
          new qq.maps.LatLng(p2[0], p2[1])
      ],
      strokeColor: '#000000',
      strokeWeight: 5,
      editable:false,
      map: map
    })
    overlay_ary.push polyline
  )

  listener = qq.maps.event.addListener(map, "rightclick", (event) ->
    console.log('您右击的位置为: [' + event.latLng.getLat() + ', ' + event.latLng.getLng() + ']');
    return if status == 'finish'

    return if points.length < 2

    points.push [event.latLng.getLat(), event.latLng.getLng()]

    p1 = points[points.length - 2]
    p2 = points[points.length - 1]
    p3 = points[0]
    polyline = new qq.maps.Polyline({
      path: [
          new qq.maps.LatLng(p1[0], p1[1]),
          new qq.maps.LatLng(p2[0], p2[1]),
          new qq.maps.LatLng(p3[0], p3[1])
      ],
      strokeColor: '#000000',
      strokeWeight: 5,
      editable:false,
      map: map
    })
    overlay_ary.push polyline
    status = 'finish'
  )

  $("#fence-reset").click ->
    points = []
    for overlay in overlay_ary
      overlay.setVisible(false)
    status = 'plot'
    false

  $("#fence-ok").click ->
    device_id = $(this).data("device-id")
    $.postJSON(
      '/devices/' + device_id + '/fences',
      {
        fence: {
          name: $("#fence-name input").val(),
          enabled: $("#fence-enabled input").is(":checked"),
          points: points
        }
      },
      (retval) ->
        console.log retval
        window.location.href = "/devices/" + device_id + "/fences"
    false
    )

  $("#fence-update").click ->
    device_id = $(this).data("device-id")
    fence_id = $(this).data("fence-id")
    $.putJSON(
      '/devices/' + device_id + '/fences/' + fence_id,
      {
        fence: {
          name: $("#fence-name input").val(),
          enabled: $("#fence-enabled input").is(":checked"),
          points: points
        }
      },
      (retval) ->
        $("#app-notification").notification({content: "更新成功"})
    false
    )
