--
-- OpenStreetMap region data library
--
--
-- Copyright (C) 2013, Hiroshi Miura
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU Affero General Public License for more details.
--
--    You should have received a copy of the GNU Affero General Public License
--    along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
local setmetatable = setmetatable
local error = error
local require = require
local myname = ...

module(...)

_VERSION = '0.30'

local target = {
    ['japan'] = myname .. '.japan',
    ['asia']  = myname .. '.asia',
    ['world'] = myname .. '.world'
  }

function get_region(name)
    if not target[name] then
        return nil
    end
    local region = require(target[name])
    return region
end

local class_mt = {
    -- to prevent use of casual module global variables
    __newindex = function (table, key, val)
        error('attempt to write to undeclared variable "' .. key .. '"')
    end
}

setmetatable(_M, class_mt)
