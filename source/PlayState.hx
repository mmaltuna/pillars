package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

import utils.data.TilePoint;
import Main.ViewPort;

class PlayState extends FlxState {

	public var board: Board;

	private static var boardWidth = 60;
	private static var boardHeight = 120;

	private var foreground: FlxSprite;

	override public function create() {
		super.create();

		var boardX: Int = Std.int((ViewPort.width - boardWidth) / 2);
		var boardY: Int = Std.int((ViewPort.height - boardHeight) / 2);

		board = new Board(boardX, boardY);
		add(board.gfxSet);

		foreground = new FlxSprite(0, 0);
		foreground.loadGraphic("assets/images/foreground-6x12.png", 160, 144);
		add(foreground);
	}

	override public function update(elapsed: Float) {
		board.update(elapsed);

		super.update(elapsed);
	}
}
