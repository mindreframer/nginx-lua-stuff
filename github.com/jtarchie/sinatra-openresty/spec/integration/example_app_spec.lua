package.path = './spec/?.lua;./lib/?.lua;'..package.path
require 'spec_helper'
local _ =require("underscore")

describe("When testing against a live nginx process", function()
  before_each(function()
    os.execute("pkill nginx; nginx -p `pwd`/spec/app/ -c nginx.conf;")
  end)

  describe("standard GET request routes", function()
    it("returns successfully", function()
      local response = visit("/")
      assert.same(200, response.status)
      assert.same("Hello, World", response.body)
    end)

    it("returns the name in the response", function()
      local response = visit("/JT")
      assert.same(200, response.status)
      assert.same("Hello, JT", response.body)
    end)

    it("returns the age in the response", function()
      local response = visit("/age/30")
      assert.same(200, response.status)
      assert.same("You are 30 years old.", response.body)
    end)

    it("matches routes with query string parameters", function()
      local response = visit("/age/30?name=JT")
      assert.same(200, response.status)
      assert.same("JT are 30 years old.", response.body)
    end)

    it("returns headers specified in the response", function()
      local response = visit("/JT", {}, {['Accept']='application/json'})
      assert.same('{"name":"JT"}', response.body)
      assert.same(201, response.status)
      assert.same('application/json;charset=utf-8', response.headers['content-type'])
    end)
  end)
end)
