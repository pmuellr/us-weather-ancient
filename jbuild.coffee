# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------

fs            = require "fs"
path          = require "path"
child_process = require "child_process"

_ = require "underscore"

__basename = path.basename __filename

#-------------------------------------------------------------------------------

Config = 

    server:
        cmd: "server"
        pidFile: path.join __dirname, "tmp", "server.pid"

    watch: [ "lib-src/**/*", "www-src/**/*" ]

    clean: [
        "bower_components"
        "node_modules"
        "tmp"
    ]

    bower:
        jquery:
            version: "2.0.x"
            files:
                "jquery.js":                    "."

        angular: 
            version: "1.0.x"
            files:
                "angular.js":                   "."

        bootstrap: 
            version: "3.0.x"
            files:
                "dist/css/bootstrap.css":       "css"
                "dist/css/bootstrap-theme.css": "css"
                "dist/fonts/*":                 "fonts"
                "dist/js/bootstrap.js":         "js"
                
        "font-awesome": 
            version: "3.2.x"
            files:
                "css/font-awesome.css":         "css"
                "css/font-awesome-ie7.css":     "css"
                "font/*":                       "font"


#-------------------------------------------------------------------------------
exports.build =
    doc: "build the server"
    run: -> taskBuild()

#-------------------------------------------------------------------------------
exports.serve =
    doc: "run the server"
    run: -> taskServe()

#-------------------------------------------------------------------------------
exports.watch =
    doc: "watch for source changes, re-build and re-serve"
    run: -> taskWatch()

#-------------------------------------------------------------------------------
exports.bower =
    doc: "get bower files"
    run: -> taskBower()

#-------------------------------------------------------------------------------
exports.clean =
    doc: "clean up transient junk"
    run: -> taskClean

#-------------------------------------------------------------------------------
taskBuild = ->
    timeStart = Date.now()

    #----------------------------------
    log "building server code in lib"

    cleanDir "lib"

    coffeec "--output lib lib-src/*.coffee"

    createBuiltOn "lib/builtOn.json"

    #----------------------------------
    log "building client code in www"

    cleanDir "www", "tmp/ang"

    cp "-R", "www-src/index.*", "www"
    cp "-R", "www-src/images",  "www"

    cp "-R", "www-src/ang/*",  "tmp/ang"
    cp "package.json",         "tmp/ang"
    createBuiltOn              "tmp/ang/builtOn.json"

    angTangle "tmp/ang www/index.js"
    browserify """
        --require process
        --require events
        --require underscore
        --outfile www/node-modules.js
        --debug
    """.replace /\s+/g, " "

    splitSourceMap = ->
        coffee "tools/split-sourcemap-data-url.coffee www/node-modules.js"

    setTimeout splitSourceMap, 200

    taskBower() unless test "-d", "bower_components"

    for name, {version, files} of Config.bower
        for srcFile, dstDir of files
            srcFile = path.join "bower_components", name, srcFile
            dstDir  = path.join "www", "bower",     name, dstDir

            mkdir "-p", dstDir
            cp srcFile, dstDir


    createManifest "www", "www/index.appcache"   

    cp "www/index.html", "www/index-dev.html"
    sed "-i", /<html manifest="index.appcache"/, '<html class="dev"', "www/index-dev.html"

    timeElapsed = Date.now() - timeStart
    # log "build time: #{timeElapsed/1000} sec"

    return

#-------------------------------------------------------------------------------
taskServe = ->
    server.start Config.server.pidFile, "node", Config.server.cmd.split(" ")

#-------------------------------------------------------------------------------
taskWatch = ->
    taskBuild()
    taskServe()

    watch
        files: Config.watch
        run: -> 
            taskBuild()
            taskServe()

    watch
        files: __basename
        run: -> 
            echo "file #{__basename} changed; exiting"
            server.kill Config.server.pidFile
            process.exit 0

#-------------------------------------------------------------------------------
taskClean = ->
    for dir in Config.clean
        if test "-d", dir
            rm "-rf", dir

#-------------------------------------------------------------------------------

taskBower = ->
    cleanDir "bower_components"

    unless which "bower"
        logError "bower must be globally installed"

    for name, {version, files} of Config.bower
        exec "bower install #{name}##{version}"
        log ""

#-------------------------------------------------------------------------------
cleanDir = (dirs...) ->
    for dir in dirs
        mkdir "-p",  dir
        rm "-rf", "#{dir}/*"

#-------------------------------------------------------------------------------
createManifest = (dir, oFile) ->
    files = ls "-AR", dir
    files = _.reject files, (file) ->
        test "-d", path.join dir, file

    content = """
        CACHE MANIFEST
        # created on #{new Date()}

        CACHE:

        #{files.join "\n"}

        NETWORK:
        *
    """.trim()

    content.to oFile

    return

#-------------------------------------------------------------------------------
createBuiltOn = (oFile) ->
    content = JSON.stringify {date: new Date}, null, 4
    content.to oFile

#-------------------------------------------------------------------------------

coffee     = (parms) ->  pexec "coffee #{parms}"
coffeec    = (parms) ->  coffee "--bare --compile #{parms}"
angTangle  = (parms) ->  pexec "ang-tangle #{parms}"
browserify = (parms) ->  pexec "browserify #{parms}"

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
