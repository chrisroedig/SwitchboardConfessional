#SwitchBoardConfessional

A project to experiment with telephony APIs and live updating web UI.

Main purpose is for me to learn rails, node, backbone various associated technology and a good system for tying it all together for a live streaming single page app.

As such, test coverage is poor, and some of this wont make sense. Please feel free to let me know if some approaches can be improved.
 
This project uses Rails as it's main application and API server. A node.js server is also in the project to push new data to the main dashboard. The node-rails combo is linked via redis.



## To start this app in development mode....

* Make sure the configs for node and redis make sense (node.yml and redis.yml)
* Make sure a redis server is running
* `rails s` as usual for the rails part
* `cd node` and then `node server.js development` to start the node server
* both rails and node log to the same dir and draw configs from the same files
* good luck

