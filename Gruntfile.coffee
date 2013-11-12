# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------

fs            = require "fs"
path          = require "path"
zlib          = require "zlib"
child_process = require "child_process"

require "shelljs/global"
_ = require "underscore"

__basename = path.basename __filename

mkdir "-p", "tmp"

#-------------------------------------------------------------------------------

grunt = null

Config =

    watch:

        Gruntfile:
            files: __basename
            tasks: "gruntfile-changed"

        source:
            files: [ "lib-src/**/*", "www-src/**/*" ]
            tasks: "build-n-serve"
            options:
                atBegin: true

    server:
        cmd: "server"
        pidFile: path.join __dirname, "tmp", "server.pid"

    clean: [
        "bower_components"
        "node_modules"
        "tmp"
    ]

    browserify: [
        "d3"
        "events"
        "process"
        "path"
        "util"
        "underscore"
    ]

    gzip: [
        /.*\.css$/
        /.*\.js$/
        /.*\.svg$/
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

#-------------------------------------------------------------------------------
module.exports = (Grunt) ->
    grunt = Grunt

    grunt.initConfig Config

    grunt.registerTask "default", ["help"]

    grunt.registerTask "help", "print help", ->
        exec "grunt --help"

    grunt.loadNpmTasks "grunt-contrib-watch"

    grunt.registerTask "build", "run a build", ->
        build()

    grunt.registerTask "serve", "run the server", ->
        serve()

    grunt.registerTask "bower", "get bower files", ->
        bower()

    grunt.registerTask "clean", "remove transient files", ->
        clean()

    grunt.registerTask "----------------", "remaining tasks are internal", ->

    grunt.registerTask "serverStart", "start the server", ->
        serverStart()

    grunt.registerTask "serverStop", "stop the server", ->
        serverStop()

    grunt.registerTask "build-n-serve", "run a build, start the server", ->
        grunt.task.run ["build", "serve"]

    grunt.registerTask "gruntfile-changed", "exit when the Gruntfile changes", ->
        grunt.log.write "Gruntfile changed, maybe you wanna exit and restart?"


#-------------------------------------------------------------------------------
build = ->
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

    log "ang-tangle tmp/ang www/index.js"
    angTangle "tmp/ang www/index.js"

    args = _.map Config.browserify, (module) -> "--require #{module}"
    args.push "--outfile www/node-modules.js"
    args.push "--debug"

    log "browserify'ing: #{Config.browserify.join " "}"
    browserify args.join " "

    coffee "tools/split-sourcemap-data-url.coffee www/node-modules.js"

    bower() unless test "-d", "bower_components"

    for name, {version, files} of Config.bower
        for srcFile, dstDir of files
            srcFile = path.join "bower_components", name, srcFile
            dstDir  = path.join "www", "bower",     name, dstDir

            mkdir "-p", dstDir
            cp srcFile, dstDir


    createManifest "www", "www/index.appcache"   

    wwwFiles = ls "-R", "www"

    gzipped = 0
    for file in wwwFiles
        wwwFile = path.join "www", file
        for pattern in Config.gzip
            if wwwFile.match pattern
                gzFile = path.join "www", "gz", file

                mkdir "-p", path.dirname gzFile
                gzipFile wwwFile, gzFile

                gzipped++

    log "gzip'd #{gzipped} files"

    cp "www/index.html", "www/index-dev.html"
    sed "-i", /<html manifest="index.appcache"/, '<html class="dev"', "www/index-dev.html"

    timeElapsed = Date.now() - timeStart
    log "build time: #{timeElapsed/1000} sec"

    return

#-------------------------------------------------------------------------------
serve = ->
    grunt.task.run ["serverStop", "serverStart"]

#-------------------------------------------------------------------------------
serverStart = ->
    serverSpawn Config.server.pidFile, "node", Config.server.cmd.split(" ")

#-------------------------------------------------------------------------------
serverStop = ->
    serverKill Config.server.pidFile

#-------------------------------------------------------------------------------
clean = ->
    for dir in Config.clean
        if test "-d", dir
            rm "-rf", dir

#-------------------------------------------------------------------------------
bower = ->
    cleanDir "bower_components"

    unless which "bower"
        logError "bower must be globally installed"

    for name, {version, files} of Config.bower
        exec "bower install #{name}##{version}"
        log ""

#-------------------------------------------------------------------------------
gzipFile = (iFile, oFile) ->
    gzip = zlib.createGzip()

    iStream = fs.createReadStream  iFile
    oStream = fs.createWriteStream oFile

    iStream.pipe(gzip).pipe(oStream)

#-------------------------------------------------------------------------------
cleanDir = (dirs...) ->
    for dir in dirs
        mkdir "-p",  dir
        rm "-rf", "#{dir}/*"

#-------------------------------------------------------------------------------
createManifest = (dir, oFile) ->
    files = ls "-AR", dir
    files = _.reject files, (file) ->
        return true if test "-d", path.join dir, file
        return true if file.match /\.map$/
        return true if file.match /\.map\.json$/
        return false

    content = """
        CACHE MANIFEST
        # created on #{new Date()}

        CACHE:

        #{files.join "\n"}

        NETWORK:
        *
    """.trim()

    content.to oFile

#-------------------------------------------------------------------------------
createBuiltOn = (oFile) ->
    content = JSON.stringify {date: new Date}, null, 4
    content.to oFile

#-------------------------------------------------------------------------------
serverSpawn = (pidFile, cmd, args, opts={}) ->
    console.log "serverStart #{pidFile}, #{cmd}, #{args.join " "}"
    opts.stdio = "inherit"

    serverProcess = grunt.util.spawn {cmd, args, opts}, ->

    serverProcess.pid.toString().to pidFile

#-------------------------------------------------------------------------------
serverKill = (pidFile) ->
    return unless test "-f", pidFile

    pid = cat pidFile
    pid = parseInt pid, 10
    rm pidFile

    try
        process.kill pid
    catch e

#-------------------------------------------------------------------------------

coffee     = (parms) ->  exec "node_modules/.bin/coffee #{parms}"
coffeec    = (parms) ->  coffee "--bare --compile #{parms}"
angTangle  = (parms) ->  exec "node_modules/.bin/ang-tangle #{parms}"
browserify = (parms) ->  exec "node_modules/.bin/browserify #{parms}"

#-------------------------------------------------------------------------------
log = (message) ->
    grunt.log.write "#{message}\n"

#-------------------------------------------------------------------------------
logError = (message) ->
    grunt.fail.fatal "#{message}\n"

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
