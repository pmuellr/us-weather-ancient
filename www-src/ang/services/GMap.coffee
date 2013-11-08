# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
# info: https://developers.google.com/maps/documentation/javascript/
#-------------------------------------------------------------------------------

process = require "process"
events  = require "events"
_       = require "underscore"

Service     = null
GMapLoaded  = false

Logger = null
setLogger = (value) -> Logger = value

$rootScope = null
set$rootScope = (value) -> $rootScope = value

InfoWindowBusyHTML  = """
    <div>
        <p><p><p><p><p><p><p>
    </div>
"""

InfoWindowErrorHTML = """
    <div class='gmap-iw'>
        <h5>adding location</h5>
        <h3 class='gmap-iw-error'>invalid location</h3>
    </div>
"""

#-------------------------------------------------------------------------------
AngTangle.service class GMapService extends events.EventEmitter

    #---------------------------------------------------------------------------
    constructor: (@$window, Logger, $rootScope) ->
        Service = @

        setLogger     Logger
        set$rootScope $rootScope

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

try
    storedLatLng = JSON.parse localStorage.getItem "LastMarkerLatLng"
catch e

if storedLatLng?
    MarkerLatLng = new google.maps.LatLng storedLatLng.lat, storedLatLng.lng
else
    MarkerLatLng = new google.maps.LatLng 39.828221, -98.579505

Geocoder        = null
InfoWindow      = null
Map             = null
Marker          = null

#-------------------------------------------------------------------------------
init = ->
    google.maps.visualRefresh = true

    Geocoder    = new google.maps.Geocoder()
    InfoWindow  = new google.maps.InfoWindow {content: InfoWindowBusyHTML}

    mapElement = $(".map-container")[0]

    mapOptions =
        center:             MarkerLatLng
        zoom:               5
        mapTypeId:          google.maps.MapTypeId.ROADMAP
        panControl:         false
        mapTypeControl:     false
        streetViewControl:  false
        zoomControl:        true
        zoomControlOptions:
            position:       google.maps.ControlPosition.LEFT_CENTER

    Map = new google.maps.Map mapElement, mapOptions

    Marker = new google.maps.Marker
        position:   MarkerLatLng
        map:        Map
        draggable:  true
        title:      'select a new us-weather location!'

    onMarkerMoved(MarkerLatLng)

    google.maps.event.addListener Marker, "dragend", ->
        return if !Service?

        onMarkerMoved Marker.getPosition()

    google.maps.event.addListener Map, "click", (mouseEvent) ->
        return if !Service?

        onMarkerMoved mouseEvent.latLng

    InfoWindow.open Map, Marker

    google.maps.event.addListener InfoWindow, "closeclick", ->
        InfoWindow.open Map, Marker        

#-------------------------------------------------------------------------------
onMarkerMoved = (latLng) ->
    Marker.setPosition latLng
    Geocoder.geocode {latLng}, getGeocodeResult 
    # InfoWindow.setContent InfoWindowBusyHTML

    storedLatLng = 
        lat: latLng.lat()
        lng: latLng.lng()

    localStorage.setItem "LastMarkerLatLng", JSON.stringify storedLatLng

#-------------------------------------------------------------------------------
getGeocodeResult = (result, status) ->
    # console.log "geocode status: #{status}"
    # console.log "geocode result: #{JSON.stringify result, null, 4}"

    if status isnt "OK"
        InfoWindow.setContent InfoWindowErrorHTML
        return

    addresses = _.filter result, (address) ->
        for component in address.address_components
            continue unless component.types[0]   is "country"
            continue unless component.types[1]   is "political"
            continue unless component.short_name is "US"
            return true

        return false

    shortAddresses = []

    for address in addresses
        state  = null
        areas  = []

        for component in address.address_components
            if component.types[0] is "administrative_area_level_1"
                state = component.short_name

            if component.types[0] is "administrative_area_level_2"
                continue if component.short_name.length is 1
                areas.push component.short_name

            if component.types[0] is "administrative_area_level_3"
                continue if component.short_name.length is 1
                areas.push component.short_name

            if component.types[0] is "locality"
                continue if component.short_name.length is 1
                areas.push component.short_name

        if state
            for area in areas
                shortAddresses.push "#{area}, #{state}"
                shortAddresses.push "#{area}"

    addresses = shortAddresses
    addresses = _.uniq addresses

    if addresses.length is 0
        InfoWindow.setContent InfoWindowErrorHTML
        return

    iContent = []
    iContent.push """
        <div class='gmap-iw'>
            <h5>adding location</h5>
            <h3>click one of the names to add the location</h3>
    """

    for address in addresses
        iContent.push "<button type='button'>#{address}</button>"

    iContent.push "</div>"

    InfoWindow.setContent iContent.join "\n"

    $rootScope.$broadcast "location-selected", "some data"

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
