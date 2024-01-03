package openfl.display;

import openfl.text.TextField;
import openfl.text.TextFormat;
#if gl_stats
import openfl.display._internal.stats.Context3DStats;
import openfl.display._internal.stats.DrawCallContext;
#end
#if flash
import openfl.Lib;
#end

#if openfl
import openfl.system.System;
#end

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class FPS extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Int;

	@:noCompletion private var cacheCount:Int;
	@:noCompletion private var currentTime:Float;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		#if mobile
        defaultTextFormat = new TextFormat('_sans', Std.int(14 * Math.min(openfl.Lib.current.stage.stageWidth / FlxG.width, openfl.Lib.current.stage.stageHeight / FlxG.height)), color);
        #else
		defaultTextFormat = new TextFormat("_sans", 14, color);
        #end
		autoSize = LEFT;
		multiline = true;
		text = "FPS: ";

		cacheCount = 0;
		currentTime = 0;
		times = [];

		#if flash
		addEventListener(Event.ENTER_FRAME, function(e)
		{
			var time = Lib.getTimer();
			__enterFrame(time - currentTime);
		});
		#end
	}

	// Event Handlers
	@:noCompletion
	private #if !flash override #end function __enterFrame(deltaTime:Float):Void
	{
		currentTime += deltaTime;
		times.push(currentTime);

		while (times[0] < currentTime - 1000)
		{
			times.shift();
		}

		var currentCount = times.length;
		currentFPS = Math.round((currentCount + cacheCount) / 2);
		if (currentFPS > ClientPrefs.data.framerate) currentFPS = ClientPrefs.data.framerate;

		if (currentCount != cacheCount /*&& visible*/)
		{
			var memoryMegas:Float = Math.abs(FlxMath.roundDecimal(System.totalMemory / 1000000, 1));
			text = 'FPS: $currentFPS' +
				'\nMemory: $memoryMegas MB' +
				'\nPlatform: ${lime.system.System.platformLabel}';

			textColor = 0xFFFFFFFF;
			if (memoryMegas > 3000 || currentFPS <= ClientPrefs.data.framerate / 2)
			{
				textColor = 0xFFFF0000;
			}
		}

		cacheCount = currentCount;
	}
}
