package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;

class Main extends Sprite {

	public function new() {
		super();
		addChild(new FlxGame(ViewPort.width, ViewPort.height, PlayState, ViewPort.zoom, true, false));
	}
}

class ViewPort {
	public static var width: Int = 160;
	public static var height: Int = 144;
	public static var zoom: Int = 3;
}
