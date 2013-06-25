SwitchB.Views.scalar_indicator = Backbone.View.extend({

	events:{

	},
	
	initialize : function(){
		//make all class methods run in context
		_.bindAll( this );
		//bind model changes directly to render
		this.model.bind('change',this.render)		
	},

	//set tag class and template
	className:'scalar',
	tagName:'div',
	template : JST['backbone/templates/scalar_indicator'],


	render : function(){
		//set rendered html to el contents
		this.$el.html( this.template( this.model.attributes ) );
		
    return this;
	},


})
