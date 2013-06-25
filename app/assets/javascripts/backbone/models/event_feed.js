SwitchB.Models.ActivityFeed = Backbone.Collection.extend({
  
  model: SwitchB.Models.Activity,
  
  initialize:function(attr,opt){
		_.bindAll( this );
		

		SwitchB.bus.on('model:activity:add',this.new_handler)
		SwitchB.bus.on('model:activity:remove',this.del_handler)
	},
	
	new_handler : function(e, attr){
		if(!attr.id){
			attr.id = Date.now()+'_'+Math.round(Math.random()*100000)
		}
		
		//check if we already have this one
		var check = this.where( { uid:attr.uid } )
		
		if( check.length ){
			//redelegate the event as updated
			check[0].set(attr)
		
		}else{
			//add the new item

			this.add(attr)	
		}
		
	},
	
	del_handler : function(e, attr){
		
		var models = this.where(attr)
		this.remove( models )

	},

});