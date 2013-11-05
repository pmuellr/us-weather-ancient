# Licensed under the Apache License. See footer for details.

path = require "path"

optimist    = require "optimist"
configChain = require "config-chain"

pkg    = require "../package.json"
server = require "./server"

#-------------------------------------------------------------------------------
exports.run = ->
    argv = optimist.argv

    configFile = "config.json"
    configFile = argv.config if argv.config

    env = {}
    env.port    = process.env.PORT          if process.env.PORT
    env.port    = process.env.VCAP_APP_PORT if process.env.VCAP_APP_PORT
    env.gmapKey = process.env.GMAP_KEY      if process.env.GMAP_KEY

    configs = [
        argv
        env
        configFile
        port:    3000
        verbose: false
    ]

    config = configChain.apply null, configs

    help() if (config.get "help") or (config.get "h") or (config.get "?")
    help() if "?" in argv._

    options =
        gmapKey : config.get "gmapKey"
        port    : config.get "port"
        verbose : config.get "verbose"
        version : config.get "version"

    options.port = parseInt "#{options.port}", 10

    if options.version
        console.log pkg.version
        process.exit 0

    if options.verbose
        console.log "config file: #{configFile}"
        console.log "options:"
        console.log "   gmapKey : #{options.gmapKey}"
        console.log "   port    : #{options.port   }"

    server.main options

#-------------------------------------------------------------------------------
help = ->

    console.log """
        #{pkg.name} version: #{pkg.version}

        usage:
            node server <options>

        options:
            --config <file>  config file
            --gmapKey <key>  Google Maps API key
            --port <num>     HTTP port to run on
            --verbose        log messages verbosely
            --version        print the version
            --help           print this help

        You can specify a `port` value in the VCAP_APP_PORT or PORT environment 
        variables.

        You can specify a `gmapKey` value in the GMAP_KEY environment variable.

        You can also use a `config.json` file.  A default config
        file of `config.json` (in current directory) will be used,
        but you can override it with the `--config` option.
        The property names in that config file are the option names above.

        Command-line overrides environment variables overrides config file.
    """

    process.exit 1

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
