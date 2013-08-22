# Licensed under the Apache License. See footer for details.

#-------------------------------------------------------------------------------
module.exports = (mod) ->

    addControllers  mod, {
        BodyController
        MainController
        LogController
        SettingsController
        ApisController        
    }

    return

#-------------------------------------------------------------------------------
BodyController = ($scope, LogService) ->
    $scope.log = (message) -> LogService.log message

    $scope.log "BodyController created"

    $scope.appName = "us-weather"

    return

#-------------------------------------------------------------------------------
MainController = ($scope, $window, LocationsService) ->
    $scope.log "MainController created"

    $scope.locations = LocationsService.locations
    $scope.refresh   = -> LocationsService.refreshData()

    $window = $($window)
    $window.on "resize", -> recalculateChartSize $scope, $window

    recalculateChartSize $scope, $window

    return

#-------------------------------------------------------------------------------
recalculateChartSize = ($scope, $window) ->
    windowWidth  = $window.width()
    windowHeight = $window.height()

    chartWidth = Math.round(windowWidth * 0.95)
    if windowWidth > windowHeight
        chartHeight = windowHeight * 0.95
        chartHeight = Math.min( chartHeight, chartWidth / 2)
    else
        chartHeight = $scope.chartWidth

    $scope.chartWidth  = Math.round chartWidth
    $scope.chartHeight = Math.round chartHeight

    # LogService.log "-----------------------------------------"
    # LogService.log "window size: #{windowWidth} x #{windowHeight}"
    # LogService.log "chart  size: #{$scope.chartWidth} x #{$scope.chartHeight}"

    $scope.$apply() if !$scope.$$phase
    return

#-------------------------------------------------------------------------------
LogController = ($scope, LogService) ->
    $scope.log "LogController created"

    $scope.logger   = LogService
    $scope.messages = LogService.messages
    $scope.clear    = -> LogService.clear()

    return

#-------------------------------------------------------------------------------
SettingsController = ($scope) ->
    $scope.log "SettingsController created"

    return

#-------------------------------------------------------------------------------
ApisController = ($scope) ->
    $scope.log "ApisController created"

    return

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
addControllers = (mod, controllers) ->
    for own name, fn of controllers
        mod.controller name, fn

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
