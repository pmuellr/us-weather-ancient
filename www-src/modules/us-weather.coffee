# Licensed under the Apache License. See footer for details.

weather = exports

#-------------------------------------------------------------------------------
weather.getLocations = (callback) ->
    url = "/api/v1/weather-locations.json"
    httpGet url, callback
    return

#-------------------------------------------------------------------------------
weather.getWeatherByZip = (zipcode, callback) ->
    url = "/api/v1/weather-by-zip/#{zipcode}.json"

    httpGet url, (err, data) ->
        return callback err if err?
        callback null, data2series data

    return

#-------------------------------------------------------------------------------
weather.getWeatherByGeo = (lat, lon, callback) ->
    url = "/api/v1/weather-by-geo/#{lat},#{lon}.json"

    httpGet url, (err, data) ->
        return callback err if err?
        callback null, data2series data
        
    return

#-------------------------------------------------------------------------------
data2series = (data) ->
    oldSeries = data.data
    delete data.data

    newSeries = data.series = []

    for own name, points of oldSeries
        newData = []

        newSeries.push
            name:  name
            lat:   data.lat
            lon:   data.lon
            mtime: data.date
            data:  newData

        for {date, value} in points
            time = new Date(date).getTime()
            newData.push {time, value}

    return data

#-------------------------------------------------------------------------------
httpGet = (url, callback) ->
    return $.ajax 
        dataType:   "json"
        url:        url

        success:    (data, status, jqXHR) ->
            callback null, data

        error:      (jqXHR, status, error) ->
            errObj = new Error "jQuery.ajax error: #{status}"
            errObj.jqXHR  = jqXHR
            errObj.status = status
            errObj.error  = error
            callback errObj

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
