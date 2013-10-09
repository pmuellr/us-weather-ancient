# Licensed under the Apache License. See footer for details.

_ = require "underscore"

utils   = require "./utils"

amod = angular.module "app", ["ngRoute"]

controllers = 
    Add:        require "./controllers/Add"
    Body:       require "./controllers/Body"
    Help:       require "./controllers/Help"
    Home:       require "./controllers/Home"
    Messages:   require "./controllers/Messages"
    Settings:   require "./controllers/Settings"

directives = 
    WChart:     require "./directives/WChart"

filters =
    LogTime:    require "./filters/LogTime"

services =    
    GMap:       require "./services/GMap"
    Logger:     require "./services/Logger"
    Locations:  require "./services/Locations"

#-------------------------------------------------------------------------------
main = ->

    registerController  name, mod for name, mod of controllers
    registerDirective   name, mod for name, mod of directives
    registerFilter      name, mod for name, mod of filters
    registerService     name, mod for name, mod of services

    register require "./routes"

#-------------------------------------------------------------------------------
register = (fn) ->
    fn amod

#-------------------------------------------------------------------------------
registerController = (name, mod) ->
    fn = mod?.controller

    if !_.isFunction fn
        throw Error "controller module #{name} does not export a 'controller' function"

    amod.controller name, fn

#-------------------------------------------------------------------------------
registerDirective = (name, mod) ->
    fn = mod?.directive

    if !_.isFunction fn
        throw Error "directive module #{name} does not export a 'directive' function"

    amod.directive name, fn

#-------------------------------------------------------------------------------
registerFilter = (name, mod) ->
    fn = mod?.filter

    if !_.isFunction fn
        throw Error "filter module #{name} does not export a 'filter' function"

    amod.filter name, fn

#-------------------------------------------------------------------------------
registerService = (name, mod) ->
    cls = mod?.service

    if !_.isFunction cls
        throw Error "service module #{name} does not export a 'service' class"

    amod.service name, mod.service

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
