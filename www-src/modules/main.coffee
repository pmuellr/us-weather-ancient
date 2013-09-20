# Licensed under the Apache License. See footer for details.

utils   = require "./utils"

mod = null

#-------------------------------------------------------------------------------
main = ->
    mod = angular.module "app", ["ngRoute"]

    register require "./controllers/Add"
    register require "./controllers/Body"
    register require "./controllers/Help"
    register require "./controllers/Home"
    register require "./controllers/Messages"
    register require "./controllers/Settings"
    register require "./directives/WChart"
    register require "./filters/LogTime"
    register require "./services/GMap"
    register require "./services/Logger"
    register require "./services/Locations"
    
    register require "./routes"

#-------------------------------------------------------------------------------
register = (fn) ->
    fn mod

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
