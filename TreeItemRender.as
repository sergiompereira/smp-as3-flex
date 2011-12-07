package com.smp.flex
{
	import flash.net.URLRequest;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	
	import mx.controls.Alert;
	import mx.collections.*;
	import mx.controls.treeClasses.*;


	public class TreeItemRender extends TreeItemRenderer
	{
		
		protected var _link:String;
		
		 // Define the constructor.
        public function TreeItemRender() {
            super();
        }
        
        // Override the set method for the data property
        // to set the font color and style of each node.
        override public function set data(value:Object):void {
            super.data = value;
           	//super.label.mouseEnabled = false;
           	buttonMode = true;
           	if(typeof(value) == "xml"){
	           	if(value.@link != null && value.@link.toString().length>0){
	           		this.link = value.@link;
					
	           	}
	           	if((value as XML).localName() == "pagina" ){
	           		super.label.y = super.label.y+15;
	           		
	           	}
	     
           	}
           
        }
        
        public function set link(sLink:String):void{
        	_link = sLink;
        	super.label.addEventListener(MouseEvent.MOUSE_UP, onUp);
        }
     
     	protected function onUp(evt:MouseEvent):void {
			if(_link!=""){
				navigateToURL(new URLRequest(_link), "_self");
			}
     		
     	}
     

	}
}