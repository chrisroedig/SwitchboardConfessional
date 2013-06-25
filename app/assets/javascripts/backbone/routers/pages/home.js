SwitchB.Routers.home = Backbone.Router.extend({

  routes: {
    "":                 "route_root",    // #help
  },
  route_root : function(){
  	this.init_all_scalars();
    this.init_feed();

    //start up event system
    SwitchB.EventSources.Socket.initialize()
  },
  init_feed : function(){
    
    var event_collect = new SwitchB.Models.ActivityFeed( [] ) 

    var feed_view = new SwitchB.Views.activity_feed({
      collection:event_collect,
      el:$('#feedBox ul')
    }).render()
  },

  init_all_scalars : function(){
  	$('#scalarPanel').empty()
    _.each( SwitchB.DataInit.globals, this.init_scalar )
  },
  init_scalar : function( obj, key ){
    obj.id = key
		var scalar_model = new SwitchB.Models.Scalar( obj )
  	var scalar_view = new SwitchB.Views.scalar_indicator( { model : scalar_model } )
  	scalar_view.render()
  	$('#scalarPanel').append(
  		scalar_view.el
  		)
  }
});