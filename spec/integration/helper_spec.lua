package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local _ = require("underscore")
local rand = math.random

describe("helper DSL functions", function()
  function status_app(code, block)
    block = block or function() return "" end
      local app = mock_app(function(app)
      app:get("/", function()
        self:status(code)
        return tostring(block(self))
      end)
    end)
    return get("/")
  end

  describe("#status", function()
    it("sets the response status code", function()
      local response = status_app(207)
      assert.same(response.status, 207)
    end)
  end)
  describe("#not_found", function()
    it("is true for status == 404", function()
      local response = status_app(404, function(self) return self:is_not_found() end)
      assert.same(response.body, 'true')
    end)
    it("is true for status != 404", function()
      local response = status_app(405, function(self) return self:is_not_found() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('informational?', function()
    it('is true for 1xx status', function()
      local response = status_app(100 + rand(100), function(self) return self:is_informational() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status > 199', function()
      local response = status_app(200 + rand(400), function(self) return self:is_informational() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('success?', function()
    it('is true for 2xx status', function()
      local response = status_app(200 + rand(100), function(self) return self:is_success() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status < 200', function()
      local response = status_app(100 + rand(100), function(self) return self:is_success() end)
      assert.same(response.body, 'false')
    end)

    it('is false for status > 299', function()
      local response = status_app(300 + rand(300), function(self) return self:is_success() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('redirect?', function()
    it('is true for 3xx status', function()
      local response = status_app(300 + rand(100), function(self) return self:is_redirect() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status < 300', function()
      local response = status_app(200 + rand(100), function(self) return self:is_redirect() end)
      assert.same(response.body, 'false')
    end)

    it('is false for status > 399', function()
      local response = status_app(400 + rand(200), function(self) return self:is_redirect() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('client_error?', function()
    it('is true for 4xx status', function()
      local response = status_app(400 + rand(100), function(self) return self:is_client_error() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status < 400', function()
      local response = status_app(200 + rand(200), function(self) return self:is_client_error() end)
      assert.same(response.body, 'false')
    end)

    it('is false for status > 499', function()
      local response = status_app(500 + rand(100), function(self) return self:is_client_error() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('server_error?', function()
    it('is true for 5xx status', function()
      local response = status_app(500 + rand(100), function(self) return self:is_server_error() end)
      assert.same(response.body, 'true')
    end)

    it('is false for status < 500', function()
      local response = status_app(200 + rand(300), function(self) return self:is_server_error() end)
      assert.same(response.body, 'false')
    end)
  end)

  describe('body', function()
    it('takes a block for deferred body generation', function()
      mock_app(function(app)
        app:get('/', function()
          local i = 0
          self:body(function()
            while i < 1 do
              i=i+1
              return 'Hello World'
            end
          end)
        end)
      end)

      local response = get '/'
      assert.same('Hello World', response.body)
    end)

    it('takes a String', function()
      mock_app(function(app)
        app:get('/', function()
          self:body 'Hello World'
        end)
      end)

      local response = get '/'
      assert.same('Hello World', response.body)
    end)

    it('can be used with other objects', function()
      mock_app(function(app)
        app:get('/', function()
          self:body({hello='from json'})
        end)

        app:after(function()
          if (_.isObject(response.body)) then
            self:body(response.body.hello)
          end
        end)
      end)

      local response = get '/'
      assert.same('from json', response.body)
    end)

    it('can be set in after filter', function()
      mock_app(function(app)
        app:get('/', function()
          self:body 'route'
        end)
        app:after(function()
          self:body('filter')
        end)
      end)

      local response = get '/'
      assert.same('filter', response.body)
    end)
  end)

  describe('headers', function()
    it('sets headers on the response object when given a Hash', function()
      mock_app(function(app)
        app:get('/', function()
          self:headers({['X-Foo']='bar',['X-Baz']='bling'})
          return 'kthx'
        end)
      end)

      local response = get '/'
      assert.same(200, response.status)
      assert.same('bar', response.headers['X-Foo'])
      assert.same('bling', response.headers['X-Baz'])
      assert.same('kthx', response.body)
    end)

    it('returns the response headers hash when no hash provided', function()
      mock_app(function(app)
        app:get('/', function()
          local headers = self:headers({['X-Foo']='bar'})
          return headers['X-Foo']
        end)
      end)

      local response = get '/'
      assert.same(200, response.status)
      assert.same('bar', response.headers['X-Foo'])
    end)
  end)

  describe('content_type', function()
    it("sets the Content-Type header", function()
      mock_app(function(app)
        app:get('/', function()
          self:content_type('text/plain')
          return 'Hello World'
        end)
      end)

      local response = get("/")
      assert.same("text/plain;charset=utf-8", response.headers["Content-Type"])
      assert.same("Hello World", response.body)
    end)

    it("takes media type parameters (like charset)", function()
      mock_app(function(app)
        app:get("/", function()
          self:content_type("text/html", {charset='latin1'})
          return "Hello World"
        end)
      end)

      local response = get("/")
      assert.same(200, response.status)
      assert.same("text/html;charset=latin1", response.headers['Content-Type'])
      assert.same("Hello World", response.body)
    end)

    it("handles already present params", function()
      mock_app(function(app)
        app:get("/", function()
          self:content_type("foo/bar;level=1", {charset="utf-8"})
          return 'ok'
        end)
      end)

      local response = get("/")
      assert.same(200, response.status)
      assert.same("foo/bar;level=1,charset=utf-8", response.headers['Content-Type'])
      assert.same("ok", response.body)
    end)

    it("does not add charset if already present", function()
      mock_app(function(app)
        app:get("/", function()
          self:content_type("text/plain;charset=utf-16")
          return "ok"
        end)
      end)

      local response = get("/")
      assert.same(200, response.status)
      assert.same("text/plain;charset=utf-16", response.headers['Content-Type'])
    end)

    it("properly encodes parameters with delimiter characters", function()
      mock_app(function(app)
        app:before('/comma', function()
          self:content_type("image/png", {comment="Hello, World!"})
        end)
        app:before('/semicolon', function()
          self:content_type("image/png", {comment="semi;colon"})
        end)
        app:before('/quote', function()
          self:content_type("image/png", {comment='"Whatever."'})
        end)
        app:get("*", function()
          return "ok"
        end)

        local response = get("/comma")
        assert.same('image/png;comment="Hello, World!"', response.headers['Content-Type'])
        local response = get("/semicolon")
        assert.same('image/png;comment="semi;colon"', response.headers['Content-Type'])
        local response = get("/quote")
        assert.same('image/png;comment="\\"Whatever.\\""', response.headers['Content-Type'])
      end)
    end)
  end)

  describe("#helpers", function()
    it("takes a list of modules to mix into the app", function()
      local HelperOne = {one=function() return '1' end}
      local HelperTwo = {two=function() return '2' end}

      mock_app(function(app)
        app:helpers(HelperOne, HelperTwo)
        app:get('/one', function() return self:one() end)
        app:get('/two', function() return self:two() end)
      end)

      local response = get('/one')
      assert.same('1', response.body)

      local response = get('/two')
      assert.same('2', response.body)
    end)
  end)
end)
