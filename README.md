#Insomnia

## Description

Proxy based on nginx and lua that allows to suspend and resume traffic to your API or Application at will.


The guys at the gateway payment BrainTree released a very nice [presentation](http://drewolson.org/braintree_ha/presentation.html) on how they achieve HA. One of the many pearls of the slides is the BROXY (braintree proxy). This proxy allows to suspend/resume requests in quite a sophisticated way (it uses redis to persist requests).

Insomnia is a _simplistic_ alternative but quite effective in preventing mini-downtimes due to migrations, failovers, etc. 

Ningx and Lua is a killer combo (i had to say it one more time).


## Install

You need to have nginx with the [Lua module](http://wiki.nginx.org/HttpLuaModule#Installation) (not included in nginx by default) or you can use the nginx bundle [OpenResty](http://openresty.org/#Installation) where Lua and many other great plugins are already built in.

Download the `nginx.conf` from the repo.

And that's pretty much it.


## How to Use it

Run the nginx with insomnia…

	sudo /opt/openresty/nginx/sbin/nginx -c $PWD/nginx.conf


The nginx is acting as a proxy to a toy API called [Sentiment API](https://github.com/solso/sentiment-api-example). If you want to test it on your environment just replace the upstream server to point to your own API or App instead of `api-sentiment.3scale.net`

On a terminal window do a request: 

	$ time curl http://localhost:8080/v1/word/awesome.json
	{"word":"awesome","sentiment":4}
	real	0m0.264s
	user	0m0.002s
	sys	0m0.003s


On a different terminal let's put nginx to "sleep" using the insomnia API that is specified in the `nginx.conf` as the location `/insomnia/YOUR_SHARED_SECRET`

	$ curl -X PUT -d "sleep" http://localhost:8080/insomnia/YOUR_SHARED_SECRET
	sleeping

And do the same request that we did before


	$ time curl http://localhost:8080/v1/word/awesome.json

Nginx has accepted the request, but is not answering because nginx is sleeping. It will stay like this until curl times out, of we resume the traffic on nginx. To resume the traffic go to the terminal where you put nginx to sleep and do

	$ curl -X PUT -d "awake" http://localhost:8080/insomnia/YOUR_SHARED_SECRET
	awake

Go back to the terminal you did the curl and you will see that the request has finished successfully, but it has taken a long time 11s :-) 

	 time curl http://localhost:8080/v1/word/awesome.json
	{"word":"awesome","sentiment":4}
	real	0m11.455s
	user	0m0.003s
	sys	0m0.005s

The point is that although it took long it did not produce any error to the user. During those 11 seconds of traffic suspension you might have migrated/restarted/moved your backend without worry. All traffic was kept in nginx until the backend was available again.


## Considerations

* Change the YOUR_SHARED_SECRET from the location definition to some random string that only the persons that can suspend traffic know. 

* Keep an eye on the `worker_connections`, the example uses 512, but it can go up to few thousands. The number of worker connections is the upper limit of concurrency supported by nginx. When traffic is suspended nginx still accepts requests, therefore it consumes a worker connection for each request it received and it does not frees it until the traffic is resumed. Concurrency piles up when traffic is suspended, for instance, if you have 10req/s and traffic is suspended for 30 seconds you need at least 30*10 worker_connections, otherwise you will get the message `worker_connections are not enough while connecting to upstream` on the nginx error log.

* The only locations that can be suspended/resumed by insomnia are those that use the insomnia check explicitly

 
	`location /v1 {
		access_by_lua '
    		while(shared_state.insomnia==true) do
          		ngx.sleep(0.2)
        	end
      	';
		proxy_pass http://api-backend;
	}`

	`location /v2 {
		proxy_pass http://api-backend;
	}`

	traffic to `/v1` can be suspend/resumed by insomnia, whereas requests `/v2` will not be interrupted. 

* On the code above you can see how the suspended traffic is achieved, with a good old `sleep`. Worry not, `sleep` in nginx is non-blocking, so it has no negative effects besides aesthetics.



 










