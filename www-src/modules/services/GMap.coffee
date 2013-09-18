# Licensed under the Apache License. See footer for details.

_ = require "underscore"

utils   = require "../utils"
weather = require "../us-weather"

Google_Maps_API_key = require "../Google-Maps-API-key"

coreName = utils.coreName __filename

#-------------------------------------------------------------------------------
module.exports = (mod) ->
    mod.service coreName, GMapService


#-------------------------------------------------------------------------------
class GMapService

    #---------------------------------------------------------------------------
    constructor: (@$window, @$q, @Logger) ->
        @ready         = false
        @loadError     = undefined
        @loadDeferreds = []

        GoogleMapsAPILoad @

    #---------------------------------------------------------------------------
    load: () ->
        deferred = @$q.defer()

        if @ready 
            deferred.resolve @
            return

        @loadDeferreds.push deferred

        return deferred.promise


    #---------------------------------------------------------------------------
    init: () ->
        @ready = true

        google.maps.visualRefresh = true

        @geocoder    = new google.maps.Geocoder()
        @infoWindow  = new google.maps.InfoWindow {content: ""}

#-------------------------------------------------------------------------------
GoogleMapsAPILoad = (service) ->
    service.ready     = true
    service.loadError = undefined

    script = document.createElement("script")
    script.type = "text/javascript"
    script.src  = [
        "https://maps.googleapis.com/maps/api/js?key=#{GoogleMapsAPIKey}"
        "sensor=false"
        "callback=GoogleMapsAPILoaded"
    ].join("&")

    window.GoogleMapsAPILoaded = ->
        GoogleMapsAPILoaded_ service

    setTimeout(
        -> GoogleMapsAPILoadTimeout service, 
        10 * 1000
    )

    document.body.appendChild script

#-------------------------------------------------------------------------------
GoogleMapsAPILoadTimeout = (service) ->
    return if service.ready

    service.loadError = "timeout waiting for Google Maps API to load"

    while service.loadDeferreds.length
        deferred = service.loadDeferreds.shift()
        deferred.reject Error service.loadError

    return

#-------------------------------------------------------------------------------
GoogleMapsAPILoaded_ = (service) ->
    return if service.ready

    service.ready = true

    while service.loadDeferreds.length
        deferred = service.loadDeferreds.shift()
        deferred.resolve service

###
var map
var marker
var locationEntry

//------------------------------------------------------------------------------
function InitializeMap() {

    var location   = new google.maps.LatLng(47.2, -121.3)
    var mapElement = $(".map-canvas")[0]
    var mapOptions = {
        center:     location,
        zoom:       3,
        mapTypeId:  google.maps.MapTypeId.ROADMAP
    }

    map = new google.maps.Map(mapElement, mapOptions)

    marker = new google.maps.Marker({
        position:   location,
        map:        map,
        draggable:  true,
        title:      'select a new us-weather location!'
    })

    google.maps.event.addListener(marker, "dragend", function() {
        var latlng = marker.getPosition()
        map.panTo(latlng)
        getLocationName(latlng)
    })

    google.maps.event.addListener(map, "zoom_changed", function() {
    })
}

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
