//view tied to event feed collection
SwitchB.Views.activity_feed = Backbone.View.extend({
	events:{

	},

	initialize : function(){
		//make all class methods run in context
		_.bindAll( this );
		
		this.populate();

		//bind collection changes directly to render
		//render simply replaces all html
		//depending on how this view works we might make smarter handlers
		this.collection.bind('add',this.handle_add)

		this.collection.bind('remove',this.handle_remove)

	},
	//class tag, NO template
	className:'activity_feed',
	tagName:'ul',
	
	//array of views in this collection view
	efi_array:[],

	populate : function(){
		
		
		//scan collection
		this.efi_array = this.collection.map(function( efi ){
			var efi_new = new SwitchB.Views.activity_feed_item({
				model: efi,
			})
			return efi_new
		})
		return this
	},
	render : function(){
		//reference self, .each() callback runs in list item view scope
		var feed_view = this;

		//clear out the el
		$(this.el).empty();

		//each the efi view's and add them to the list 
		//wrap in underscore since it's a native array
		_( this.efi_array ).each( function( efi_v ){
			$( feed_view.el ).append( efi_v.render().el )
		} );
		return this;
	},
	handle_add : function(e){
		
		
		this.populate()
		
		var new_view = _.find( this.efi_array,function(v){
			return v.model.attributes.id == e.id
		})
		new_view.$el.hide()
		this.render()
		new_view.$el.fadeIn()

	},
	handle_remove : function( e ,attr ){

		$('.activity_item[data_id='+e.id+']',this.el).fadeOut(500,function(){this.remove()})

	}
})

//view tied to individual event in feed
SwitchB.Views.activity_feed_item = Backbone.View.extend({
	events:{

	},


	initialize : function(){
		//make all class methods run in context
		_.bindAll( this );
		//bind model changes directly to render
		this.model.bind('change',this.handle_update)		

		//attempt to load the custom template for this activity
		tmp_str = 'backbone/templates/events/'
		tmp_str += this.model.attributes.template
		if( JST[ tmp_str ] !== undefined ){
			this.template = JST[ tmp_str ]
		}
	},


	className:'activity_item',
	tagName:'li',
	template : JST['backbone/templates/events/activity_feed_item'],
	attributes :{},

	render : function(){

		this.$el.attr('data_id', this.model.attributes.id);
		//set rendered html to el contents
		this.$el.html( this.template( this.model.attributes ) );
		
    return this;	
	},
	handle_update:function(e){
		this.render();
		//do something fancy here to highlight the change
	}
})