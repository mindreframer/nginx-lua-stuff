require 'spec.helper'

context('fakengx', function()

  before(function()
    ngx = fakengx.new()
  end)

  test('instance type', function()
    assert_type(ngx, 'table')
  end)

  test('fresh instances', function()
    ngx.var.something = 1
    local a = fakengx.new()
    assert_tables(a.var, {})
  end)

  test('constants', function()
    assert_equal(ngx.DEBUG, 8)
    assert_equal(ngx.HTTP_GET, 'GET')
    assert_equal(ngx.HTTP_OK, 200)
    assert_equal(ngx.HTTP_BAD_REQUEST, 400)
  end)

  test('static', function()
    assert_equal(ngx.status, 200)
    assert_tables(ngx.var, {})
    assert_tables(ngx.arg, {})
    assert_tables(ngx.header, {})
  end)

  test('internal registries', function()
    assert_equal(ngx._body, "")
    assert_equal(ngx._log, "")
    assert_tables(ngx._captures, { stubs = {} })
  end)

  test('_captures.length()', function()
    assert_equal(ngx._captures:length(), 0)
  end)

  test('_captures.stub()', function()
    local s1 = ngx.location.stub("/subrequest")
    local s2 = ngx.location.stub("/subrequest", { body = "ABC", method = "POST" }, { status = 201 })
    local s3 = ngx.location.stub("/subrequest", { args = { b = 1, a = 2 } }, { body = "OK" })
    assert_equal(ngx._captures:length(), 3)

    local stub
    stub = ngx._captures.stubs[1]
    assert_equal(stub, s1)
    assert_equal(stub.uri, "/subrequest")
    assert_tables(stub.opts, { })
    assert_tables(stub.res, { status = 200, headers = {}, body = "" })

    stub = ngx._captures.stubs[2]
    assert_equal(stub, s2)
    assert_equal(stub.uri, "/subrequest")
    assert_tables(stub.opts, { body = "ABC", method = "POST" })
    assert_tables(stub.res, { status = 201, headers = {}, body = "" })

    stub = ngx._captures.stubs[3]
    assert_equal(stub, s3)
    assert_equal(stub.uri, "/subrequest")
    assert_tables(stub.opts, { args = "a=2&b=1" })
    assert_tables(stub.res, { status = 200, headers = {}, body = "OK" })
  end)

  test('_captures.find()', function()
    local s0 = ngx.location.stub("/subrequest", { }, { status = 200 })
    local s1 = ngx.location.stub("/subrequest", { method = "GET" }, { status = 200 })
    local s2 = ngx.location.stub("/subrequest", { body = "~>A%a+C", method = "POST" }, { status = 201, headers = { Location = "http://host/resource/1" } })
    local s3 = ngx.location.stub("/subrequest", { args = { b = 1, a = 2 } }, { body = "OK" })
    local s4 = ngx.location.stub("/subrequest", { body = (function(v) return v == "HI" end) }, { body = "OK" })

    assert_nil(ngx._captures:find("/not-registered", {}))
    assert_nil(ngx._captures:find("/not-registered"))

    assert_tables(ngx._captures:find("/subrequest"), s1)
    assert_tables(ngx._captures:find("/subrequest", { method = "GET" }), s1)
    assert_tables(ngx._captures:find("/subrequest", { method = "POST", body = "ABC" }), s2)
    assert_tables(ngx._captures:find("/subrequest", { body = "ABC" }), s1)
    assert_tables(ngx._captures:find("/subrequest", { args = "a=2&b=1" }), s3)
    assert_tables(ngx._captures:find("/subrequest", { args = { a = 2, b = 1 } }), s3)
    assert_tables(ngx._captures:find("/subrequest", { args = "b=1&a=1" }), s1)
    assert_tables(ngx._captures:find("/subrequest", { method = "POST" }), s0)
    assert_tables(ngx._captures:find("/subrequest", { body = "HI" }), s4)
  end)

  test('shared.DICT.set()', function()
    local ok, err = ngx.shared.store:set("key", "value")
    assert_equal(ok, true)
    assert_equal(err, nil)
  end)

  test('shared.DICT.get()', function()
    local val

    val = ngx.shared.store:get("key")
    assert_equal(val, nil)

    ngx.shared.store:set("key", "value")
    val = ngx.shared.store:get("key")
    assert_equal(val, "value")
  end)

  test('shared.DICT.add()', function()
    local ok, err
    ok, err = ngx.shared.store:add("key", "v1")
    assert_equal(ok, true)
    assert_equal(err, nil)

    ok, err = ngx.shared.store:add("key", "v2")
    assert_equal(ok, false)
    assert_equal(err, "exists")

    assert_equal(ngx.shared.store:get("key"), "v1")
  end)

  test('shared.DICT.replace()', function()
    local ok, err
    ok, err = ngx.shared.store:replace("key", "v1")
    assert_equal(ok, false)
    assert_equal(err, "not found")

    ok, err = ngx.shared.store:add("key", "v1")
    ok, err = ngx.shared.store:replace("key", "v2")
    assert_equal(ok, true)
    assert_equal(err, nil)

    assert_equal(ngx.shared.store:get("key"), "v2")
  end)

  test('shared.DICT.delete()', function()
    assert_equal(ngx.shared.store:get("key"), nil)
    ngx.shared.store:set("key", "v")
    assert_equal(ngx.shared.store:get("key"), "v")
    ngx.shared.store:delete("key", "v")
    assert_equal(ngx.shared.store:get("key"), nil)
  end)

  test('shared.DICT.incr()', function()
    local ok, err
    ok, err = ngx.shared.store:incr("key", 1)
    assert_equal(ok, nil)
    assert_equal(err, "not found")

    ngx.shared.store:set("key", "v")
    ok, err = ngx.shared.store:incr("key", 1)
    assert_equal(ok, nil)
    assert_equal(err, "not a number")

    ngx.shared.store:set("key", 123)
    ok, err = ngx.shared.store:incr("key", 1)
    assert_equal(ok, 124)
    assert_equal(err, nil)
  end)


  test('print()', function()
    ngx.print("string")
    assert_equal(ngx._body, "string")
  end)

  test('say()', function()
    ngx.say("string")
    assert_equal(ngx._body, "string\n")
  end)

  test('log()', function()
    ngx.log(ngx.NOTICE, "string")
    assert_equal(ngx._log, "LOG(6): string\n")
  end)

  test('time()', function()
    assert_type(ngx.time(), 'number')
    local t = os.time()
    assert_equal(ngx.time(), t)
    while os.time() - t == 0 do end -- wait for next second
    assert_equal(ngx.time(), t)     -- ensure cached value is used
  end)

  test('update_time()', function()
    local t = os.time()
    local t1 = ngx.time()
    local n1 = ngx.now()
    while os.time() - t == 0 do end -- wait for next second
    assert_equal(ngx.time(), t1)    -- until ngx.update_time() is called uses cached value
    assert_equal(ngx.now(), n1)
    ngx.update_time()
    assert_greater_than(ngx.time(), t1)
    assert_greater_than(ngx.now(), n1)
  end)

  test('now()', function()
    assert_type(ngx.now(), 'number')
    assert(ngx.now() >= os.time())
    assert(ngx.now() <= (os.time() + 1))
  end)

  test('cookie_time()', function()
    assert_type(ngx.cookie_time(1212121212), 'string')
    assert_equal(ngx.cookie_time(1212121212), 'Fri, 30-May-2008 04:20:12 GMT')
  end)

  test('exit()', function()
    assert_equal(ngx.status, 200)
    assert_nil(ngx._exit)

    ngx.exit(ngx.HTTP_BAD_REQUEST)
    assert_equal(ngx.status, 400)
    assert_equal(ngx._exit, 400)

    ngx.exit(ngx.HTTP_OK)
    assert_equal(ngx.status, 400)
    assert_equal(ngx._exit, 200)
  end)

  test('escape_uri()', function()
    assert_equal(ngx.escape_uri("here [ & ] now_"), "here+%5B+%26+%5D+now_")
  end)

  test('unescape_uri()', function()
    assert_equal(ngx.unescape_uri("here+%5B+%26+%5D+now"), "here [ & ] now")
  end)

  test('encode_args()', function()
    assert_equal(ngx.encode_args({foo = 3, ["b r"] = "hello world"}), "b%20r=hello%20world&foo=3")
    assert_equal(ngx.encode_args({["b r"] = "hello world", foo = 3}), "b%20r=hello%20world&foo=3")
  end)

  test('crc32_short()', function()
    assert_type(ngx.crc32_short("abc"), 'number')
    assert_equal(ngx.crc32_short("abc"), 891568578)
    assert_equal(ngx.crc32_short("def"), 214229345)
    assert_equal(ngx.crc32_short("another"), 2636723256)
  end)

  test('hmac_sha1()', function()
    local secret = string.char(220,58,17,206,77,234,240,187,69,25,179,182,186,38,57,83,120,107,198,148,234,246,46,96,83,28,231,89,3,169,42,62,125,235,137)
    local str    = string.char(1,225,98,83,100,71,237,241,239,170,244,215,3,254,14,24,216,66,69,30,124,126,96,177,241,20,44,3,92,111,243,169,100,119,198,167,146,242,30,124,7,22,251,52,235,95,211,145,56,204,236,37,107,139,17,184,65,207,245,101,241,12,50,149,19,118,208,133,198,33,80,94,87,133,146,202,27,89,201,218,171,206,21,191,43,77,127,30,187,194,166,39,191,208,42,167,77,202,186,225,4,86,218,237,157,117,175,106,63,166,132,136,153,243,187)

    assert_type(ngx.hmac_sha1(secret, str), 'string')
    assert_equal(ngx.hmac_sha1(secret, str), string.char(236,200,181,211,171,181,24,45,61,87,10,111,6,15,239,46,230,193,26,68))
  end)

  test('sha1_bin()', function()
    assert_type(ngx.sha1_bin("abc"), 'string')
    assert_equal(ngx.sha1_bin("abc"), string.char(169,153,62,54,71,6,129,106,186,62,37,113,120,80,194,108,156,208,216,157))
  end)

  test('md5()', function()
    assert_type(ngx.md5("abc"), 'string')
    assert_equal(ngx.md5("abc"), '900150983cd24fb0d6963f7d28e17f72')
  end)

  test('md5_bin()', function()
    assert_type(ngx.md5_bin("abc"), 'string')
    assert_equal(ngx.md5_bin("abc"), string.char(144,1,80,152,60,210,79,176,214,150,63,125,40,225,127,114))
  end)

  test('encode_base64()', function()
    assert_type(ngx.encode_base64("abc"), 'string')
    assert_equal(ngx.encode_base64("abc"), 'YWJj')
  end)

  test('decode_base64()', function()
    assert_type(ngx.decode_base64("YWJj"), 'string')
    assert_equal(ngx.decode_base64("YWJj"), 'abc')
  end)

  test('location.capture()', function()
    local s1 = ngx.location.stub("/stubbed", {}, { body = "OK" })

    assert_error(function() ngx.location.capture("/not-stubbed") end)
    assert_not_error(function() ngx.location.capture("/stubbed") end)
    assert_equal(#s1.calls, 1)

    assert_tables(ngx.location.capture("/stubbed"), { status = 200, headers = {}, body = "OK" })
    assert_equal(#s1.calls, 2)
  end)

  test('location.capture_multi()', function()
    local s1 = ngx.location.stub("/stubbed", {}, { body = "OK" })
    local s2 = ngx.location.stub("/stubbed2", {}, { body = "OK" })

    assert_not_error(function() ngx.location.capture_multi({ { "/stubbed" }, { "/stubbed2"} }) end)
    assert_equal(#s1.calls, 1)
    assert_equal(#s2.calls, 1)

    local r1, r2
    r1, r2 = ngx.location.capture_multi({ { "/stubbed" }, { "/stubbed2"} })
    assert_equal(r1.body, 'OK')
    assert_equal(r2.body, 'OK')
  end)

  test('req.read_body()', function()
    assert_nil(ngx.req.read_body())
  end)


  test('thread.spawn()', function()
    local concat = function(a, b) return "Hello " .. a .. b end
    assert_tables(ngx.thread.spawn(concat, "Wor", "ld"), {
      fun = concat, args = { "Wor", "ld" }
    })
  end)

  test('thread.wait()', function()
    local concat = function(a, b) return "Hello " .. a .. b end
    local thread = ngx.thread.spawn(concat, "Wor", "ld")
    local ok, res = ngx.thread.wait(thread)
    assert_equal(ok, true)
    assert_equal(res, "Hello World")
  end)

end)
