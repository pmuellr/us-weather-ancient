# Licensed under the Apache License. See footer for details.

_ = require "underscore"

utils   = require "../utils"

coreName = utils.coreName __filename

GMapLoaded = false

#-------------------------------------------------------------------------------
module.exports = (mod) ->
    mod.service coreName, GMap

    checkForGMapsLoaded()

#-------------------------------------------------------------------------------
class GMap

    #---------------------------------------------------------------------------
    constructor: (@$window, @Logger) ->

    #---------------------------------------------------------------------------
    isLoaded: ->
        return GMapLoaded

    #---------------------------------------------------------------------------
    init: () ->
        google.maps.visualRefresh = true

        @geocoder    = new google.maps.Geocoder()
        @infoWindow  = new google.maps.InfoWindow {content: ""}


#-------------------------------------------------------------------------------
checkForGMapsLoaded = ->
    return if GMapLoaded

    if window?.google?.maps?.version?
        GMapLoaded = true
        return

    setTimeout checkForGMapsLoaded, 500

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
