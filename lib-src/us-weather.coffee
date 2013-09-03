# Licensed under the Apache License. See footer for details.

URL  = require "url"
http = require "http"
util = require "util"

_          = require "underscore"
htmlParser = require "htmlparser"
soupSelect = require "soupselect"
select     = soupSelect.select

pkg  = require "../package.json"

weather = exports

URLprefix = "http://graphical.weather.gov/xml/sample_products/browser_interface/ndfdXMLclient.php"

DataNameMap = 
    "Temperature":                              "temp"
    "Dew Point Temperature":                    "dew"
    "Apparent Temperature":                     "appt"
    "12 Hourly Probability of Precipitation":   "pop12"
    "Liquid Precipitation Amount":              "qpf"
    "Snow Amount":                              "snow"
    "Ice Accumulation":                         "iceaccum"
    "Cloud Cover Amount":                       "sky"
    "Relative Humidity":                        "rh"

WeatherParms = _.values DataNameMap
WeatherParms = _.map WeatherParms, (parm) -> "#{parm}=#{parm}"
WeatherParms = WeatherParms.join "&"

#-------------------------------------------------------------------------------
main = (args) ->
    if args[0] is "serve"
        require "./server"

    else if args[0] is "locations"
        weather.getLocations (err, data) -> 
            if err
                err.weatherURL = err.weatherURL || "???"
                console.log "error accessing url #{err.weatherURL}: #{err}"
                if err.stack?
                    console.log "stack:\n#{err.stack}"

            console.log JL data if data?

    else if args.length is 1
        zip = parseInt args[0], 10
        help() if isNaN zip
        weather.getWeatherByZip zip, (err, data) ->
            if err
                err.weatherURL = err.weatherURL || "???"
                console.log "error accessing url #{err.weatherURL}: #{err}"
                if err.stack?
                    console.log "stack:\n#{err.stack}"

            console.log JL data if data?

    else if args.length is 2
        lat = parseFloat args[0]
        lon = parseFloat args[1]
        help() if isNaN lat or isNaN lon
        weather.getWeatherByGeo lat, lon, (err, data) ->  
            if err
                err.weatherURL = err.weatherURL || "???"
                console.log "error accessing url #{err.weatherURL}: #{err}"
                if err.stack?
                    console.log "stack:\n#{err.stack}"

            console.log JL data if data?

    else
        help()

#-------------------------------------------------------------------------------
help = ->
    console.log "usage:"
    console.log "    #{pkg.name} <arguments>"
    console.log ""
    console.log "arguments:"
    console.log "    serve       - start an http server"
    console.log "    locations   - display locations"
    console.log "    <num>       - weather for zip code"
    console.log "    <num> <num> - weather for latitude / longitude"
    process.exit(1)

#-------------------------------------------------------------------------------
weather.getLocations = (callback) ->
    callback = getOneTimeInvoker callback

    url = "#{URLprefix}?listCitiesLevel=1234"

    getHttp url, (err, body) ->
        if err?
            err.weatherURL = url
            return callback err 

        try 
            handle_getLocations body, callback
        catch err
            err.weatherURL = url
            callback err

    return

#-------------------------------------------------------------------------------
weather.getWeatherByZip = (zipcode, callback) ->
    parsedZipcode = parseInt "#{zipcode}"
    if isNaN parsedZipcode
        callback Error("zipcode value is not an integer")
        return

    callback = getOneTimeInvoker callback

    url = "#{URLprefix}?product=time-series&zipCodeList=#{zipcode}" # &#{WeatherParms}"

    # console.log url
    getHttp url, (err, body) ->
        if err?
            err.weatherURL = url
            return callback err 

        try
            handle_getWeather body, callback
        catch err
            err.weatherURL = url
            callback err

    return

#-------------------------------------------------------------------------------
weather.getWeatherByGeo = (lat, lon, callback) ->
    parsedLat = parseFloat "#{lat}"
    if isNaN parsedLat
        callback Error("latitude value is not a number")
        return

    parsedLon = parseFloat "#{lon}"
    if isNaN parsedLon
        callback Error("longitude value is not a number")
        return

    callback = getOneTimeInvoker callback

    url = "#{URLprefix}?product=time-series&listLatLon=#{lat},#{lon}&#{WeatherParms}"

    # console.log url
    getHttp url, (err, body) ->
        if err?
            err.weatherURL = url
            return callback err 

        try
            handle_getWeather body, callback
        catch err
            err.weatherURL = url
            callback err

    return

#-------------------------------------------------------------------------------
handle_getLocations = (xml, callback) ->

    dom = parseXML xml

    llList = getText select dom, "latlonlist"
    cnList = getText select dom, "citynamelist"

    llList = llList.split " "
    cnList = cnList.split "|"

    result = []

    for i in [0...llList.length]
        ll = llList[i]
        cn = cnList[i]

        [lat,  lon] = ll.split ","
        [city, st ] = cn.split ","

        lat = parseFloat lat
        lon = parseFloat lon

        result.push {lat, lon, city, st}

    callback(null, result)

    return

#-------------------------------------------------------------------------------
handle_getWeather = (xml, callback) ->
    # console.log "handle_getWeather(#{xml})"
    result = {}

    dom = parseXML xml

    result.date = getDate select dom, "creationdate"

    point = select(dom, "data location point")[0]

    result.lat = parseFloat point.attribs.latitude
    result.lon = parseFloat point.attribs.longitude

    timeLayouts = getTimeLayouts dom
    # console.log "layouts: #{JL timeLayouts}"

    result.data = {}

    dataSets = [
        [ 'temperature[type="hourly"]',   valueParserInt   ]
        [ 'temperature[type="dewpoint"]', valueParserInt   ]
        [ 'temperature[type="apparent"]', valueParserInt   ]
        [ 'precipitation[type="liquid"]', valueParserFloat ]
        [ 'precipitation[type="snow"]',   valueParserFloat ]
        [ 'precipitation[type="ice"]',    valueParserFloat ]
        [ 'cloudamount',                  valueParserInt   ]
        [ 'probabilityofprecipitation',   valueParserInt   ]
        [ 'humidity',                     valueParserInt   ]
    ]

    for [selector, parser] in dataSets
        {name, values} = getParameterData dom, timeLayouts, selector, parser
        continue if !name?

        name = DataNameMap[name]
        result.data[name] = values

    callback null, result

    return

#-------------------------------------------------------------------------------
getParameterData = (dom, timeLayouts, elementName, parser) ->
    # console.log "getParameterData #{elementName}"

    elements = select dom, "data parameters #{elementName}"
    return {} if !elements[0]?

    layout   = elements[0].attribs["time-layout"]
    return {} if !layout?

    layout   = timeLayouts[layout]
    return {} if !layout?

    name     = getText select elements, "name"
    values   = select elements, "value"
    return {} if !name? or !values?

    # console.log name, layout

    rawValues = _.map values, (value) -> parser(value)

    len = Math.min values.length, layout.length

    values = []
    for i in [0...len]
        date  = layout[i]
        value = rawValues[i]

        values.push {date, value}

    return {name, values}

#-------------------------------------------------------------------------------
valueParserInt = (dom) ->
    text  = getText dom
    value = parseInt text, 10
    value = 0 if isNaN value
    return value

#-------------------------------------------------------------------------------
valueParserFloat = (dom) ->
    text  = getText dom
    value = parseFloat text
    value = 0.0 if isNaN value
    return value

#-------------------------------------------------------------------------------
getTimeLayouts = (dom) ->
    result = {}

    layoutElements = select dom, "timelayout"

    for layoutElement in layoutElements
        key = getText select layoutElement, "layoutkey"

        timeElements = select layoutElement, "startvalidtime"
        times = _.map timeElements, (timeElement) -> getDate timeElement

        result[key] = times

    return result

#-------------------------------------------------------------------------------
findElements = (nodes, tag, result) ->
    result = result || []

    for node in nodes
        if node.type is "tag"
            if node.name is tag
                result.push node

        if node.children?
            findElements(node.children, tag, result)

    return result

#-------------------------------------------------------------------------------
findElement = (nodes, tag, result) ->
    elements = findElements nodes, tag
    return elements[0]

#-------------------------------------------------------------------------------
getDate = (nodes) ->
    text = getText nodes
    date = new Date text
    return date.toISOString().replace("T", " ")

#-------------------------------------------------------------------------------
getText = (nodes, result) ->
    nodes = [nodes] if !_.isArray nodes

    result = result || ""

    for node in nodes

        if node.type is "text"
            result += node.data

        if node.children?
            result = getText(node.children, result)

    return result

#-------------------------------------------------------------------------------
parseXML = (body) ->
    result = null

    handler = new htmlParser.DefaultHandler (err, nodes) ->
        result = nodes if !err?

    parser = new htmlParser.Parser handler
    parser.parseComplete(body)

    normalizeElements result

    return result

#-------------------------------------------------------------------------------
# lowercase and remove - from element names
#-------------------------------------------------------------------------------
normalizeElements = (nodes) ->
    return if !nodes?

    nodes = [nodes] if !_.isArray nodes

    for node in nodes
        continue if node.type isnt "tag"

        node.name = node.name.toLowerCase()
        node.name = node.name.replace(/-/g,"")

        if node.attribs
            if node.attribs["type"]
                node.attribs["type"] = node.attribs["type"].replace /\s+/, ""
                # console.log "fixed type attribute: #{node.attribs["type"]}"

        normalizeElements node.children

    return

#-------------------------------------------------------------------------------
getHttp = (url, callback) ->
    urlParsed = URL.parse(url)
    request   = http.request(urlParsed)

    request.on "response", (response) ->
        body = ""

        response.setEncoding "utf8"

        response.on "data", (chunk) ->
            body += chunk

        response.on "end", ->
            if response.statusCode isnt 200
                err = Error "http status: #{response.statusCode}"
                err.weatherURL = url
                return callback err, body

            callback null, body

        response.on "error", (err) ->
            err.weatherURL = url
            return callback err, body

    request.on "error", (err) ->
        err.weatherURL = url
        return callback err

    request.end()

    return

#-------------------------------------------------------------------------------
getOneTimeInvoker = (callback) ->
    called = false

    return (err, data) ->
        return if called
        called = true
        callback err, data

#-------------------------------------------------------------------------------
JS = (object) -> JSON.stringify object
JL = (object) -> JSON.stringify object, null, 4

#-------------------------------------------------------------------------------
main(process.argv.slice 2) if require.main is module

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
