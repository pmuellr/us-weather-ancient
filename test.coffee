# Licensed under the Apache License. See footer for details.

weather = require "./lib/us-weather"

Wilmington = 
    lat:  34.27
    lon: -77.92
    zip:  28405

Raleigh = 
    lat:  35.87
    lon: -78.78
    zip:  27511

{lat, lon, zip} = Raleigh

#-------------------------------------------------------------------------------
run = (fname, fn) ->
    fn(fname)
    return

#-------------------------------------------------------------------------------
run "getLocations", (fn) ->

    console.log "calling #{fn}()"

    weather[fn] (err, locations) ->
        if err
            console.log "#{fn}: error: #{err}"
            console.log err.stack
            return

        console.log "#{fn}: #{JSON.stringify locations, null, 4}"

#-------------------------------------------------------------------------------
run "getWeatherByGeo", (fn) ->

    console.log "calling #{fn}(#{lat}, #{lon})"

    weather[fn] lat, lon, (err, weather) ->
        if err
            console.log "#{fn}: error: #{err}"
            console.log err.stack
            return

        console.log "#{fn}: #{JSON.stringify weather, null, 4}"

#-------------------------------------------------------------------------------
run "getWeatherByZip", (fn) ->

    console.log "calling #{fn}(#{zip})"

    weather[fn] zip, (err, weather) ->
        if err
            console.log "#{fn}: error: #{err}"
            console.log err.stack
            return

        console.log "#{fn}: #{JSON.stringify weather, null, 4}"

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
