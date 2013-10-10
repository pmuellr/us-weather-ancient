# Licensed under the Apache License. See footer for details.

fs            = require "fs"
path          = require "path"
child_process = require "child_process"

require "shelljs/global"
_ = require "underscore"

#-------------------------------------------------------------------------------

module.exports = (grunt) ->

    grunt.initConfig

        readWrite: [
            "lib"
            "www"
        ]

        watch: 
            dirs: [
                "lib-src"
                "www-src"
            ]
            run: (grunt) ->
                runBuild grunt
                runServe grunt

        clean: [
            "bower_components"
            "lib"
            "node_modules"
            "tmp"
            "vendor"
            "www"
        ]

        icons: 
            dir:     "www-src/images"
            srcSize:  512
            dstSizes: "16 32 57 64 72 76 96 114 120 128 144 152 256 1024".split " "
        
        bower:
            "jquery":
                version: "2.0.3"
                files:
                    "jquery.js":                "vendor/jquery"
                    "jquery.min.js":            "vendor/jquery"
                    "jquery.min.map":           "vendor/jquery"

            "angular": 
                version: "1.2.x"
                files:
                    "angular.js":               "vendor/angular"
                    "angular.min.js":           "vendor/angular"
                    "angular.min.js.map":       "vendor/angular"

            "angular-route": 
                version: "1.2.x"
                files:
                    "angular-route.js":         "vendor/angular"
                    "angular-route.min.js":     "vendor/angular"
                    "angular-route.min.js.map": "vendor/angular"
                    
            "bootstrap": 
                version: "3.0.x"
                files:
                    "dist/css/*":               "vendor/bootstrap/css"
                    "dist/fonts/*":             "vendor/bootstrap/fonts"
                    "dist/js/*":                "vendor/bootstrap/js"
                    "assets/js/html5shiv.js":   "vendor/bootstrap/js"
                    "assets/js/respond.min.js": "vendor/bootstrap/js"
                    
            "font-awesome": 
                version: "3.2.x"
                files:
                    "css/*":                    "vendor/font-awesome/css"
                    "font/*":                   "vendor/font-awesome/font"

    #----------------------------------

    grunt.registerTask "default", ["help"]

    grunt.registerTask "help", "Display available commands", ->
        exec "grunt --help", @async()

    grunt.registerTask "build", "Build the server", ->
        runBuild grunt, @

    grunt.registerTask "serve", "Run the server", ->
        @async()
        runServe grunt, @

    grunt.registerTask "watch", "When src files change, re-build and re-serve", ->
        @async()
        runWatch grunt

    grunt.registerTask "vendor", "Get vendor files", ->
        runVendor grunt, @

    grunt.registerTask "clean", "Remove generated files", ->
        runClean grunt, @

    grunt.registerTask "icons", "Regenerate icons", ->
        runIcons grunt, @

#-------------------------------------------------------------------------------

runBuild = (grunt, task) ->
    unless test "-d", "vendor"
        log grunt, "installing vendor files since they aren't installed"
        runVendor grunt, task

    makeWritable  grunt, task
    runBuildMeat  grunt, task
    makeReadOnly  grunt, task

#-------------------------------------------------------------------------------

runBuildMeat = (grunt, task) ->

    timeStart = Date.now()

    mkdir "-p", "tmp"
    rm "-rf", "tmp/modules" if test "-d", "tmp/modules"

    #----------------------------------
    log grunt, "building server code in lib"

    mkdir "-p",  "lib"
    rm    "-rf", "lib/*"

    coffeec "--output lib lib-src/*.coffee"

    writeBuiltOn "lib/built-on.js"

    mkdir "-p",       "tmp/modules/server"
    cp "-R", "lib/*", "tmp/modules/server"

    #----------------------------------
    log grunt, "building client code in www"

    mkdir "-p",  "www"
    rm    "-rf", "www/*"

    modulesDir = "www/m"

    mkdir "-p",  "#{modulesDir}"
    rm    "-rf", "#{modulesDir}/*"

    dirs = "controllers directives filters services".split " "
    dirs.unshift ""

    for dir in dirs
        dir = "/#{dir}" if dir isnt ""

        coffeec "--output #{modulesDir}#{dir} www-src/modules#{dir}/*.coffee"

    cp "lib/built-on.js", "#{modulesDir}/built-on.js"
    cp "package.json",    "#{modulesDir}/package.json"

    files2module "www-src/views", "#{modulesDir}/views.js"

    if true
        browserify "--debug --outfile www/index.js #{modulesDir}/main.js"
        cp "-f", "www/index.js", "tmp/index.js"
        coffee "tools/split-sourcemap-data-url.coffee www/index.js"
    else
        cjsify "--verbose --output www/index.js --source-map www/index.js.map --alias fs: --alias child_process: #{modulesDir}/main.js"

    mkdir "-p",                    "tmp/modules/client"
    cp    "-R", "#{modulesDir}/*", "tmp/modules/client"
    rm "-rf", modulesDir


    mkdir "-p", "www/images"
    mkdir "-p", "www/vendor"

    cp "www-src/*.*",      "www"
    cp "www-src/images/*", "www/images"
    cp "-R", "vendor/*",   "www/vendor"

    rm "www/body.html"

    body = cat "www-src/body.html"
    sed "-i", /%body%/, body, "www/index.html"

    key = cat "Google-Maps-API-key.txt"
    sed "-i", /%Google-Maps-API-key\.txt%/, key, "www/index.html"

    createManifest "www", "www/index.appcache"   

    cp "www/index.html", "www/index-dev.html"
    sed "-i", /<html manifest="index.appcache"/, '<html class="dev"', "www/index-dev.html"

    timeElapsed = Date.now() - timeStart
    log grunt, "build time: #{timeElapsed/1000} sec"

    return

#-------------------------------------------------------------------------------

runServe = (grunt) ->
    serverStart grunt

    return

#-------------------------------------------------------------------------------

ServerPidFile = path.join __dirname, "tmp", "server.pid"

#-------------------------------------------------------------------------------
serverKill = (grunt, cb) ->

    return false unless test "-f", ServerPidFile

    pid = cat ServerPidFile
    pid = parseInt pid, 10
    # log grunt, "killing the server, pid: #{pid}"

    try
        process.kill pid
    catch e
        # log grunt, "error killing the server, already dead? pid: #{pid}, err: #{e}"

    rm ServerPidFile
    process.nextTick -> cb() if cb?

    return true

#-------------------------------------------------------------------------------

serverStart = (grunt) ->

    killed = serverKill grunt, -> serverStart grunt
    return if killed

    options = 
        stdio: "inherit"

    serverProcess = child_process.spawn "node", ["server.js"], options

    serverProcess.pid.toString().to ServerPidFile

    return

#-------------------------------------------------------------------------------
runWatch = (grunt, fileName=null, watchers=[]) ->
    return if watchers.tripped

    if fileName
        log grunt, "----------------------------------------------------"
        log grunt, "file changed: #{fileName} on #{new Date}" 

    if watchers.length
        for watcher in watchers
            fs.unwatchFile watcher

        watchers.splice 0, watchers.length
        watchers.tripped = true

    watchCfg   = grunt.config "watch"
    watchDirs  = watchCfg.dirs
    watchRun   = watchCfg.run

    if !watchRun?
        err grunt, "you didn't specify anything to run!"

    try 
        watchRun grunt
    catch e
        err grunt, "running watch meat: #{e}"

    watchFiles = []

    for dir in watchDirs
        files = ls "-RA", dir
        files = _.map files, (file) -> path.join dir, file

        watchFiles = watchFiles.concat files

    if _.isEmpty watchFiles
        err grunt, "no files to watch!"

    watchers = []
    watchers.tripped = false

    options = 
        persistent: true
        interval:   500

    for watchFile in watchFiles
        watchHandler = getWatchHandler grunt, watchFile, watchers
        fs.watchFile watchFile, options, watchHandler

        watchers.push watchFile

    fs.watchFile __filename, options, ->
        log grunt, "#{path.basename __filename} changed; exiting"
        process.exit 0
        return

    log grunt, "watching #{1 + watchFiles.length} files for changes"

    return

#-------------------------------------------------------------------------------
getWatchHandler = (grunt, watchFile, watchers) ->
    return (curr, prev) ->
        return if curr.mtime == prev.mtime

        runWatch grunt, watchFile, watchers

        return

#-------------------------------------------------------------------------------

runClean = (grunt) ->
    dirs = grunt.config "clean"

    makeWritable grunt

    for dir in dirs
        if test "-d", dir
            rm "-rf", dir

    return

#-------------------------------------------------------------------------------

runVendor = (grunt, task) ->
    rm "-rf", "bower_components"
    rm "-rf", "vendor"

    bowerConfig = grunt.config "bower"

    for target, data of bowerConfig
        runBower grunt, {target, data}

    return

#-------------------------------------------------------------------------------

runBower = (grunt, task) ->
    pkg     = task.target 
    version = task.data.version
    files   = task.data.files

    bower = which "bower"
    unless bower
        bower = "./node_modules/.bin/bower"

        unless test "-f", bower
            log grunt, "installing bower locally since it's not installed globally"
            exec "npm install bower"
            log grunt, ""

    exec "#{bower} install #{pkg}##{version}"
    log grunt, ""

    for srcFile, dstDir of files
        mkdir "-p", dstDir

        srcFile = path.join "bower_components", pkg, srcFile
        cp srcFile, dstDir

    return

#-------------------------------------------------------------------------------

runIcons = (grunt) ->
    {dir, srcSize, dstSizes} = grunt.config "icons"

    if !which "convert"
        log grunt, "ImageMagick convert not available, unable to create icons."
        return

    srcSize = align "#{srcSize}", "right", 4, "0"
    srcFile = "#{dir}/icon-#{srcSize}.png"

    dstSizes = _.map dstSizes, (dstSize) -> align dstSize, "right", 4, "0"

    for dstSize in dstSizes
        resizeOption = "-resize #{dstSize}x#{dstSize}"
        dstFile      = "#{dir}/icon-#{dstSize}.png"

        cmd = "convert #{resizeOption} #{srcFile} #{dstFile}"

        log grunt, cmd
        exec cmd

    if !which "iconutil"
        log grunt, "iconutil not available, unable to create icns."
        return

    mkdir "-p", "tmp/app.iconset"
    rm "-rf",   "tmp/app.iconset/*"

    cp "#{dir}/icon-0016.png", "tmp/app.iconset/icon_16x16.png"       if test "-f", "#{dir}/icon-0016.png"  
    cp "#{dir}/icon-0032.png", "tmp/app.iconset/icon_16x16@2x.png"    if test "-f", "#{dir}/icon-0032.png"      
    cp "#{dir}/icon-0032.png", "tmp/app.iconset/icon_32x32.png"       if test "-f", "#{dir}/icon-0032.png"  
    cp "#{dir}/icon-0064.png", "tmp/app.iconset/icon_32x32@2x.png"    if test "-f", "#{dir}/icon-0064.png"      
    cp "#{dir}/icon-0128.png", "tmp/app.iconset/icon_128x128.png"     if test "-f", "#{dir}/icon-0128.png"      
    cp "#{dir}/icon-0256.png", "tmp/app.iconset/icon_128x128@2x.png"  if test "-f", "#{dir}/icon-0256.png"          
    cp "#{dir}/icon-0256.png", "tmp/app.iconset/icon_256x256.png"     if test "-f", "#{dir}/icon-0256.png"      
    cp "#{dir}/icon-0512.png", "tmp/app.iconset/icon_256x256@2x.png"  if test "-f", "#{dir}/icon-0512.png"          
    cp "#{dir}/icon-0512.png", "tmp/app.iconset/icon_512x512.png"     if test "-f", "#{dir}/icon-0512.png"      
    cp "#{dir}/icon-1024.png", "tmp/app.iconset/icon_512x512@2x.png"  if test "-f", "#{dir}/icon-1024.png"          


    cmd = "iconutil -c icns -o #{dir}/app.icns tmp/app.iconset"
    log grunt, cmd
    exec cmd

    return

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

files2module = (dir, oFile) ->
    files = ls "-AR", dir

    content = []
    for file in files
        fullFile   = path.join dir, file
        fileContent = JSON.stringify cat fullFile
        content.push "exports['#{file}'] = #{fileContent};"

    content = content.join "\n"
    content.to oFile

    return

#-------------------------------------------------------------------------------

writeBuiltOn = (oFile) ->
    content = "exports.date = new Date('#{new Date().toISOString()}')"
    content.to oFile

    return

#-------------------------------------------------------------------------------

coffee = (command) ->
    exec "node_modules/.bin/coffee #{command}"
    return

#-------------------------------------------------------------------------------

coffeec = (command) ->
    exec "node_modules/.bin/coffee --bare --compile #{command}"
    return

#-------------------------------------------------------------------------------

browserify = (command) ->
    exec "node_modules/.bin/browserify #{command}"
    return

#-------------------------------------------------------------------------------

cjsify = (command) ->
    exec "node_modules/.bin/cjsify #{command}"
    return

#-------------------------------------------------------------------------------

makeWritable = (grunt) ->
    dirs = grunt.config "readWrite"

    for dir in dirs
        mkdir "-p", dir
        chmod "-R", "+w", dir

    return

#-------------------------------------------------------------------------------

makeReadOnly = (grunt) ->
    dirs = grunt.config "readWrite"

    for dir in dirs
        mkdir "-p", dir
        chmod "-R", "-w", dir

    return

#-------------------------------------------------------------------------------
getTime =  ->
    date = new Date()
    hh   = align.right date.getHours(),   2, 0
    mm   = align.right date.getMinutes(), 2, 0

    return "#{hh}:#{mm}"

#-------------------------------------------------------------------------------
err =  (grunt, message) ->
    log grunt, "error: #{message}"
    process.exit 1

#-------------------------------------------------------------------------------
log =  (grunt, message) ->
    if !grunt?
        throw Error "log(): grunt was null!"

    if message is ""
        grunt.log.writeln ""
        return

    grunt.log.writeln "#{getTime()} - #{message}"

    return

#-------------------------------------------------------------------------------
align = (s, direction, length, pad=" ") ->
    s   = "#{s}"
    pad = "#{pad}"

    direction = direction.toUpperCase()[0]

    if direction is "L"
        doPad = (s) -> s + pad
    else if direction is "R"
        doPad = (s) -> pad + s
    else
        throw Error "invalid direction argument for align()"

    while s.length < length
        s = doPad s

    return s

align.right = (s, length, pad=" ") -> align s, "right", length, pad
align.left  = (s, length, pad=" ") -> align s, "left",  length, pad    

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
