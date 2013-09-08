package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local Response = require("sinatra/response")
ngx = {}

describe("Response", function()
  before_each(function()
    ngx = {
      print=function()end,
      header={},
      status=nil,
      var={
        request_method=nil
      }
    }
  end)

  it("sets defaults", function ()
    local response = Response:new()
    assert.same(response.status, 200)
    assert.same(response.headers, {})
    assert.same(response.body, " ")
  end)

  describe("when finishing response back", function()
    it("outputs the body", function()
      local say = spy.on(ngx, "print")
      local response = Response:new({200, "1234"})
      response:finish()
      assert.spy(say).was_called_with("1234")
    end)

    it("outputs the headers", function()
      local response = Response:new({200, {["Content-Type"]="text/plain"}, " "})
      response:finish()
      assert.same(ngx.header, {["Content-Type"]="text/plain"})
    end)

    it("sets the status code", function()
      local response = Response:new(500)
      response:finish()
      assert.same(ngx.status, 500)
    end)
  end)

  describe("arguments passed into #new", function()
    local status = 500
    local headers = {["Content-Type"]="application/json"}
    local body = "body"

    it("can be an array of three elements for status, headers, and body", function()
      local response = Response:new({status, headers, body})
      assert.same(response.status, status)
      assert.same(response.headers, headers)
      assert.same(response.body, body)
    end)

    it("can be an array of two elements for status and body", function()
      local response = Response:new({status, body})
      assert.same(response.status, status)
      assert.same(response.headers, {})
      assert.same(response.body, body)
    end)

    it("can be string as the body", function()
      local response = Response:new(body)
      assert.same(response.status, 200)
      assert.same(response.headers, {})
      assert.same(response.body, body)
    end)

    it("can be a number as the status", function()
      local response = Response:new(status)
      assert.same(response.status, status)
      assert.same(response.headers, {})
      assert.same(response.body, " ")
    end)
  end)
end)
