# Licensed under the Apache License. See footer for details.

process = require "process"

USGeoCenter = [39.828221, -98.579505]

#-------------------------------------------------------------------------------
AngTangle.controller add = ($scope, Logger, GMap) ->
    $scope.setSubtitle "add a location"

    $scope.gmap = GMap
    
    return if !GMap.isLoaded()

    $(".map-container").show()
    process.nextTick -> GMap.triggerResize()

    $scope.$on "$destroy", ->
        $(".map-container").hide()

    GMap.on "marker-moved", (latlng)->
        GMap.panTo latlng

    return

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
