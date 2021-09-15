local mp = require("mp")
local utils = require("mp.utils")
local msg = require("mp.msg")
local options = require("mp.options")

-- options
local o = {
  info_key = 'D'
}

options.read_options(o)

local message = ""

local filename = nil
local title = nil
local mediatitle = nil
local pos = nil
local plen = nil
local ytdltitle = nil
local description = nil
local extractor = nil
local uploader = nil

local function refresh_vars()
  pos = mp.get_property_number('playlist-pos', 0)
  plen = mp.get_property_number('playlist-count', 0)
  filename = mp.get_property("filename")
  title = mp.get_property("title")
  mediatitle = mp.get_property("media-title")
  ytdltitle = mp.get_property("file-local-options/ytdl-title")
  description = mp.get_property("file-local-options/description")
  extractor = mp.get_property("file-local-options/extractor")
  uploader = mp.get_property("file-local-options/uploader")
end


local function exec(args)
  local ret = utils.subprocess({args = args})
  return ret.status, ret.stdout, ret, ret.killed_by_us
end

local function show_info_lite()
  refresh_vars()
  mp.command('show_text "[${playlist-pos-1}/${playlist-count}] ${media-title}\n\n ${file-size} ${filtered-metadata}"')
end

local function atm(add)
  message = message .. add
end 

local function isit(arg)
  local a = mp.get_property(arg)
  if a~=nil then
    return true
  else
    return false
  end
end

local function atmp(add)
  local a = mp.get_property(add)
  if a~=nil then
    message = message .. a
  end
end

local function atml(prop)
  local p = mp.get_property("file-local-options/" .. prop)
  if a~=nil then
    message = message .. prop .. ": " .. a .. "\n "
  end
end

local function show_info()
  refresh_vars()
  message=""
  atm("[")
  atmp("playlist-pos-1")
  atm("/")
  atmp("playlist-count")
  atm("] ")
  if filename ~= title then
    atmp("filename")
    atm("\n ")
  end
  atmp("media-title")
  if isit("file-size") then
    atm("\n\n ")
    atmp("file-size")
    atm(" ")
    atmp("video-format")
    atm("@")
    atmp("video-bitrate")
    atm(" ")
    atmp("video-codec")
    atm(" ")
    atmp("width")
    atm("x")
    atmp("height")
    atm(" via ")
    atmp("hwdec")
    atm(" ")
    atmp("current-vo")
    atm("\n ")
    atmp("audio-codec")
    atm("@")
    atmp("audio-bitrate")
    atm("\n\n ")
  end
  if isit("metadata") then
    atmp("metadata")
  end
  atm("\n\n ")
  atmp("clock")

  msg.info(message:gsub("\n\n", "\n"))
  mp.commandv("expand-properties", "show_text", message)
end

local function show_info_for_streams()
  refresh_vars()
  if filename
    and filename:match('^https?://')
    then
    show_info()
  end
end

--[[local function show_meta()
    local items = mp.get_property_number('metadata/list/count')
    local meta = mp.get_property_native('metadata')

    msg.warn(metadata)


end ]]--

function observe(name)
  mp.observe_property(name, "native", function(name, val)
    msg.info("property '" .. name .. "' changed to '" ..
      utils.to_string(val) .. "'")
  end)
end

function play_next(filename)
  pcall(function ()
    msg.info("play next: ", filename)
    local appendstr = "append"
    local pos = mp.get_property_number('playlist-pos', 0)
    local plen = mp.get_property_number('playlist-count', 0)
    mp.commandv("loadfile", filename, appendstr)
    mp.commandv("playlist-move", plen,  pos+1)
  end)
end

mp.register_script_message("play_next", play_next)

mp.register_script_message("show_info", show_info)
mp.register_script_message("show_info_lite", show_info_lite)
--mp.register_script_message("show_meta", show_meta)
mp.register_event("playback-restart", show_info_lite)
--mp.register_event("start-file", show_info)
--mp.register_event("file-loaded", show_info)
mp.add_key_binding("B", "show_info", show_info)
mp.add_key_binding("i", "show_info", show_info)
mp.add_key_binding("I", "show_info", show_info)
--[[
--
pcall(function () observe("metadata") end)
pcall(function () observe("filtered-metadata") end)
pcall(function () observe("chapter-metadata") end)
pcall(function () observe("vf-metadata") end)
pcall(function () observe("af-metadata") end)

for i,name in ipairs(mp.get_property_native("playlist")) do
msg.info(i)
msg.info(name)
pcall(observe(name))
end

for i,name in ipairs(mp.get_property_native("property-list")) do
observe(name)
end

for i,name in ipairs(mp.get_property_native("file-local-options")) do
observe("options/" .. name)
end
]]--
-- mp.get_property_osd("[${playlist-pos-1}/${playlist-count}] ${media-title}\n ${file-size} ${video-format}@${video-bitrate} ${width}x${height} ${clock}\n ${audio-codec-name} ${video-codec-name} via ${hwdec}")
-- mp.get_property_osd("[${playlist-pos-1}/${playlist-count}] ${filename}\n ${media-title}\n ${file-size} ${video-format}@${video-bitrate} ${width}x${height} ${clock}\n ${audio-codec-name} ${video-codec-name} via ${hwdec}")

-- mp.commandv("load-script", "/home/pi/.config/mpv/mpv-scripts/appendURL.lua")
