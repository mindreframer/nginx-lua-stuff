package.path = './spec/?.lua;./lib/?.lua;'..package.path
require("spec_helper")

describe("Filters that run before requests", function()
  it("executes flter in order of defined", function()
    local count = 0
    mock_app(function(app)
      app:get('/', function() return 'Hello World' end)
      app:before(function()
        assert.equal(0, count)
        count = 1
      end)
      app:before(function()
        assert.equal(1, count)
        count = 2
      end)
    end)

    local response = get('/')
    assert.same(200, response.status)
    assert.same(2, count)
    assert.same('Hello World', response.body)
  end)

  it("can modify the request", function()
    mock_app(function(app)
      app:get('/foo', function() return 'foo' end)
      app:get('/bar', function() return 'bar' end)
      app:before(function()
        request.current_path='/bar'
      end)
    end)

    local request = get('/foo')
    assert.same(200, request.status)
    assert.same('bar', request.body)
  end)

  it("does not modify the response with its return value", function()
    mock_app(function(app)
      app:before(function() return 'Hello World' end)
      app:get('/foo', function()
        assert.same(' ',response.body)
        return 'foo'
      end)
    end)

    local response = get('/foo')
    assert.same(200, response.status)
    assert.same('foo', response.body)
  end)

  it("does modify the response with halt", function()
    mock_app(function(app)
      app:before(function() self:halt({302, 'Hi'}) end)
      app:get('/foo', function()
        return 'should not happen'
      end)
    end)

    local response = get('/foo')
    assert.same(302, response.status)
    assert.same('Hi', response.body)
  end)

  it("gives you access to params", function()
    mock_app(function(app)
      app:before(function() self.foo = params.foo end)
      app:get('/foo', function() return self.foo end)
    end)

    local response = get('/foo?foo=cool')
    assert.same(200, response.status)
    assert.same('cool', response.body)
  end)

  it("properly unescapes parameters", function()
    mock_app(function(app)
      app:before(function() self.foo = params.foo end)
      app:get('/foo', function() return self.foo end)
    end)

    local response = get('/foo?foo=bar%3Abaz%2Fbend')
    assert.same(200, response.status)
    assert.same('bar:baz/bend', response.body)
  end)

  it("takes an options route pattern", function()
    local ran_filter = false
    mock_app(function(app)
      app:before("/b*", function() ran_filter = true end)
      app:get("/foo", function() end)
      app:get("/bar", function() end)
    end)

    get("/foo")
    assert.same(false, ran_filter)
    get("/bar")
    assert.same(true, ran_filter)
  end)

  it("generates block arguments from the route pattern", function()
    local subpath = nil
    mock_app(function(app)
      app:before("/foo/:sub", function(s) subpath = s end)
      app:get("/foo/*", function() end)
    end)

    get("/foo/bar")
    assert.same("bar", subpath)
  end)
end)

describe("Filters than run after requests", function()
  it("executes before and after filters in correct order", function()
    local invoked = 0
    mock_app(function(app)
      app:before(function() invoked = 2 end)
      app:get("/", function()
        invoked = invoked + 2
        return "Hello"
      end)
      app:after(function() invoked = invoked * 2 end)
    end)

    local response = get('/')
    assert.same(200, response.status)
    assert.same(8, invoked)
  end)

  it("executes flter in order of defined", function()
    local count = 0
    mock_app(function(app)
      app:get('/', function() return 'Hello World' end)
      app:after(function()
        assert.equal(0, count)
        count = 1
      end)
      app:after(function()
        assert.equal(1, count)
        count = 2
      end)
    end)

    local response = get('/')
    assert.same(200, response.status)
    assert.same(2, count)
    assert.same('Hello World', response.body)
  end)

  it("does not modify the response with its return value", function()
    mock_app(function(app)
      app:after(function() return 'Hello World' end)
      app:get('/foo', function()
        assert.same(' ',response.body)
        return 'foo'
      end)
    end)

    local response = get('/foo')
    assert.same(200, response.status)
    assert.same('foo', response.body)
  end)

  it("does modify the response with halt", function()
    mock_app(function(app)
      app:after(function() self:halt({302, 'Hi'}) end)
      app:get('/foo', function()
        return 'should not happen'
      end)
    end)

    local response = get('/foo')
    assert.same(302, response.status)
    assert.same('Hi', response.body)
  end)

  it("takes an options route pattern", function()
    local ran_filter = false
    mock_app(function(app)
      app:after("/b*", function() ran_filter = true end)
      app:get("/foo", function() end)
      app:get("/bar", function() end)
    end)

    get("/foo")
    assert.same(false, ran_filter)
    get("/bar")
    assert.same(true, ran_filter)
  end)

  it("generates block arguments from the route pattern", function()
    local subpath = nil
    mock_app(function(app)
      app:after("/foo/:sub", function(s) subpath = s end)
      app:get("/foo/*", function() end)
    end)

    get("/foo/bar")
    assert.same("bar", subpath)
  end)
end)
