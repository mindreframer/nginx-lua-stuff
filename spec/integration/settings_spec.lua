package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

local _ = require("underscore")

describe("When defining settings", function()
  describe("#configure", function()
    it("defaults to all environments", function()
      local context = nil
      mock_app(function(app)
        app:configure(function()
          context = "context"
        end)
      end)

      assert.same("context", context)
    end)

    it("only runs against the default environment", function()
      local context = nil
      mock_app(function(app)
        app:configure('development', function()
          context = "development"
        end)
        app:configure('production', function()
          context = 'production'
        end)
      end)

      assert.same('development', context)
    end)

    it("runs against multiple specified environments", function()
      local context = nil

      mock_app(function(app)
        app:setting('environment', 'staging')
        app:configure('staging', 'production', function()
          context = "not_development"
        end)

        app:configure('development', function()
          context = 'development'
        end)
      end)

      assert.same('not_development', context)
    end)
  end)

  describe("#setting", function()
    it("sets the parameter to a define value", function()
      mock_app(function(app)
        app:setting('starting', 'done')
        app:get('/', function()
          return tostring(self:setting('starting'))
        end)
      end)

      local response = get('/')
      assert.same('done', response.body)
    end)
  end)

  describe("#disable", function()
    it("sets the setting to false", function()
      mock_app(function(app)
        app:disable('starting')
        app:get('/', function()
          return tostring(self:setting('starting'))
        end)
      end)

      local response = get('/')
      assert.same('false', response.body)
    end)
  end)

  describe("#enable", function()
    it("sets the setting to true", function()
      mock_app(function(app)
        app:enable('starting')
        app:get('/', function()
          return tostring(self:setting('starting'))
        end)
      end)

      local response = get('/')
      assert.same('true', response.body)
    end)
  end)
end)
