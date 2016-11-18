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

# MediaDevices Repository
class z.media_devices.MediaDevicesRepository
  ###
  Extended check for calling support of browser.
  @param conversation_id [String] Conversation ID
  @return [Boolean] True if calling is supported
  ###
  @supports_media_devices: ->
    return z.util.Environment.browser.supports.media_devices

  ###
  Construct a new MediaDevices repository.
  @param call_center [z.calling.CallCenter] Call center with references to all other handlers
  ###
  constructor: (@call_center) ->
    @logger = new z.util.Logger 'z.media_devices.MediaDevicesRepository', z.config.LOGGER.OPTIONS

    @media_devices_handler = new z.media_devices.MediaDevicesHandler @
