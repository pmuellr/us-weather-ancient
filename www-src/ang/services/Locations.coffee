# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
AngTangle.service class LocationsService

    #---------------------------------------------------------------------------
    constructor: (@$window, @Logger) ->

    #---------------------------------------------------------------------------
    save: ->

    #---------------------------------------------------------------------------
    load: ->

    #---------------------------------------------------------------------------
    add: (location) ->

    #---------------------------------------------------------------------------
    remove: (location) ->

    #---------------------------------------------------------------------------
    refresh: () ->


#-------------------------------------------------------------------------------
class Locations

    KEY = "us-weather.locations"

    InitialLocations = [
        { lat: 35.870, lon: -78.780, name: "Raleigh-Durham, NC"  }
        { lat: 39.046, lon: -84.662, name: "Cincinnati, OH"      }
        { lat: 38.130, lon: -78.450, name: "Charlottesville, VA" }
    ]

    #---------------------------------------------------------------------------
    inject: (@Logger) ->

        @Logger.log "#{@constructor.name} created"

        @_load()

    #---------------------------------------------------------------------------
    save: ->
        localStorage.setItem KEY, JSON.stringify {
            @_lastId
            @locations
        }

        return

    #---------------------------------------------------------------------------
    _load: ->
        json = localStorage.getItem KEY
        json = "{}" if !json

        try 
            parsed = JSON.parse json
        catch e
            parsed = {}

        if !_.isObject parsed or _.isArray parsed or !parsed?
            parsed = {} 

        _.defaults parsed, 
            _lastId:    0
            locations:  []

        {
            @_lastId 
            @locations
        } = parsed

        if !@locations.length
            for location in InitialLocations
                {lat, lon, name} = location
                @add lat, lon, name, {dontSave: true, dontRefresh: true}

            @save()

        @refreshData()

        return        

    #---------------------------------------------------------------------------
    add: (lat, lon, name, options) ->
        id  = @_lastId++

        location = {lat, lon, name, id}

        @locations.unshift location

        @save()                        unless options?.dontSave
        @refreshLocationData location  unless options?.dontRefresh

        return

    #---------------------------------------------------------------------------
    remove: (id) ->
        index = -1
        for i in [0 ... @locations.length]
            if @locations[i].id is id
                index = i
                break

        return if index is -1

        @locations.splice index, 1

        return

    #---------------------------------------------------------------------------
    refreshData: ->
        for location in @locations
            @refreshLocationData location

        return

    #---------------------------------------------------------------------------
    refreshLocationData: (location) ->

        weather.getWeatherByGeo location.lat, location.lon, (err, data) =>
            if err
                @Logger.log "error reading data for #{location.name}: #{err}"
                return

            @Logger.log "retrieved weather data for #{location.name}"
            location.data = data

            @refreshMinMax()

            @save()

        return

    #---------------------------------------------------------------------------
    refreshMinMax: ->
        minTime  =  Infinity
        maxTime  = -Infinity
        minTemp  =  Infinity
        maxTemp  = -Infinity
        minDepth =  Infinity
        maxDepth = -Infinity

        for location in @locations
            for series in location.data.series
                for datum in series.data
                    minTime  = datum.time  if datum.time  < minTime
                    maxTime  = datum.time  if datum.time  > maxTime

                    if TempNames[series.name]
                        minTemp  = datum.value if datum.value < minTemp
                        maxTemp  = datum.value if datum.value > maxTemp


                    else if DepthNames[series.name]
                        minDepth = datum.value if datum.value < minDepth
                        maxDepth = datum.value if datum.value > maxDepth

        for location in @locations
            location.minTime  = minTime
            location.maxTime  = maxTime
            location.minTemp  = minTemp
            location.maxTemp  = maxTemp
            location.minDepth = minDepth
            location.maxDepth = maxDepth

TempNames = 
    temp:       true
    dew:        true
    appt:       true

DepthNames = 
    qpf:        true
    snow:       true
    iceaccum:   true

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
