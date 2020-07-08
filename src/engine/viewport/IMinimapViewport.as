// ActionScript file
package engine.viewport
{
	import engine.audio.IPositionalSound;
	
	public interface IMinimapViewport
	{
		function moveTo(x:int, y:int):void;
		
		//sets the borders also
		function set zoomLv(zoomLv:Number):void;
		function get zoomLv():Number;
		
		function set sizeWidth(width:int):void;
		function set sizeHeight(height:int):void;
		function get sizeWidth():int;
		function get sizeHeight():int;
		
		function set position_x(x:int):void;
		function set position_y(y:int):void;
		function get position_x():int;
		function get position_y():int;
		
		function set speed(speed:Number):void;
		function get speed():Number;
		
		function set border_x(border_x:int):void;
		function set border_y(border_y:int):void;
		function get border_x():int;
		function get border_y():int;
		
		//if within border, can move. Else, restrict within borders
		//function checkWithinMovable():Boolean;
		
		function set prepZonePercentage(prepZonePercent:Number):void;
		function get prepZonePercentage():Number;
		
		function checkZone(IPSnd:IPositionalSound):String;
	}
}