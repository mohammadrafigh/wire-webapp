#
# Wire
# Copyright (C) 2016 Wire Swiss GmbH
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see http://www.gnu.org/licenses/.
#

window.z ?= {}
z.media_devices ?= {}

class z.media_devices.MediaDevicesError
  constructor: (type) ->
    @name = @constructor.name
    @stack = (new Error()).stack
    @type = type or z.media_devices.MediaDevicesError::TYPE.UNKNOWN

    @message = switch @type
      when z.media_devices.MediaDevicesError::TYPE.NO_CAMERA_FOUND
        'No camera found'
      when z.media_devices.MediaDevicesError::TYPE.NO_DEVICES_FOUND
        'No MediaDevices found'
      when z.media_devices.MediaDevicesError::TYPE.NO_MICROPHONE_FOUND
        'No microphone found'
      when z.media_devices.MediaDevicesError::TYPE.SCREEN_NOT_SUPPORTED
        'Screen sharing is not yet supported by this browser'
      else
        'Unknown CallError'

  @:: = new Error()
  @::constructor = @
  @::TYPE = {
    NO_CAMERA_FOUND: 'z.media_devices.MediaDevicesError::TYPE.NO_MICROPHONE_FOUND'
    NO_DEVICES_FOUND: 'z.media_devices.MediaDevicesError::TYPE.NO_DEVICES_FOUND'
    NO_MICROPHONE_FOUND: 'z.media_devices.MediaDevicesError::TYPE.NO_MICROPHONE_FOUND'
    SCREEN_NOT_SUPPORTED: 'z.media_devices.MediaDevicesError::TYPE.SCREEN_NOT_SUPPORTED'
    UNKNOWN: 'z.media_devices.MediaDevicesError::TYPE.UNKNOWN'
  }
