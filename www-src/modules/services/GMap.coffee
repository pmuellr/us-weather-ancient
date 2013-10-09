# Licensed under the Apache License. See footer for details.

events = require "events"

_ = require "underscore"

#-------------------------------------------------------------------------------

Service     = null
GMapLoaded  = false

#-------------------------------------------------------------------------------
exports.service = class GMapService extends events.EventEmitter

    #---------------------------------------------------------------------------
    constructor: (@$window, @Logger) ->
        Service = @

    #---------------------------------------------------------------------------
    isLoaded: ->
        return GMapLoaded

    #---------------------------------------------------------------------------
    panTo: (latlng) ->
        Map?.panTo latlng
        return

    #---------------------------------------------------------------------------
    triggerResize: ->
        return unless Map?

        process.nextTick =>
            google.maps.event.trigger Map, "resize"
            @panTo Marker.getPosition()
        return

#-------------------------------------------------------------------------------

USGeoCenter     = [39.828221, -98.579505]

Geocoder        = null
InfoWindow      = null
MarkerLocation  = null
Map             = null
Marker          = null

#-------------------------------------------------------------------------------
init = ->
    google.maps.visualRefresh = true

    Geocoder    = new google.maps.Geocoder()
    InfoWindow  = new google.maps.InfoWindow {content: ""}

    MarkerLocation   = new google.maps.LatLng USGeoCenter[0], USGeoCenter[1]

    mapElement = $(".map-container")[0]

    mapOptions =
        center:         MarkerLocation
        zoom:           3
        mapTypeId:      google.maps.MapTypeId.ROADMAP
        panControl:     false
        mapTypeControl: false
        zoomControl:    true
        zoomControlOptions:
            position:   google.maps.ControlPosition.LEFT_CENTER

    Map = new google.maps.Map mapElement, mapOptions

    Marker = new google.maps.Marker
        position:   MarkerLocation
        map:        Map
        draggable:  true
        title:      'select a new us-weather location!'

    google.maps.event.addListener Marker, "dragend", ->
        return if !Service?

        Service.emit "marker-moved", Marker.getPosition()

    google.maps.event.addListener Map, "click", (mouseEvent) ->
        return if !Service?

        Marker.setPosition mouseEvent.latLng
        Service.emit "marker-moved", mouseEvent.latLng


#-------------------------------------------------------------------------------
onMarkerMoved = (latLng) ->
    Marker.setPosition latLng
    Service.emit "marker-moved", latLng


#-------------------------------------------------------------------------------
checkForGMapsLoaded = ->
    return if GMapLoaded

    if window?.google?.maps?.version?
        GMapLoaded = true
        init()
        return

    setTimeout checkForGMapsLoaded, 500

#-------------------------------------------------------------------------------
$ checkForGMapsLoaded()

###


//------------------------------------------------------------------------------
function getLocationName(latlng) {
    geocoder.geocode({'latLng': latlng}, getLocationNameResult)
}

//------------------------------------------------------------------------------
function getLocationNameResult(results, status) {
    if (status != "OK") {
        infoWindow.close()
        return
    }

    console.log("-------------------------------------------------------------")
    console.log("status:  " + JSON.stringify(status,  null, 4))

    html = []
    html.push("<p>select a location name")
    html.push("<p><input class='locationInput'>")
    html.push("<button class='locationAdd'>add</button>")
    html.push("<p><select selectedIndex='-1' size='" + results.length + "' class='locationSelector'>")

    for (var i=0; i<results.length; i++) {
        var address = results[i].formatted_address
        address = $('<div/>').text(address).html()

        html.push("<option>" + address + "</option>")
        console.log(i + ": " + address)
    }

    html.push("</select>")

    infoWindow.setContent(html.join("\n"))  
    infoWindow.open(map, marker)

    $(".locationInput").val(results[0].formatted_address)

    $(".locationSelector").change(function(event){
        var index = event.target.selectedIndex
        var locName = results[index].formatted_address
        console.log("selected: " + locName)
        $(".locationInput").val(locName)
    })

    $(".locationAdd").click(function(thing){
        var locName = $(".locationInput").val()
        infoWindow.close()
        console.log("picked: " + locName)
    })
}

###



#-------------------------------------------------------------------------------
# Copyright 2013 Patrick Mueller
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------
