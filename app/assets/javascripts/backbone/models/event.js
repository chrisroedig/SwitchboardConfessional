SwitchB.Models.Activity = Backbone.Model.extend({
	initialize:function(attr,opt){
		_.bindAll( this );
		//bind to model update/delete events
		//build title and content from the attributes


		SwitchB.bus.on( 'model:activity:update:'+attr.uid ,this.update_handler)
		SwitchB.bus.on( 'model:activity:delete:'+attr.uid ,this.delete_handler)

	},
	sync:function(){
		//do nothing
	},
	update_handler:function(e,new_attr){
		this.set(new_attr)
	},
	delete_handler:function(e){
		// not sure what to do here, deletes are currently handled in the collections
	},
}); 