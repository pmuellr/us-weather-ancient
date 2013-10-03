# Licensed under the Apache License. See footer for details.

utils = require "../utils"

coreName = utils.coreName __filename

USGeoCenter = [39.828221, -98.579505]

#-------------------------------------------------------------------------------
module.exports = (mod) ->
    mod.controller coreName, AddController

    return

#-------------------------------------------------------------------------------
AddController = ($scope, Logger, GMap) ->
    Logger.log "controller #{coreName} created"

    $scope.gmap = GMap
    
    return if !GMap.isLoaded()

    $(".map-container").show()

    $scope.$on "$destroy", ->
        $(".map-container").hide()

    GMap.on "marker-moved", (latlng)->
        GMap.panTo latlng
        getLocationName latlng

    return

#-------------------------------------------------------------------------------
getLocationName = (latlng) ->
    console.log "got lat lng: #{latlng}"

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
