#!/usr/bin/env lua

module("yagami.logger", package.seeall)

local string_sub = string.sub
local string_lower  = string.lower
local string_format = string.format
local debug_getinfo = debug.getinfo
local io_open       = io.open
local os_date       = os.date
local ngx_time      = ngx.time

logging = require("logging")
util = require("yagami.util")
vars = require("yagami.vars")

function get_logger(appname)
    local logger = vars.get(appname, "__LOGGER")
    if logger then return logger end
    
    local filename = "/dev/stderr"
    local level = "DEBUG"
    local log_config = util.get_config("logger")
    
    if log_config and type(log_config.file) == "string" then
        filename = log_config.file
    end
    
    if log_config and type(log_config.level) == "string" then
        level = log_config.level
    end

    local log_filename = function(date)
      return filename .. '.' .. date
    end

    local f_date = os_date("%Y-%m-%d", ngx_time())
    local f = io_open(log_filename(f_date), "a")
    if not f then
        f = io_open("/dev/stderr", "a")
        ngx.log(ngx.ERR, string_format("LOGGER ERROR: file `%s' could not be opened for writing", filename))
    end
    f:setvbuf("line")

    local function log_appender(self, level, message)
        local date  = os_date("%Y-%m-%d %H:%M:%S", ngx_time())
        local frame = debug_getinfo(4)
        local s = string_format('[%s] [%s] [%s:%d] %s\n',
                                string_sub(date, 6),
                                level,
                                frame.short_src,
                                frame.currentline,
                                message)
        local log_date = string_sub(date, 1, 10)
        if log_date ~= f_date then
          f_date = log_date
          f:close()
          f = io_open(log_filename(log_date), "a")
          f:setvbuf("line")
        end
        f:write(s)
        return true
    end
    
    logger = logging.new(log_appender)
    logger:setLevel(level)
    vars.set(appname, "__LOGGER", logger)
    logger._log = logger.log
    logger._setLevel = logger.setLevel

    logger.log = function(self, level, ...)
                     local _logger = get_logger(ngx.ctx.YAGAMI_APP_NAME)
                     _logger._log(self, level, ...)
                 end
    logger.setLevel = function(self, level, ...)
                          local _logger = get_logger(ngx.ctx.YAGAMI_APP_NAME)
                          _logger:_log("ERROR", "Can not setLevel")
                      end
    -- for _, l in ipairs(logging.LEVEL) do -- logging does not export this variable :(
    local levels = {d = "DEBUG", i = "INFO", w = "WARN", e = "ERROR", f = "FATAL"}
    for k, l in pairs(levels) do
        logger[k] = function(self, ...)
                        logger.log(self, l, ...)
                    end
        logger[string_lower(l)] = logger[k]
    end
    logger.tostring = logging.tostring
    logger.table_print = util.table_print
    
    return logger
end

function logger()
    local logger = get_logger(ngx.ctx.YAGAMI_APP_NAME)
    return logger
end

