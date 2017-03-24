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

	private static var setSize: Int = 6;
	private static var initX: Int = 2;
	private static var initY: Int = -3;

	public function new() {
		super();

		x = initX;
		y = initY;

		playState = PlayState.getInstance();
		jewels = new Array<FlxSprite>();

		var jewelA = new FlxSprite(PlayState.getPosX(x), PlayState.getPosY(y));
		jewelA.loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);
		jewelA.animation.frameIndex = Std.random(setSize);
		add(jewelA);

		var jewelB = new FlxSprite(PlayState.getPosX(x), PlayState.getPosY(y + 1));
		jewelB.loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);
		jewelB.animation.frameIndex = Std.random(setSize);
		add(jewelB);

		var jewelC = new FlxSprite(PlayState.getPosX(x), PlayState.getPosY(y + 2));
		jewelC.loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);
		jewelC.animation.frameIndex = Std.random(setSize);
		add(jewelC);

		jewels.push(jewelA);
		jewels.push(jewelB);
		jewels.push(jewelC);

		reload();
	}

	public function move(x: Int, y: Int) {
		if (canMoveTo(x, y)) {
			jewels[0].x = PlayState.getPosX(x);
			jewels[0].y = PlayState.getPosY(y);

			jewels[1].x = PlayState.getPosX(x);
			jewels[1].y = PlayState.getPosY(y + 1);

			jewels[2].x = PlayState.getPosX(x);
			jewels[2].y = PlayState.getPosY(y + 2);

			this.x = x;
			this.y = y;
		}
	}

	public function step() {
		if (!isPlaced()) {
			jewels[0].y += PlayState.getStepSize();
			jewels[1].y += PlayState.getStepSize();
			jewels[2].y += PlayState.getStepSize();

			PlayState.middleStep = !PlayState.middleStep;

			if (!PlayState.middleStep)
				y++;
		}
	}

	public function shift() {
		var jewel = jewels[2];

		jewels[2].y = PlayState.getPosY(y);
		jewels[0].y = PlayState.getPosY(y + 1);
		jewels[1].y = PlayState.getPosY(y + 2);

		jewels[2] = jewels[1];
		jewels[1] = jewels[0];
		jewels[0] = jewel;
	}

	public function isPlaced(): Bool {
		if (y + 3 >= playState.level.boardH)
			return true;

		return playState.level.getCellValue(x, y + 3) >= 0;
	}

	public function canMoveTo(x: Int, y: Int): Bool {
		var b: Bool = x >= 0 && x < playState.level.boardW && y < playState.level.boardH;

		b = b && (y + 2 < playState.level.boardH);
		b = b && playState.level.getCellValue(x, y) == -1;
		b = b && playState.level.getCellValue(x, y + 1) == -1;
		b = b && playState.level.getCellValue(x, y + 2) == -1;

		return b;
	}

	public function reload() {
		move(initX, initY);

		jewels[0].animation.frameIndex = Std.random(setSize);
		jewels[1].animation.frameIndex = Std.random(setSize);
		jewels[2].animation.frameIndex = Std.random(setSize);

		playState.status = PlayState.STATUS_FALLING;

		PlayState.middleStep = false;
	}
}
