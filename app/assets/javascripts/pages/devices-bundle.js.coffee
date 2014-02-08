#= require utility/ajax
$ ->
  map = null
  size = new soso.maps.Size(42, 68)
  origin = new soso.maps.Point(0, 0)
  anchor = new soso.maps.Point(10, 30)
  end_marker = null
  start_marker = null
  interval = 1000
  demo_log_index = 2
  log_overlay = []
  logs = []
  current_type = "path"

  $("form").submit ->
    device_id = $(this).find("select").val()
    start_time = $(this).find("#start_input").val()
    end_time = $(this).find("#end_input").val()
    window.location.href = "/devices/#{device_id}/show_map?start_time=#{start_time}&end_time=#{end_time}"
    return false

  $("#circle").click ->
    plotLogs("circle")

  $("#polyline").click ->
    plotLogs("path")

  updateLog = -> 
    # use ajax to get the logs and refresh the map
    $.getJSON(
      '/devices/' + window.device_id + '/show_map.json',
      { demo: window.demo,
      log_index: demo_log_index,
      start_time: $("#start_input_shown").val(),
      end_time: $("#end_input_shown").val() },
      (retval) ->
        if window.demo == "true"
          demo_log_index += 1
        logs = retval.logs
        plotLogs(current_type)
    ) 
    setTimeout(updateLog, interval)

  plotLogs = (type) ->
    current_type = type
    if type == "path"
      for overlay in log_overlay
        overlay.setVisible(false)
      log_overlay = []
      path = []
      for log in logs
        path.push(new soso.maps.LatLng(log.lat_offset, log.lng_offset))
      polyline = new soso.maps.Polyline({
        path: path,
        strokeColor: '#000000',
        strokeWeight: 5,
        editable:false,
        map: map
      })
      log_overlay.push polyline

      if start_marker != null
        start_marker.setVisible(true)
      if end_marker != null
        end_marker.setVisible(false) # hide the previous marker
      if logs.length > 0
        end_log = logs[logs.length-1]
        end_p = new soso.maps.LatLng(end_log.lat_offset, end_log.lng_offset);
        end_marker = new soso.maps.Marker({
          position: end_p,
          map: map
        });
        end_icon =  new soso.maps.MarkerImage(
          "/assets/end.png", 
          size,
          origin,
          anchor
        );
        end_marker.setIcon(end_icon);
    else if type == "circle"
      for overlay in log_overlay
        overlay.setVisible(false)
      log_overlay = []
      if start_marker
        start_marker.setVisible(false)
      if end_marker
        end_marker.setVisible(false)
      for log in logs
        # plot a circle with radius 100 meters
        circle = new soso.maps.Circle({
            center: new soso.maps.LatLng(log.lat_offset, log.lng_offset),
            radius: 100,
            fillColor: new soso.maps.Color(0,0,255,0.2),
            strokeWeight: 0,
            map: map
        });
        log_overlay.push circle
    console.log log_overlay.length

  initialize = ->
    center = new soso.maps.LatLng(window.center[0], window.center[1])
    map = new soso.maps.Map(document.getElementById('container'),{
      center: center,
      zoom: window.zoom})

    if window.start != ""
      start = window.start.split(',')
      start_p = new soso.maps.LatLng(start[0], start[1])
      start_marker = new soso.maps.Marker({
        position: start_p,
        map: map
      });
      start_icon =  new soso.maps.MarkerImage(
        "/assets/start.png", 
        size,
        origin,
        anchor
      );
      start_marker.setIcon(start_icon);
    end

    if window.end != ""
      end = window.end.split(',')
      end_p = new soso.maps.LatLng(end[0], end[1]);
      end_marker = new soso.maps.Marker({
        position: end_p,
        map: map
      });
      end_icon =  new soso.maps.MarkerImage(
        "/assets/end.png", 
        size,
        origin,
        anchor
      );
      end_marker.setIcon(end_icon);
    end

    path = []
    logs = window.logs.split('-')
    for log in logs
      log = log.split(',')
      path.push(new soso.maps.LatLng(log[0], log[1]))
      logs.push({lat_offset: log[0], lng_offset: log[1]})
    polyline = new soso.maps.Polyline({
      path: path,
      strokeColor: '#000000',
      strokeWeight: 5,
      editable:false,
      map: map
    })
    log_overlay.push polyline

    setTimeout(updateLog, interval)

  initialize()
