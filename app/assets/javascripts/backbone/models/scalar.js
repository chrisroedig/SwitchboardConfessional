SwitchB.Models.Scalar = Backbone.Model.extend({
	initialize:function(attr,opt){
		_.bindAll( this );
		//bind to model update event
		var ev_str = 'model:scalar:update:'+attr.id;
		SwitchB.bus.on(ev_str,this.update_handler)
		this.attributes.value=Math.round(this.attributes.value*10)/10.0

	},
	sync:function(){
		//do nothing
	},
	update_handler:function(e,new_attr){
		new_attr.value=Math.round(new_attr.value*10)/10.0
		this.set(new_attr)
		
	}
}); 