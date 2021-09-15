-- streamcache.lua

-- This version of streamcache.lua has been modified a lot to reflect
-- the much different caching behaviour of more contemporary mpv versions.
-- A lua script has no more possibility to obtain the actual amount of
-- data cached by mpv - but on the other hand, mpv does do a good job
-- of maintaining a cache of "n seconds", using the "cache-secs" option.
-- Surprisingly, mpv will report only the amount of data cached in excess
-- of that many "cache-secs", when mp.get_property_native("cache-used")
-- is called.
--
-- So now, streamcachel.lua operates like this:
--  - pass the number of seconds of cache to aim for to "cache-secs"
--  - set the initial playback speed to "streamcache_min_speed" (default: 0.98)
--  - slowly (meaning: by no more than the factor of "streamcache_adjust_factor" per second)
--    decrease the playback speed only if "cache-used" reports zero kB available
--    in addition to "cache-secs" seconds of cache
--  - slowly increase the playback speed only if "cache-used" reports more
--    than "streamcache_slack/3" seconds worth of kB reported by "cache-used" available
--    in addition to "cache-secs" seconds of cache

-- Configurable parameters:
streamcache_seconds_aim = 10800
streamcache_slack = 30
streamcache_min_speed = 0.98
streamcache_adjust_factor = 1.00005


-- Changing replay speed by < 2% seems to cause less
--  distortion when not correcting audio pitch (via the scaletempo filter).
-- But you can try setting this to "yes" if you like - 
--  might be useful if you want to toy around with very low min_speed values.
mp.set_property("options/audio-pitch-correction", "yes")

-- Notice that using this script with non-live streams, like podcasts,
--  does usually not improve buffering, as the server will usually 
--  send pre-buffering data individually to clients, anyway. But you can
--  still use this script for podcasts where the server sends less than
--  your desired amount of pre-buffering data.

-- Anything below this line is not meant for configuration.

mp.set_property("options/cache-secs", streamcache_seconds_aim)

streamcache_cache_high = 90
streamcache_cache_low = 30

function streamcache_check_fill()
    local cache_seconds = mp.get_property("demuxer-cache-duration")
    if cache_seconds == nil then
        cache_seconds = 0 + 0.0
    else
        cache_seconds = cache_seconds + 0.0
    end

    local current_speed = mp.get_property_native("speed")
    if current_speed == nil then
        current_speed = streamcache_min_speed
    end

    if (cache_seconds <= 0.0 or (cache_seconds < streamcache_cache_low) or current_speed > 1.0) then
        -- slow down, but now below streamcache_min_speed
        local new_speed = current_speed * (1.0 / streamcache_adjust_factor)
        if (new_speed < streamcache_min_speed) then
            new_speed = streamcache_min_speed
        end
        if ((new_speed > (1.0/streamcache_adjust_factor)) and (new_speed < streamcache_adjust_factor)) then
            -- new_speed is very near 1.0 - so let's use 1.0
            new_speed = 1.0
        end
        if (new_speed ~= current_speed) then
            mp.msg.log("debug", "demuxer-cache-duration " .. cache_seconds .. " seconds , lowered speed to " .. new_speed)
            mp.set_property("speed", new_speed) 
        end
        return
    end

    if (cache_seconds > streamcache_cache_high  and current_speed < 1.0) then
        -- speed up, but not above 1/streamcache_min_speed
        local new_speed = current_speed * streamcache_adjust_factor
        local max_speed = math.floor((10000.0/streamcache_min_speed) + 0.5)/10000.0
        if (new_speed > max_speed) then
            new_speed = max_speed
        end
        if ((new_speed > (1.0/streamcache_adjust_factor)) and (new_speed < streamcache_adjust_factor)) then
            -- new_speed is very near 1.0 - so let's use 1.0
            new_speed = 1.0
        end
        if (new_speed ~= current_speed) then
            mp.msg.log("debug", "demuxer-cache-duration " .. cache_seconds .. " seconds , increased speed to " .. new_speed)
            mp.set_property("speed", new_speed) 
        end
        return
    end

    -- cache_seconds is ok, and currenty speed not higher or lower 1.0 
    mp.msg.log("v", "demuxer-cache-duration " .. cache_seconds .. " seconds, speed remains at " .. current_speed)
end

streamcache_timer = mp.add_periodic_timer(1.0, streamcache_check_fill)


function streamcache_on_loaded()
    mp.msg.log("info", "new file loaded - starting with minimum speed = " .. streamcache_min_speed)
    mp.set_property("speed", streamcache_min_speed)
    -- streamcache_compute_cache_sizes()    
end

mp.register_event("file-loaded", streamcache_on_loaded)

