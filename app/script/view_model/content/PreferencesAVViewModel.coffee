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
z.ViewModel ?= {}
z.ViewModel.content ?= {}


class z.ViewModel.content.PreferencesAVViewModel
  constructor: (element_id, @call_center) ->
    @logger = new z.util.Logger 'z.ViewModel.content.PreferencesAVViewModel', z.config.LOGGER.OPTIONS

    @media_devices_handler = @call_center.media_devices_handler
    @available_devices = @media_devices_handler.available_devices
    @current_device_id = @media_devices_handler.current_device_id

    @media_stream_handler = @call_center.media_stream_handler
    @audio_stream = @media_stream_handler.local_media_streams.audio
    @video_stream = @media_stream_handler.local_media_streams.video

    @audio_stream.subscribe (audio_stream) =>
      @_release_audio_meter() if @audio_interval
      @_initiate_audio_meter audio_stream if audio_stream

    @audio_context = undefined
    @audio_level = ko.observable 0
    @audio_interval = undefined

    @permission_denied = ko.observable false

  # Initiate devices.
  initiate_devices: =>
    @_get_media_stream()
    .then (audio_stream) =>
      @_initiate_audio_meter audio_stream if not @audio_interval

  # Release devices.
  release_devices: =>
    @_release_audio_meter()
    @_release_media_streams()

  ###
  Get current MediaStream or initiate it.
  @private
  ###
  _get_media_stream: =>
    return Promise.resolve @audio_stream() if @audio_stream() and @video_stream()

    @media_stream_handler.get_media_stream_constraints @available_devices.audio_input().length, @available_devices.video_input().length
    .then ([media_type, media_stream_constraints]) =>
      return @media_stream_handler.request_media_stream media_type, media_stream_constraints
    .then (media_stream_info) =>
      @media_stream_handler.local_media_type z.calling.enum.MediaType.VIDEO if @available_devices.video_input().length
      @media_stream_handler.set_local_media_stream media_stream_info
      return @audio_stream()
    .catch (error) =>
      error = error[0] if _.isArray error
      @permission_denied true
      @logger.log @logger.levels.ERROR, "Requesting MediaStream failed: #{error.message}", error
      throw error

  ###
  Initiate audio meter.
  @private
  @param audio_stream []
  ###
  _initiate_audio_meter: (audio_stream) =>
    @logger.log @logger.levels.INFO, 'Initiating new audio meter', audio_stream
    @audio_context = @call_center.audio_repository.get_audio_context()

    @audio_analyser = @audio_context.createAnalyser()
    @audio_analyser.fftSize = 1024
    @audio_analyser.smoothingTimeConstant = 0.2
    @audio_data_array = new Float32Array @audio_analyser.frequencyBinCount

    @audio_interval = window.setInterval =>
      @audio_analyser.getFloatFrequencyData @audio_data_array
      volume = 0
      # Data is in the db range of -100 to -30, but can also be -Infinity. We normalize the value up to -50 to the range of 0, 1.
      for data in @audio_data_array
        volume += Math.abs(Math.max(data, -100) + 100) / 50

      average_volume = volume / @audio_data_array.length

      @audio_level average_volume - 0.075
    , 100

    @audio_source = @audio_context.createMediaStreamSource audio_stream
    @audio_source.connect @audio_analyser

  _release_audio_meter: =>
    window.clearInterval @audio_interval
    @audio_interval = undefined
    @audio_source.disconnect() if @audio_source

  _release_media_streams: =>
    @media_stream_handler.reset_media_streams()
    @permission_denied false
