package ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

import PlayState;

class Cursor extends FlxTypedGroup<FlxSprite> {

	public var jewels: Array<FlxSprite>;
	private var outline: FlxSprite;
	private var playState: PlayState;

	public var x: Int;
	public var y: Int;

	public function new() {
		super();

		playState = PlayState.getInstance();

		x = 0;
		y = 0;

		jewels = new Array<FlxSprite>();

		var jewelA = new FlxSprite(PlayState.getPosX(0), PlayState.getPosY(0));
		jewelA.loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);
		jewelA.animation.frameIndex = Std.random(6);
		add(jewelA);

		var jewelB = new FlxSprite(PlayState.getPosX(0), PlayState.getPosY(1));
		jewelB.loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);
		jewelB.animation.frameIndex = Std.random(6);
		add(jewelB);

		var jewelC = new FlxSprite(PlayState.getPosX(0), PlayState.getPosY(2));
		jewelC.loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);
		jewelC.animation.frameIndex = Std.random(6);
		add(jewelC);

		jewels.push(jewelA);
		jewels.push(jewelB);
		jewels.push(jewelC);
	}

	public function move(x: Int, y: Int) {
		if (x >= 0 && x < PlayState.boardW && y >= 0 && y < PlayState.boardH - 2) {
			jewels[0].x = PlayState.getPosX(x);
			jewels[0].y = PlayState.getPosX(y);

			jewels[1].x = PlayState.getPosX(x);
			jewels[1].y = PlayState.getPosX(y + 1);

			jewels[2].x = PlayState.getPosX(x);
			jewels[2].y = PlayState.getPosX(y + 2);

			this.x = x;
			this.y = y;

			if (isPlaced())
				playState.status = PlayState.STATUS_SETTLING;
		}
	}

	public function rotate() {
		var jewel = jewels[2];

		jewels[2].y = PlayState.getPosY(y);
		jewels[0].y = PlayState.getPosY(y + 1);
		jewels[1].y = PlayState.getPosY(y + 2);

		jewels[2] = jewels[1];
		jewels[1] = jewels[0];
		jewels[0] = jewel;
	}

	public function isPlaced(): Bool {
		if (y + 3 >= PlayState.boardH)
			return true;

		return playState.getCellValue(x, y + 3) >= 0;
	}

	public function reload() {
		move(2, 0);

		jewels[0].animation.frameIndex = Std.random(6);
		jewels[1].animation.frameIndex = Std.random(6);
		jewels[2].animation.frameIndex = Std.random(6);

		playState.status = PlayState.STATUS_FALLING;
	}
}
