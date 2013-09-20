# Licensed under the Apache License. See footer for details.

fs   = require "fs"
path = require "path"

PROGRAM = path.basename(__filename)

main = (iDir) ->

    error "expecting argument iDir" if !iDir?

    currPath = []
    try
        files = getFiles iDir
    catch e
        return error "error reading directory '#{iDir}: #{e}"

    console.log "CACHE MANIFEST"
    console.log ""
    console.log "# created by #{PROGRAM} on #{new Date()}"
    console.log ""

    console.log "CACHE:"
    for file in files
        console.log file
    console.log ""

    console.log "NETWORK:"
    console.log "*"

    return

#-------------------------------------------------------------------------------
getFiles = (dir, currPath="", collection=[]) ->

    files = fs.readdirSync(dir)

    for file in files
        fullName = path.join dir,      file
        currName = path.join currPath, file

        stats    = fs.statSync fullName

        if stats.isFile()
            collection.push currName

        else if stats.isDirectory()
            getFiles fullName, currName, collection

    return collection    

#-------------------------------------------------------------------------------
error = (message) ->
    log message
    process.exit 1

#-------------------------------------------------------------------------------
exit = (message) ->
    log message
    process.exit 0

#-------------------------------------------------------------------------------
log = (message) ->
    console.error "#{PROGRAM}: #{message}"

#-------------------------------------------------------------------------------
main.apply null, process.argv.slice 2

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
