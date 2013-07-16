# Reasoning
While authing against our Google Apps domain has worked pretty well up until now, we really needed a way to auth against out Github organization. Not everyone who is accessing some of our protected development content has an email account in our Google Apps domain. They do, however, have access to our github org.

Sadly it seems that apache and nginx modules for doing oauth are lacking.

I was hoping to avoid the whole lua approach (and `mod_authnz_external` was a no go from the start). However I realized that Brian Akins (@bakins) had done some fancy omnibus work that got me 90% of the way there.

From there it was a matter of patching up the omnibus repo to bring it to current versions as well as adding in a few additional components.


# Requirements
## Software
You'll either need to build your own nginx packages from here:
- https://github.com/bakins/omnibus-nginx

or you can grab mine from here:
- https://app.box.com/s/ji0kpu8ybkcd4asoitse (nginx_1.2.8-1.ubuntu.12.04_amd64.deb)

These are omnibus builds of nginx + openresty created by @bakins. They have pretty much everything you need to get started to do some fancy lua application related stuff right in nginx.

## GitHub application
Go to your github account and add a new application under your github org. (https://github.com/organizations/ORGNAME/settings/applications/)

- Application Name is arbitrary.
- Homepage URL is the url to the site you're protecting
- Callback URL is `http[s]://mysite.com/_callback`

Make note of the ID and Secret you're given. You'll need those.

# Configuration
If you just want a simple test, it's pretty straightforward.

- install the package
- edit `/opt/nginx/etc/nginx.conf` with the attached conf file
- edit `/opt/nginx/etc/access.lua` with the attach lua script making the appropriate changes noted below

```lua
local oauth = {
    app_id = "MY_GITHUB_APP_ID",
    app_secret = "MY_GITHUB_APP_SECRET",
    orgs_whitelist = {["MY_GITHUB_ORG"]=true},
```

Note that org names are case-sensitive.

# Start nginx (this will start in the foreground)
```bash
cd /opt/nginx/
sudo LD_PRELOAD=/opt/nginx/lib/libmmap_lowmem.so nginx -c /opt/nginx/etc/nginx.conf -p /opt/nginx/etc/
```

In another window, you might want to `tail -f /opt/nginx/log/*`

Load up the site in your browser. You should get redirected to github to authorize the application. After you auth, you'll get redirected BACK to your site (and will likely get a 404 since we don't actually have any content to serve).

This is just a POC really. You'll want to likely tweek the `access.lua` appropriately and maybe even restrict access to a given repository.

# References
I got most of the inspiration (okay all of it) from a shitload of other people. Here are the big ones in no specific order

- https://github.com/bakins/omnibus-nginx
- http://seatgeek.com/blog/dev/oauth-support-for-nginx-with-lua
- https://github.com/NorthIsUp/nginx-oauth-on-dotcloud

I'm actually pretty excited about the openresty stuff but really the ability to extend nginx generically with lua is pretty awesome too.