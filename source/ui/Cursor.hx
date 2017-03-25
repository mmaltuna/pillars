package ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

class Cursor extends FlxTypedGroup<FlxSprite> {
	private var outline: FlxSprite;
	private var board: Board;
	private var column: Column;

	public var x: Int;
	public var y: Int;

	private static var initX: Int = 3;
	private static var initY: Int = -2;

	public function new(board: Board) {
		super();

		this.board = board;

		x = initX;
		y = initY;

		column = new Column(board.getPosX(x), board.getPosY(y),
			[Std.random(Board.setSize), Std.random(Board.setSize), Std.random(Board.setSize)]);

		for (member in column)
			add(member);

		reload();
	}

	public function move(x: Int, y: Int) {
		if (canMoveTo(x, y)) {
			column.moveTo(board.getPosX(x), board.getPosY(y));

			this.x = x;
			this.y = y;
		}
	}

	public function step() {
		if (!isPlaced()) {
			column.moveTo(column.x, column.y + Board.getStepSize());
			board.middleStep = !board.middleStep;
			if (!board.middleStep)
				y++;

			if (y == 0 && !board.middleStep) {
				// It's completely visible for the first time
				board.indicator.setValues(
					[Std.random(Board.setSize), Std.random(Board.setSize), Std.random(Board.setSize)]);
			}
		}
	}

	public function shift() {
		column.shift();
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
		board.status = Board.STATUS_FALLING;
		board.middleStep = false;
	}

	public function getJewels(): Array<FlxSprite> {
		return column.jewels;
	}

	public function getValues(): Array<Int> {
		return column.getValues();
	}

	public function setValues(values: Array<Int>) {
		column.setValues(values);
	}
}
