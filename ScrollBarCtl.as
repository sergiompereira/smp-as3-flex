	
//IMPORTS

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import nl.demonsters.debugger.MonsterDebugger;
	

	import srg.display.utils.DragHandler;
	import srg.animation.TweenSafe;
	import srg.display.utils.ShapeUtils;

	import spark.components.Group;
	import spark.components.supportClasses.GroupBase;

//PUBLIC VARIABLES

	[SkinPart(required="true")]
	public var buttonControl:GroupBase;
	[SkinPart(required="true")]
	public var barControl:GroupBase;
	
	
	//defaults to local skin
	//skinClass property can be reset by the client 
	[Bindable]
	public var skinClassRef:Class = srg.flex.controls.ScrollBarSkin;

//PROTECTED AND PRIVATE VARIABLES

	protected var _scrollLength:Number = 0;
	protected var _scrollBounds:Rectangle;
	
	private var _target:DisplayObject;
	private var _property:String = "y";
	private var _propertyLength:String;
	private var _altPropertyLength:String;
	
	private var _elasticity:Number = 1;
	private var _onWheel:Boolean = true;
	
	private var _frameInitY:Number;
	private var _targetInitY:Number;
	private var _targetInitHeight:Number;
	
	private var _timer:Timer = new Timer(10);;
	private var _elasticityTimer:Timer = new Timer(10);
	
	private var _tween:TweenSafe = new TweenSafe();
	private var _dragHnd:DragHandler = new DragHandler();
	
	private var _destinationScrollPosition:Number;
	private var _scrollPositionOnUpdate:uint = 0;
	
	private var _addedToStage:Boolean = false;
	
	private var _targetMask = new Sprite();
	private var _maskWidth:Number;
	private var _maskHeight:Number;
	private var _maskEdge:Number;
	
//PUBLIC FUNCTIONS

	public function set scrollLength(value:Number):void {
		_scrollLength = value;
	}
	
	public function set scrollBounds(value:Rectangle):void {
		_scrollBounds = value;
	}
	
	public function set target(value:DisplayObject):void {
		_target = value;
	}

	public function set elasticity(value:Number):void {
		_elasticity  = value;
	}

	public function set property(value:String):void {
		_property = value;
	}

	public function set wheelEnabled(value:Boolean):void {
		_onWheel = value;
	}
	
	/**
	 * margin : Accepts the mask margin. If < 0, no mask is applyed.
	 */
	public function set maskWidth(value:Number):void {
		_maskWidth = value;
	}
	
	public function set maskHeight(value:Number):void {
		_maskHeight = value;
	}
	
	public function set maskEdge(value:Number):void {
		_maskEdge = value;
	}
	

	
//PROTECTED AND PRIVATE FUNCTIONS

	protected function init():void 
	{
		if(this.stage != null){
			_addedToStage = true;
			buttonControl.buttonMode = true;
			if (_target == null) {
				throw new Error("ScrollBar->Define a target object.")
			}else {
				setupProperties();
				setupEventListeners();
			}
		}else {
			throw new Error("ScrollBar->Must be added to the display list.")
		}
	}
	
	private function setupProperties():void{
		
			this.x = _target.x;
			this.y = _target.y;
			
			_frameInitY = this[_property];
			_targetInitY = _target[_property];
			_destinationScrollPosition = buttonControl[_property];
			
			if (_property == "y") {
				_propertyLength = "height";
				_altPropertyLength = "width";
			}else {
				_propertyLength = "width";
				_altPropertyLength = "height";
			}

			_targetInitHeight = _target[_propertyLength];
			
			if(_scrollLength == 0){
				_scrollLength = barControl[_propertyLength];
			}
			
			var scrolldistance:Number = barControl[_propertyLength] - buttonControl[_propertyLength];
			
			_scrollBounds = new Rectangle();
			
			if (_property == "y") {
				_scrollBounds.x = 0;
				_scrollBounds.y = 0;
				_scrollBounds.width = 0;
				_scrollBounds.height = scrolldistance;
			}else {
				_scrollBounds.x = 0;
				_scrollBounds.y = 0;
				_scrollBounds.width = scrolldistance;
				_scrollBounds.height = 0;
			}
			
			if (_maskWidth > 0 && _maskHeight > 0) {
				
				if (_property == "y") {
					_targetMask.addChild(ShapeUtils.createRectangle(_maskWidth, _maskHeight, 0x000000,1,0, _maskEdge));
					_targetMask.addChild(ShapeUtils.createGradientRectangle(_maskWidth,_maskEdge, [0x000000, 0x000000],[0,1],[0,255],-1, 0,0));
					_targetMask.addChild(ShapeUtils.createGradientRectangle(_maskWidth, _maskEdge, [0x000000, 0x000000], [1, 0], [0, 255], -1, 0, _maskHeight + _maskEdge));
				}
		
				
				if(_maskEdge>0){
					_target.cacheAsBitmap = true;
					_targetMask.cacheAsBitmap = true;
				}
				
				maskContainer.addChild(_targetMask);
				
				
				_target.mask = _targetMask;
			}
			
	}
	
	private function setupEventListeners():void{
			
		
		_dragHnd.setDraggable(buttonControl, false, _scrollBounds.x, _scrollBounds.y, _scrollBounds.width, _scrollBounds.height,null,null,onDrag);

		
		if (barControl != null)
		{
			barControl.buttonMode = true;
			barControl.addEventListener(MouseEvent.MOUSE_UP, onRepositionbuttonControl);
		}
		

		_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
		_timer.start();
		
		if (_onWheel)
		{	
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		}
		
	}
	
	/*
	private function onStageReady(evt:Event = null):void 
	{	
		if (_target != undefined) 
		{		
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		}
	}
	*/
	
	private function onTimer(evt:TimerEvent):void
	{
		evalScrollable();
	}
	
	public function evalScrollable():Boolean 
	{
		_timer.removeEventListener(TimerEvent.TIMER, evalScrollable);
		_timer.reset();
		
		if (_target[_propertyLength] > _scrollLength) {
			
			this.x = _target.x;
			this.y = _target.y;
			
			this.visible = true;
			
			if(_maskEdge>0){
				_target.cacheAsBitmap = true;
				_targetMask.cacheAsBitmap = true;
			}
			return true;
		} else {
			this.visible = false;
			verifyTargetReset();
			return false;
		}
		
		return false;
	}
	
	private function verifyTargetReset():void{
		if(_target[_property] != 0){
			buttonControl[_property] = 0;
			_tween.setTween(_target, _property, TweenSafe.REG_EASEOUT, _target[_property], 0, 0.5)
		}
	}
	
	private function onDrag(evt:*):void 
	{
		this.addEventListener(Event.ENTER_FRAME, moveTarget, false, 0, true);
		this.removeEventListener(Event.ENTER_FRAME, movebuttonControl);
	}
	
	private function moveTarget(evt:Event):void 
	{
		if(Math.abs(_target[_property] - getTargetPosition()) > 1){
			setTargetPosition();
		}else {
			
			this.removeEventListener(Event.ENTER_FRAME, moveTarget);
			if(Math.abs(_destinationScrollPosition - buttonControl[_property]) < 1){
				this.removeEventListener(Event.ENTER_FRAME, movebuttonControl);
			}
		}
	}
	private function setTargetPosition() {
		_target[_property] += (getTargetPosition()-_target[_property])/_elasticity;
	}
	
	private function getTargetPosition():Number {
		
		return Math.round(_targetInitY + ((_scrollLength-_target[_propertyLength] )/(barControl[_propertyLength] - buttonControl[_propertyLength]))*buttonControl[_property] + (_frameInitY-_targetInitY));
	}
	
	private function onRepositionbuttonControl(evt:MouseEvent):void 
	{
		var bkgLoc = new Point();
		if (_property == "y") {
			bkgLoc[_property] = evt.localY;
		}else {
			bkgLoc[_property] = evt.localX;
		}
		
		if (bkgLoc[_property] < _scrollBounds[_propertyLength]) {
			_destinationScrollPosition = bkgLoc[_property];
			trace("_destinationScrollPosition a "+_destinationScrollPosition)
		} else {
			_destinationScrollPosition = _scrollBounds[_propertyLength];
			trace("_destinationScrollPosition b "+_destinationScrollPosition)
		}
		trace("_destinationScrollPosition "+_destinationScrollPosition)
		this.addEventListener(Event.ENTER_FRAME, movebuttonControl, false, 0, true);
	}
	
	
	//updates this if there have been changes on the target 
	public function updateScroller(scrollPosition:uint = 0):void {
		
		if(scrollPosition < 3){
			_scrollPositionOnUpdate = scrollPosition;
		}
		
		_targetInitHeight= _target[_propertyLength];
		_timer.addEventListener(TimerEvent.TIMER, onTimerUpdate, false, 0, true);
		_timer.start();

	}
	
	//updates scroll button on regard of target position change
	public function updateScrollButton():void 
	{
		var scrollPosition:Number = (_target[_property] - _targetInitY - (_frameInitY - _targetInitY)) / ((_scrollLength - _target[_propertyLength] ) / (barControl[_propertyLength] - buttonControl[_propertyLength]));

		if (scrollPosition > _scrollBounds[_propertyLength]) {
			scrollPosition = _scrollBounds[_propertyLength];
		}else if(scrollPosition < 0) {
			scrollPosition = 0;
		}else {
			scrollPosition = scrollPosition;
			//buttonControl[_property] = scrollPosition;
		}
		
		_tween.setTween(buttonControl, _property, TweenSafe.REG_EASEIN, buttonControl[_property], scrollPosition, 0.5)
	}
	
	//updates target on regard of scroll button change
	public function updateTarget():void
	{
		/*
		var bkgLoc = new Point();
		bkgLoc[_property] = buttonControl[_property];
		if (bkgLoc[_property] < _scrollBounds[_propertyLength]) {
			_destinationScrollPosition = bkgLoc[_property];
		} else {
			_destinationScrollPosition = _scrollBounds[_propertyLength];
		}
		*/
		
		this.addEventListener(Event.ENTER_FRAME, moveTarget, false, 0, true);
	}
	
	
	private function onTimerUpdate(evt:TimerEvent) {
		_timer.removeEventListener(TimerEvent.TIMER, onTimerUpdate);
		_timer.reset();
		
		var scrollactive:Boolean = evalScrollable();
		
		switch(_scrollPositionOnUpdate){
			case 0:
				_destinationScrollPosition = 0;
				break;
			case 1:
				_destinationScrollPosition = _scrollBounds[_propertyLength];
				break;
			case 2:
				_destinationScrollPosition = buttonControl[_property];
				break;
			
		}
		
		if(!scrollactive){
			_destinationScrollPosition = 0;	
		}	
		
		//this.addEventListener(Event.ENTER_FRAME, moveTarget, false, 0, true);
		this.addEventListener(Event.ENTER_FRAME, movebuttonControl, false, 0, true);
	}
	
	private function movebuttonControl(evt:Event):void
	{
		moveTarget(evt);
		buttonControl[_property] += (_destinationScrollPosition - buttonControl[_property]) / _elasticity;
		
	}
	
	public function reset():void {
		this.removeEventListener(Event.ENTER_FRAME, moveTarget);
		this.removeEventListener(Event.ENTER_FRAME, movebuttonControl);
		buttonControl.removeEventListener("Drag", onDrag);
		if(barControl != null){
			barControl.removeEventListener(MouseEvent.MOUSE_UP, onRepositionbuttonControl);
		}

		_target[_property] = _targetInitY;
		buttonControl[_property] = 0;
		_targetInitHeight= _target[_propertyLength];
		_timer.addEventListener(TimerEvent.TIMER, onTimer, false, 0, true);
		_timer.start();

	}
	
	private function onWheel(evt:MouseEvent):void {
		
		var scrollPosition:Number = buttonControl[_property] - evt.delta*4;
		if (scrollPosition > _scrollBounds[_propertyLength]) {
			_destinationScrollPosition = _scrollBounds[_propertyLength];
		}else if(scrollPosition < 0) {
			_destinationScrollPosition = 0;
		}else {
			_destinationScrollPosition = scrollPosition;
			buttonControl[_property] = scrollPosition;
		}
		this.addEventListener(Event.ENTER_FRAME, movebuttonControl, false, 0, true);
	
	}
