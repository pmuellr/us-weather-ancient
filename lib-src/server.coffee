# Licensed under the Apache License. See footer for details.

http = require "http"
path = require "path"

express  = require "express"
lruCache = require "lru-cache"

weather = require "./us-weather"

PROGRAM = "#{path.basename path.dirname __dirname} server"
WWWDIR  = path.join __dirname, "../www"
VENDOR  = path.join __dirname, "../vendor"

CACHE_GC_MINS     = 5
CACHE_ENTRIES_MAX = 500
CACHE_MAX_AGE_HRS = 1

Locations = null

WeatherCache = lruCache
    max:    CACHE_ENTRIES_MAX
    maxAge: CACHE_MAX_AGE_HRS * 1000 * 60 * 60

#-------------------------------------------------------------------------------
main = ->
    port = process.env.VCAP_APP_PORT or process.env.PORT or "3000"
    port = parseInt port, 10

    favIcon = path.join WWWDIR, "images/icon-032.png"

    app = express()

    app.on 'error', (error) ->
        logError error

    # app.use setImage(cfsImage)
    # app.use setOptions(options)

    app.use express.favicon(favIcon)
    # app.use express.json(strict: false)
    # app.use express.urlencoded()

    app.use CORSify

    app.get "/api/v1/weather-locations.json",        logRequest, getLocations
    app.get "/api/v1/weather-by-geo/:lat,:lon.json", logRequest, getWeatherByGeo
    app.get "/api/v1/weather-by-zip/:zip.json",      logRequest, getWeatherByZip

    app.use express.errorHandler(dumpExceptions: true)

    app.use            express.static(WWWDIR)
    app.use "/vendor", express.static(VENDOR)

    log "starting server at http://localhost:#{port}"

    app.listen port

    setInterval cleanCache, CACHE_GC_MINS * 1000 * 60

#-------------------------------------------------------------------------------
permanentRedirectWithSlash = (path) ->
    return (request, response, next) ->
        return next() if request.path isnt path
        response.redirect 301, "#{path}/"

#-------------------------------------------------------------------------------
CORSify = (request, response, next) ->
    response.header "Access-Control-Allow-Origin:", "*"
    response.header "Access-Control-Allow-Methods", "GET"
    next()

#-------------------------------------------------------------------------------
logRequest = (request, response, next) ->
    log "#{request.method} #{request.url}"
    next()

#-------------------------------------------------------------------------------
cleanCache = ->
    log "cleanCache()"
    keys = WeatherCache.keys()
    for key in keys
        val = WeatherCache.get key
        if !val?
            log "   weather entry removed: #{key}"

#-------------------------------------------------------------------------------
getLocations = (request, response) ->
    if Locations?
        response.send Locations 
        return

    weather.getLocations (err, data) ->
        return handleError response, err if err?

        Locations = data
        response.send locations: Locations

#-------------------------------------------------------------------------------
getWeatherByZip = (request, response) ->
    zip = request.params.zip
    key = "#{zip}"

    value = WeatherCache.get key
    if value? 
        response.send value
        return

    weather.getWeatherByZip zip, (err, data) ->
        return handleError response, err if err?

        WeatherCache.set key, data
        response.send data

#-------------------------------------------------------------------------------
getWeatherByGeo = (request, response) ->
    lat = request.params.lat
    lon = request.params.lon
    key = "#{lat},#{lon}"

    value = WeatherCache.get key
    if value? 
        response.send value
        return

    weather.getWeatherByGeo lat, lon, (err, data) ->
        return handleError response, err if err?

        WeatherCache.set key, data
        response.send data

#-------------------------------------------------------------------------------
handleError = (response, err) ->
    response.send
        error: "#{err}"
        stack: "#{err.stack}"

    return

#-------------------------------------------------------------------------------
log = (message) ->
    console.log "#{PROGRAM}: #{logDate()} #{message}"

#-------------------------------------------------------------------------------
logError = (error) ->
    log "error: #{error}"
    log error.stack

#-------------------------------------------------------------------------------
logDate = () ->
    date = new Date()

    mon = date.getMonth() + 1
    day = date.getDate()
    hr  = date.getHours()
    min = date.getMinutes()
    sec = date.getSeconds()
    ms  = date.getMilliseconds()

    mon = alignRight "#{mon}" , 2, 0
    day = alignRight "#{day}" , 2, 0
    hr  = alignRight "#{hr }" , 2, 0
    min = alignRight "#{min}" , 2, 0
    sec = alignRight "#{sec}" , 2, 0
    ms  = alignRight "#{ms }" , 4, 0

    result = "#{mon}-#{day} #{hr}:#{min}:#{sec}.#{ms}"
    return result

#-------------------------------------------------------------------------------
alignRight = (string, length, pad) ->
    while string.length < length
        string = "#{pad}#{string}"

    string

#-------------------------------------------------------------------------------
main()

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
