package ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

class Cursor extends FlxTypedGroup<FlxSprite> {

	public var jewels: Array<FlxSprite>;
	private var outline: FlxSprite;
	private var board: Board;

	public var x: Int;
	public var y: Int;

	private static var setSize: Int = 6;
	private static var initX: Int = 3;
	private static var initY: Int = -2;

	public function new(board: Board) {
		super();

		this.board = board;

		x = initX;
		y = initY;

		jewels = new Array<FlxSprite>();

		var jewelA = new FlxSprite(board.getPosX(x), board.getPosY(y));
		jewelA.loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);
		jewelA.animation.frameIndex = Std.random(setSize);
		add(jewelA);

		var jewelB = new FlxSprite(board.getPosX(x), board.getPosY(y + 1));
		jewelB.loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);
		jewelB.animation.frameIndex = Std.random(setSize);
		add(jewelB);

		var jewelC = new FlxSprite(board.getPosX(x), board.getPosY(y + 2));
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
			jewels[0].x = board.getPosX(x);
			jewels[0].y = board.getPosY(y);

			jewels[1].x = board.getPosX(x);
			jewels[1].y = board.getPosY(y + 1);

			jewels[2].x = board.getPosX(x);
			jewels[2].y = board.getPosY(y + 2);

			this.x = x;
			this.y = y;
		}
	}

	public function step() {
		if (!isPlaced()) {
			jewels[0].y += board.getStepSize();
			jewels[1].y += board.getStepSize();
			jewels[2].y += board.getStepSize();

			board.middleStep = !board.middleStep;

			if (!board.middleStep)
				y++;
		}
	}

	public function shift() {
		var jewel = jewels[2];

		jewels[2].y = board.getPosY(y);
		jewels[0].y = board.getPosY(y + 1);
		jewels[1].y = board.getPosY(y + 2);

		jewels[2] = jewels[1];
		jewels[1] = jewels[0];
		jewels[0] = jewel;
	}

	public function isPlaced(): Bool {
		if (y + 3 >= board.height)
			return true;

		return board.getCellValue(x, y + 3) >= 0;
	}

	public function canMoveTo(x: Int, y: Int): Bool {
		var b: Bool = x >= 0 && x < board.width;
		var yy: Int = board.middleStep ? y + 1 : y;

		b = b && (yy + 2 < board.height);
		b = b && board.getCellValue(x, yy) == -1;
		b = b && board.getCellValue(x, yy + 1) == -1;
		b = b && board.getCellValue(x, yy + 2) == -1;

		return b;
	}

	public function reload() {
		move(initX, initY);

		jewels[0].animation.frameIndex = Std.random(setSize);
		jewels[1].animation.frameIndex = Std.random(setSize);
		jewels[2].animation.frameIndex = Std.random(setSize);

		board.status = Board.STATUS_FALLING;

		board.middleStep = false;
	}
}
