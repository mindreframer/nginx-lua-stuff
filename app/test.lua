utils = require "utils"

function testReadFile()
    local data = utils.readFile("test/testReadFile.txt")
    local content = [[
testing
readFile
]]
    assert(data == content)
end

function testBuildURLWithKeyAndDomain()
    assert("http://foobar.com/lalala", utils.buildURL("foobar.com", "lalala"))
end

for k in pairs(_G) do
    if utils.starts(k, "test") then
        _G[k]()
    end
end
