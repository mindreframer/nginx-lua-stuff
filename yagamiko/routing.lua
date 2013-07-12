#!/usr/bin/env lua

local router = require('yagami.router')
router.setup()

---------------------------------------------------------------------
map('^/id',                         'id.getid')

--test map
map('^/test', 'test.test')



map('^/hello%?name=(.*)',           'test.hello')
map('^/longtext',                   'test.longtext')
map('^/ltp',                        'test.ltp')
map('^/ip',                         'ip.getipnew')




-- business
map('^/goods',                      'goods.bootstrap')
map('^/brand',                      'brand.bootstrap')
map('^/comment',					'comment.bootstrap')
map('^/notice',						'notice.bootstrap')

-- image/file/audio storage
map('^/upload', 					'storage.savetoweedfs')





map('^/service/soundget','sound.soundget')
map('^/service/soundmake','sound.soundmake')

---------------------------------------------------------------------
