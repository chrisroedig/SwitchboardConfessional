![Screeny](http://2c92bcc0c57c3cdc1ba2-482e8486f1521bd9f3e96f2ddbe7bce1.r41.cf1.rackcdn.com/Screen Shot 2013-06-24 at 23.33.25 .png)
#SwitchBoardConfessional

A project to experiment with telephony APIs and live updating web UI.

Main purpose is for me to learn rails, node, backbone various associated technology and a good system for tying it all together for a live streaming single page app.

As such, test coverage is poor, and some of this wont make sense. Please feel free to let me know if some approaches can be improved.
 
This project uses Rails as it's main application and API server. A node.js server is also in the project to push new data to the main dashboard. The node-rails combo is linked via redis.



## To start this app in development mode....

* Make sure the configs for node and redis make sense (node.yml and redis.yml)
* twiml traffic shoudl point to `/tw/call` `/tw/sms` `/tw/call_update`
* Make sure a redis server is running
* `rails s` as usual for the rails part
* `cd node` and then `node server.js development` to start the node server
* both rails and node log to the same dir and draw configs from the same files
* good luck

