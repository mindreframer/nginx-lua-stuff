package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local Request = require("sinatra/request")
ngx = {}

describe("Request", function()
  before_each(function()
    ngx = {
      var={
        uri="/path",
        request_method="GET"
      },
      req={
        get_uri_args=function() end,
        get_headers=function() end
      }
    }
  end)

  describe("with ngx.var", function()
    it("returns the request method", function()
      local request = Request:new()
      assert.same(request.request_method, "GET")
    end)

    it("returns the current path", function()
      local request = Request:new()
      assert.same(request.current_path, "/path")
    end)
  end)

  describe("with ngx.req", function()
    describe("form paramteres from #params", function()
      before_each(function()
        ngx.req.get_uri_args=function()
          return({
            a='1',
            b='2'
          }) 
        end
      end)

      it("returns a hash from query string", function()
        local request = Request:new()
        assert.same(request.params, {a='1',b='2'})
      end)
    end)

    describe("accessing headers", function()
      before_each(function()
        ngx.req.get_headers=function()
          return({
            ['Accept']='application/json'
          })
        end
      end)

      it("returns headers from the request", function()
        local request = Request:new()
        assert.same(request.headers, {['Accept']='application/json'})
      end)
    end)
  end)
end)
