# -------------------------------------------
# Modernizr test: audio supports playbackrate
# -------------------------------------------

# Modernizr tests:
# - playbackrate: Does the browser support changing playback rate
#   when the music is already playing (e.g. not IOS)
#
# - playbackratelive: Does the browser support changing playback rate
#   if the music is stopped and consequently started after setting it (IOS)
#
# Note that these tests are asynchronous (use Modernizr.on)

playbackLiveTest = (audio) ->
  # Reset audio
  audio.currentTime = 0
  margin = 0.1
  rate = 0.5
  duration = 12
  minDuration = 3

  started = null
  rateSet = false
  audio.addEventListener 'timeupdate', ->
    return if audio.paused or isNaN(audio.currentTime) or audio.currentTime <= 0

    # Set playback rate when currentTime > 0
    if not rateSet
      audio.playbackRate = rate
      audio.pause()
      audio.play()
      return rateSet = true

   # Record the time at which the audio started playing
    if not started?
      return started = Date.now() / 1000 - audio.currentTime

    delta = Date.now() / 1000 - started
    return if minDuration > delta

    # Calculate the actual playback rate and set test result
    playbackRate = audio.currentTime / delta
    if (rate - margin) < playbackRate < (rate + margin)
      Modernizr.addTest 'playbackratelive', true

      # Clear fail timer and pause the audio
      clearTimeout failTimer
      audio.pause()

  # Just fail the test on timeout
  failTimer = setTimeout( ->
      Modernizr.addTest 'playbackratelive', Modernizr.playbackratelive?
      audio.pause()
    , (duration + 1) * 1000
  )

  audio.play()

playbackTest = ->
  margin = 0.1    # Margin that the measured playback rate should be within
  rate = 0.5      # Test rate
  duration = 7    # How long time to play the audio before measuring playback rate
  minDuration = 3 # Shortest duration in seconds before testing

  # Structure setup
  source = document.createElement 'source'
  source.setAttribute 'type', 'audio/mpeg'
  source.setAttribute 'src', 'audio/silence.mp3'
  audio = document.createElement 'audio'
  audio.appendChild source

  # Test block
  # Handler that checks if the playbackRate is correct and tells Modernizr
  started = null
  rateSet = false
  audio.addEventListener 'timeupdate', ->
    # Don't do anything if the test has finished
    return if Modernizr.playbackrate?

    # Skip events fired before audio plays or events with invalid time.
    # Occurs on Chrome and IOS.
    # We check if currentTime <= 0 because IOS *will* work if currentTime == 0
    return if audio.paused or isNaN(audio.currentTime) or audio.currentTime <= 0

    if not rateSet
      audio.playbackRate = rate
      rateSet = true

    # Record the time at which the audio started playing
    if not started?
      return started = Date.now() / 1000 - audio.currentTime

    # Get time in seconds since audio started playing and return if played
    # for too short time
    delta = Date.now() / 1000 - started
    return if minDuration > delta

    # Calculate the actual playback rate and set test result
    playbackRate = audio.currentTime / delta
    if (rate - margin) < playbackRate < (rate + margin)
      Modernizr.addTest 'playbackrate', true
      audio.pause()

  # Just fail the test on timeout
  setTimeout( ->
      Modernizr.addTest 'playbackrate', Modernizr.playbackrate?
      audio.pause()
    , (duration + 1) * 1000
  )

  # Start playback
  audio.play()

  # Second test - test whether playbackrate works if start/stopped (IOS bug)
  Modernizr.on 'playbackrate', (playbackrate) ->
    playbackLiveTest audio

Modernizr.on 'autoplayback', (autoplayback) ->
  if not autoplayback
    # IOS prohibits web pages from starting any audio playback automatically, so
    # we fall back to wait for user interaction before running the test.
    listener = ->
      document.removeEventListener 'click', listener
      playbackTest()
    document.addEventListener 'click', listener
  else
    playbackTest()

