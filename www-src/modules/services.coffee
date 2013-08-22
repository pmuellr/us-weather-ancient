# Licensed under the Apache License. See footer for details.

LogService       = require "./services/LogService"
LocationsService = require "./services/LocationsService"

#-------------------------------------------------------------------------------
module.exports = (mod) ->
    addServices mod, {
        LogService    
        LocationsService
    }

#-------------------------------------------------------------------------------
addServices = (mod, services) ->
    injector = angular.injector()
    for name, fn of services
        factory = buildFactory injector, fn

        mod.factory name, factory

    return

#-------------------------------------------------------------------------------
buildFactory = (injector, fn) ->
    injectMethod = fn::inject

    injectMethod = null if typeof injectMethod isnt "function"

    if injectMethod
        injected = injector.annotate injectMethod
    else
        injected = []

    fn.factory = ->
        inst = new fn
        injectMethod.apply inst, arguments if injectMethod
        return inst

    fn.factory.$inject = injected
    return fn.factory


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
