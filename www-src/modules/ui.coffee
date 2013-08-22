# Licensed under the Apache License. See footer for details.

weather = require "./us-weather"

ui = module.exports

#-------------------------------------------------------------------------------
Raleigh = 
    lat:  35.87
    lon: -78.78
    zip:  27511

{lat, lon, zip} = Raleigh

GraphTemp = GraphChance = GraphPrecip = null

#-------------------------------------------------------------------------------
watchWindowResizing = ->
    timeout = null

    #----------------------------------
    fireResizingComplete = ->
        $window = $(window)
        event = new CustomEvent "window-resizing-complete", 
            detail:
                width:  $window.width()
                height: $window.height()

        window.dispatchEvent event

    #----------------------------------
    $(window).resize ->
        clearTimeout(timeout) if timeout
        timeout = setTimeout(fireResizingComplete, 500)

#-------------------------------------------------------------------------------
watchWindowResizing()
$(window).bind "window-resizing-complete", (event) ->
    {width, height} = event.originalEvent.detail
    console.log {width, height}

#-------------------------------------------------------------------------------
start = ->

    $(".chartContainer").height( $(window).innerHeight() / 2 )
    $(".chartContainer").width(  $(window).innerWidth() )

    weather.getWeatherByZip zip, (err, weatherData) ->
        displayWeather weatherData

    $(window).resize ->
        $(".chartContainer").height( $(window).innerHeight() / 2 )
        $(".chartContainer").width(  $(window).innerWidth() )

        GraphTemp.render()   if GraphTemp?
        GraphChance.render() if GraphChance?
        GraphPrecip.render() if GraphPrecip?

#-------------------------------------------------------------------------------
displayWeather = (weatherData) ->
    utils.dump JSON.stringify weatherData, null, 4

    seriesTemp   = []
    seriesPrecip = []
    seriesChance = []


#-------------------------------------------------------------------------------
formatTemp = (y) ->
    return "#{y} F"

#-------------------------------------------------------------------------------
formatPrecip = (y) ->
    return "#{y} in"

#-------------------------------------------------------------------------------
formatChance = (y) ->
    return "#{y} %"


#-------------------------------------------------------------------------------
$(document).ready start

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
