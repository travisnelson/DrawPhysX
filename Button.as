package  {	
  import flash.display.MovieClip;	
	import flash.events.*;

	public class Button extends MovieClip {
		private var imgOn:MovieClip;
		private var imgOff:MovieClip;
		public var selected:Boolean;
		public var unselectHandler:Function;
		public var text:String;
		
		public function Button(iOn:MovieClip, iOff:MovieClip, UnselectHandler:Function, txt:String){
			imgOn=iOn;
			imgOff=iOff;
			unselectHandler=UnselectHandler;
			text=txt;
			
			imgOn.visible=false;
			selected=false;
			
			addChild(imgOn);
			addChild(imgOff);
			
			addEventListener(MouseEvent.CLICK, mouseClickHandler);
		}
		
		public function select(){
			unselectHandler(this);
			imgOn.visible=true;
			imgOff.visible=false;
			selected=true;
		}
		
		public function unselect(){
			imgOn.visible=false;
			imgOff.visible=true;
			selected=false;
		}
		
		public function mouseClickHandler(evt:MouseEvent){
			if(selected)
				unselect();
			else
				select();
		}
		
	}
	
}