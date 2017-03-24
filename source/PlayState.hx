package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

import ui.Cursor;
import utils.data.TilePoint;

class PlayState extends FlxState {

	public static var tileSize: Int = 8;
	public static var borderSize: Int = 1;

	public static inline var STATUS_FALLING: Int = 0;
	public static inline var STATUS_SETTLING: Int = 1;
	public static inline var STATUS_PAUSED: Int = 2;

	private static var instance: PlayState = null;

	private var cursor: Cursor;
	private var background: FlxSprite;
	public var board: Array<Array<FlxSprite>>;

	public var level: Level;

	private var speed: Int = 1;		// speed = 1 => 1 step per second

	private var lastUpdated: Float = 0;

	public var status: Int;
	public var previousStatus: Int;

	override public function create() {
		super.create();

		instance = this;
		level = new Level();

		status = STATUS_FALLING;
		previousStatus = STATUS_PAUSED;

		background = new FlxSprite(0, 0);
		background.loadGraphic("assets/images/background-6x12.png", 60, 120);
		add(background);

		board = new Array<Array<FlxSprite>>();
		for (i in 0 ... level.boardW)
			board[i] = new Array<FlxSprite>();

		cursor = new Cursor();
		cursor.move(2, 0);
		add(cursor);
	}

	override public function update(elapsed: Float) {
		switch status {
			case STATUS_PAUSED:
				onStatusPaused();

			case STATUS_FALLING:
				onStatusFalling(elapsed);

			case STATUS_SETTLING:
				onStatusSettling(elapsed);
		}

		super.update(elapsed);
	}

	public function onStatusPaused() {
		if (FlxG.keys.justPressed.ENTER) {
			status = previousStatus;
		}
	}

	public function onStatusFalling(elapsed: Float) {
		if (FlxG.keys.justPressed.ENTER) {
			previousStatus = status;
			status = STATUS_PAUSED;
		}

		if (FlxG.keys.justPressed.LEFT) {
			cursor.move(cursor.x - 1, cursor.y);
		} else if (FlxG.keys.justPressed.RIGHT) {
			cursor.move(cursor.x + 1, cursor.y);
		}

		if (FlxG.keys.justPressed.SPACE) {
			cursor.permute();
		}

		if (lastUpdated < (1.0 / speed)) {
			lastUpdated += elapsed;
		} else {
			lastUpdated = 0;
			cursor.move(cursor.x, cursor.y + 1);
		}
	}

	public function onStatusSettling(elapsed: Float) {
		if (FlxG.keys.justPressed.ENTER) {
			previousStatus = status;
			status = STATUS_PAUSED;
		}

		if (FlxG.keys.justPressed.LEFT) {
			cursor.move(cursor.x - 1, cursor.y);
		} else if (FlxG.keys.justPressed.RIGHT) {
			cursor.move(cursor.x + 1, cursor.y);
		}

		if (FlxG.keys.justPressed.SPACE) {
			cursor.permute();
		}

		if (lastUpdated < (1.0 / speed)) {
			lastUpdated += elapsed;
		} else {
			lastUpdated = 0;
			settleCursor();

			deleteCombos();
			updateBoard();

			cursor.reload();
		}
	}

	public function settleCursor() {
		var jewelA = cursor.jewels[0].clone();
		jewelA.x = getPosX(cursor.x);
		jewelA.y = getPosY(cursor.y);
		board[cursor.x][cursor.y] = jewelA;
		add(jewelA);

		var jewelB = cursor.jewels[1].clone();
		jewelB.x = getPosX(cursor.x);
		jewelB.y = getPosY(cursor.y + 1);
		board[cursor.x][cursor.y + 1] = jewelB;
		add(jewelB);

		var jewelC = cursor.jewels[2].clone();
		jewelC.x = getPosX(cursor.x);
		jewelC.y = getPosY(cursor.y + 2);
		board[cursor.x][cursor.y + 2] = jewelC;
		add(jewelC);

		level.setCellValue(cursor.x, cursor.y, jewelA.animation.frameIndex);
		level.setCellValue(cursor.x, cursor.y + 1, jewelB.animation.frameIndex);
		level.setCellValue(cursor.x, cursor.y + 2, jewelC.animation.frameIndex);
	}

	public function deleteCombos() {
		var jewelsToDelete = level.deleteCombos();
		jewelsToDelete.forEach(function(pos) {
			board[pos.x][pos.y].destroy();
			board[pos.x][pos.y] = null;
		});
	}

	public function updateBoard() {
		level.updateBoard();

		for (column in 0 ... level.boardW) {
			pushToBottom(column);
		}
	}

	private function pushToBottom(column: Int) {
		var j = 0;
		while (j < level.boardH) {
			var row = level.boardH - j - 1;
			if (board[column][row] == null) {
				if (level.isInbounds(column, row - 1) && board[column][row - 1] != null) {
					board[column][row] = board[column][row - 1];
					board[column][row].x = getPosX(column);
					board[column][row].y = getPosY(row);
					board[column][row - 1] = null;
					j--;
				}
			}

			j++;
		}
	}

	public static function getInstance(): PlayState {
		return instance;
	}

	public static function coordsToPoint(x: Int, y: Int): FlxPoint {
		var point: FlxPoint = new FlxPoint();
		point.x = getPosX(x);
		point.y = getPosY(y);

		return point;
	}

	public static function getPosX(x: Int): Float {
		return borderSize + x * (tileSize + borderSize * 2);
	}

	public static function getPosY(y: Int): Float {
		return borderSize + y * (tileSize + borderSize * 2);
	}
}
