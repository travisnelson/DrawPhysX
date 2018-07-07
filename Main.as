package {
	import flash.display.Sprite;
	import flash.events.*;
  import flash.display.MovieClip;	
	import flash.text.TextField;
	import flash.utils.*;
	import Box2D.Dynamics.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import General.*;
	
	public class Main extends MovieClip {
		// physics vars
		public var m_world:b2World;
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1.0/30.0;
		static public var m_sprite:Sprite;
		public var m_input:Input;

		// mouse drawing stuff
		public var mouseBody;
		public var mousePath:Array=new Array();
		public var Joints:Array=new Array();

		// config vars
		public var lineDistance=0.1;
		public var lineThickness=0.05;

		// buttons
		var Buttons:Array=new Array();
		var handBtn:MovieClip;
		var pencilBtn:MovieClip;
		var wobblyBtn:MovieClip;
		var flexBtn:MovieClip;

		public function Main(){
			// Add event for main loop
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);

			m_sprite = new Sprite();
			addChild(m_sprite);
			m_input = new Input(m_sprite);

			// Create world AABB
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-100.0, -100.0);
			worldAABB.upperBound.Set(100.0, 100.0);
			
			// Define the gravity vector
			var gravity:b2Vec2 = new b2Vec2(0.0, 10.0);
//			var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
			
			// Allow bodies to sleep
			var doSleep:Boolean = true;

			// Construct a world object
			m_world = new b2World(worldAABB, gravity, doSleep);

			// debug drawing
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			var dbgSprite:Sprite = new Sprite();
			addChild(dbgSprite);
			dbgDraw.m_sprite = m_sprite;
			dbgDraw.m_drawScale = 30;
			dbgDraw.m_fillAlpha = 0.6;
			dbgDraw.m_lineThickness = 1.0;
			dbgDraw.m_drawFlags = b2DebugDraw.e_shapeBit;
			m_world.SetDebugDraw(dbgDraw);			
	
			makeButtons();

			makeGround();
		}
		
		public function makeButtons(){
			handBtn=new Button(new HandBtnOn(), new HandBtnOff(), unselectBtns,
												"Click and drag to move objects around.");
			handBtn.x=30;
			handBtn.y=5;
			addChild(handBtn);
			Buttons.push(handBtn);

			pencilBtn=new Button(new PencilBtnOn(), new PencilBtnOff(), unselectBtns,
											  "Draw to create objects.");
			pencilBtn.x=65;
			pencilBtn.y=5;
			addChild(pencilBtn);
			Buttons.push(pencilBtn);
			
			wobblyBtn=new Button(new wobblyOn(), new wobblyOff(), unselectBtns,
										    "Draw to create ropes.");
			wobblyBtn.x=100;
			wobblyBtn.y=5;
			addChild(wobblyBtn);
			Buttons.push(wobblyBtn);
			
			flexBtn=new Button(new flexOn(), new flexOff(), unselectBtns,
												"Draw to create springy objects.");
			flexBtn.x=135;
			flexBtn.y=5;
			addChild(flexBtn);
			Buttons.push(flexBtn);
			
			pencilBtn.select();
		}
		
		public function unselectBtns(which:MovieClip){
			for each (var btn in Buttons){
				btn.unselect();
			}
			toolTip.text=which.text;
			
		}
		
		public function makeGround(){
			var bodyDef:b2BodyDef;
			bodyDef = new b2BodyDef();
			bodyDef.position.x = (550/2)/30;
			bodyDef.position.y = 400/30;
			bodyDef.angularDamping = 0.1;
			bodyDef.linearDamping = 0.1;
			bodyDef.allowSleep=false;			

			var body = m_world.CreateBody(bodyDef);

			var shapeDef:b2PolygonDef=new b2PolygonDef();
			shapeDef.vertexCount=4;
			shapeDef.vertices[0].Set((550/2)/30,-1);
			shapeDef.vertices[1].Set((550/2)/30,1);
			shapeDef.vertices[2].Set(-(550/2)/30,1);
			shapeDef.vertices[3].Set(-(550/2)/30,-1);
			shapeDef.density = 0.5;
			shapeDef.friction = 0.1;
			shapeDef.restitution = 0.2;
			body.CreateShape(shapeDef);			

			shapeDef.vertexCount=4;
			shapeDef.vertices[0].Set(0.25, -1);
			shapeDef.vertices[1].Set(0, -1);
			shapeDef.vertices[2].Set(0, -1.25);
			shapeDef.vertices[3].Set(0.25, -1.25);
			body.CreateShape(shapeDef);			


			shapeDef.vertexCount=4;
			shapeDef.vertices[0].Set(7, -4);
			shapeDef.vertices[1].Set(6, -4);
			shapeDef.vertices[2].Set(6, -5);
			shapeDef.vertices[3].Set(7, -5);
			body.CreateShape(shapeDef);			

			
		}
		
		public function addLocalY(vec:b2Vec2, angle:Number, addY:Number):b2Vec2{
			var newV=rotateVec(vec, -angle);
			newV.y+=addY;
			return rotateVec(newV, angle);			
		}

		public function addLocalX(vec:b2Vec2, angle:Number, addX:Number):b2Vec2{
			var newV=rotateVec(vec, -angle);
			newV.x+=addX;
			return rotateVec(newV, angle);			
		}

		public function rotateVec(vec:b2Vec2, angle:Number):b2Vec2{
			return new b2Vec2((vec.x * Math.cos(angle)) - (vec.y * Math.sin(angle)),
												(vec.x * Math.sin(angle)) + (vec.y * Math.cos(angle)));
		}
		
		public function findAngle(startV:b2Vec2, endV:b2Vec2):Number{
			var vec=new b2Vec2(endV.x-startV.x, endV.y-startV.y);
			
			return Math.asin(vec.y / Math.sqrt(Math.pow(vec.x,2) + Math.pow(vec.y,2)));
		}
		
		
		public function createPathObject(){
			var bodyDef:b2BodyDef;
			// body definition
			bodyDef = new b2BodyDef();
//			bodyDef.position.x = 0;
//			bodyDef.position.y = 0;
			bodyDef.angularDamping = 0.1;
			bodyDef.linearDamping = 0.1;
			bodyDef.allowSleep=false;			

			mouseBody = m_world.CreateBody(bodyDef);
			var lastMouseBody:b2Body=null;

			for(var i=0;i<mousePath.length-1;++i){
				var shapeDef:b2PolygonDef=new b2PolygonDef();
				shapeDef.vertexCount=4;
			
				var vec1, vec2;
			
				if(mousePath[i].x > mousePath[i+1].x){
					vec1=mousePath[i+1];
					vec2=mousePath[i];
				} else {
					vec1=mousePath[i];
					vec2=mousePath[i+1];
				}

				var angle=findAngle(vec1, vec2);
				var newV, newV2;
							
				newV=addLocalY(vec1, angle, lineThickness);
				shapeDef.vertices[0].Set(newV.x, newV.y);

				newV=addLocalY(vec1, angle, -lineThickness);
				shapeDef.vertices[1].Set(newV.x, newV.y);

				newV=addLocalY(vec2, angle, -lineThickness);
				shapeDef.vertices[2].Set(newV.x, newV.y);

				newV=addLocalY(vec2, angle, lineThickness);
				shapeDef.vertices[3].Set(newV.x, newV.y);


				shapeDef.density = 0.5;
				shapeDef.friction = 0.1;
				shapeDef.restitution = 0.2;
				mouseBody.CreateShape(shapeDef);
				
				if(wobblyBtn.selected || flexBtn.selected){
					var jointDef;
					
					if(lastMouseBody){
						if(wobblyBtn.selected){
							jointDef = new b2DistanceJointDef();
							newV=addLocalX(mousePath[i], angle, 0.05);
							newV2=addLocalX(mousePath[i], angle, -0.05);
							
							jointDef.Initialize(mouseBody, lastMouseBody, newV, newV2);
							jointDef.collideConnected = false;
							m_world.CreateJoint(jointDef);
						} else if(flexBtn.selected){
							jointDef = new b2RevoluteJointDef();
							jointDef.Initialize(mouseBody, lastMouseBody, mousePath[i]);
							jointDef.maxMotorTorque = 25.0;
							jointDef.motorSpeed = 0.0;
							jointDef.enableMotor = true;							
							var myJoint=m_world.CreateJoint(jointDef);
							Joints.push(myJoint);
						}
					}
					lastMouseBody=mouseBody;
					mouseBody.SetMassFromShapes();			
					mouseBody = m_world.CreateBody(bodyDef);	
				}
			}
		
		
			mouseBody.SetMassFromShapes();			
		}
		
		public function UpdateJoints(){
			for each (var myJoint in Joints){
				var angleError:Number = myJoint.GetJointAngle();
				var gain:Number = 0.1;
				myJoint.SetMotorSpeed(-gain * angleError)
			}
		}
		
		public function Update(e:Event):void{
			// Update mouse joint
			UpdateMouseWorld()
			MouseDestroy();
			MouseDrag();
	
			UpdateJoints();
	
			m_world.Step(m_timeStep, m_iterations);
			Input.update();
		}
		
		// world mouse position
		static public var mouseXWorldPhys:Number;
		static public var mouseYWorldPhys:Number;
		static public var mouseXWorld:Number;
		static public var mouseYWorld:Number;
		public var mousePressed:Boolean=false;
		public var m_mouseJoint:b2MouseJoint;
		public var m_physScale:Number = 30;
		
		
		//======================
		// Update mouseWorld
		//======================
		public function UpdateMouseWorld():void{
			mouseXWorldPhys = (Input.mouseX)/m_physScale; 
			mouseYWorldPhys = (Input.mouseY)/m_physScale; 
			
			mouseXWorld = (Input.mouseX); 
			mouseYWorld = (Input.mouseY); 
		}
		

		public function MouseJointHandler():void {
			if (Input.mouseDown && !m_mouseJoint){
				var body:b2Body = GetBodyAtMouse();
				
				if (body){
					var md:b2MouseJointDef = new b2MouseJointDef();
					md.body1 = m_world.GetGroundBody();
					md.body2 = body;
					md.target.Set(mouseXWorldPhys, mouseYWorldPhys);
					md.maxForce = 300.0 * body.GetMass();
					md.timeStep = m_timeStep;
					m_mouseJoint = m_world.CreateJoint(md) as b2MouseJoint;
					body.WakeUp();
				}
			}			

			if (!Input.mouseDown){			
				if (m_mouseJoint){
					m_world.DestroyJoint(m_mouseJoint);
					m_mouseJoint = null;
				}
			}
			if (m_mouseJoint){
				var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
				m_mouseJoint.SetTarget(p2);
			}			
		}
		
		
		//======================
		// Mouse Drag 
		//======================
		
		public function MouseDrag():void{
			if(handBtn.selected){
				MouseJointHandler();
			}
			
			if(pencilBtn.selected || wobblyBtn.selected || flexBtn.selected){
				// mouse press
				if (Input.mouseDown && !mousePressed && 
						mouseYWorldPhys > (40/30)){
					mousePressed=true;
					
					mousePath=new Array();
					mousePath.push(new b2Vec2(mouseXWorldPhys, mouseYWorldPhys));
				}
					
				// mouse release
				if (!Input.mouseDown && mousePressed){
					mousePressed=false;
					mousePath.push(new b2Vec2(mouseXWorldPhys, mouseYWorldPhys));
					createPathObject();
				}
				
				// mouse move
				if(mousePressed){
					var here=new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
					var xdiff = Math.abs(here.x-mousePath[mousePath.length-1].x);
					var ydiff = Math.abs(here.y-mousePath[mousePath.length-1].y);
					
					if(Math.sqrt(xdiff*xdiff + ydiff*ydiff) > lineDistance){
						mousePath.push(here);
					}
				}
			}
		}
		
		
		
		//======================
		// Mouse Destroy
		//======================
		public function MouseDestroy():void{
			// mouse press
			if (!Input.mouseDown && Input.isKeyPressed(68/*D*/)){
				
				var body:b2Body = GetBodyAtMouse(true);
				
				if (body)
				{
					m_world.DestroyBody(body);
					return;
				}
			}
		}
		
		
		
		//======================
		// GetBodyAtMouse
		//======================
		private var mousePVec:b2Vec2 = new b2Vec2();
		public function GetBodyAtMouse(includeStatic:Boolean=false):b2Body{
			// Make a small box.
			mousePVec.Set(mouseXWorldPhys, mouseYWorldPhys);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(mouseXWorldPhys - 0.001, mouseYWorldPhys - 0.001);
			aabb.upperBound.Set(mouseXWorldPhys + 0.001, mouseYWorldPhys + 0.001);
			
			// Query the world for overlapping shapes.
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i)
			{
				if (shapes[i].GetBody().IsStatic() == false || includeStatic)
				{
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.GetBody().GetXForm(), mousePVec);
					if (inside)
					{
						body = tShape.GetBody();
						break;
					}
				}
			}
			return body;
		}
		

	}
	
	
}