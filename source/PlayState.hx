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
	public static var middleStep: Bool = false;

	public static inline var STATUS_FALLING: Int = 0;
	public static inline var STATUS_SETTLING: Int = 1;
	public static inline var STATUS_PAUSED: Int = 2;
	public static inline var STATUS_GAMEOVER: Int = 3;

	private static var instance: PlayState = null;

	private var cursor: Cursor;
	private var background: FlxSprite;
	public var board: Array<Array<FlxSprite>>;

	public var level: Level;

	private var speed: Float = 2;		// speed = 1 => 1 step per second

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
		} else if (FlxG.keys.justPressed.DOWN) {
			cursor.step();
		}

		if (FlxG.keys.justPressed.SPACE) {
			cursor.shift();
		}

		if (lastUpdated < (1.0 / speed)) {
			lastUpdated += elapsed;
		} else {
			lastUpdated = 0;
			cursor.step();
		}

		if (cursor.isPlaced())
			status = STATUS_SETTLING;
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
		} else if (FlxG.keys.justPressed.DOWN) {
			lastUpdated = 1.0 / speed;
		}

		if (FlxG.keys.justPressed.SPACE) {
			cursor.shift();
		}

		if (lastUpdated < (1.0 / speed)) {
			lastUpdated += elapsed;
		} else {
			lastUpdated = 0;
			settleCursor();

			var totalDeleted = 1;
			while (totalDeleted > 0) {
				totalDeleted = deleteCombos();
				updateBoard();
			}

			if (!level.isInbounds(cursor.x, cursor.y))
				status = STATUS_GAMEOVER;
			else
				cursor.reload();
		}

		if (!cursor.isPlaced())
			status = STATUS_FALLING;
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

	public function deleteCombos(): Int {
		var jewelsToDelete = level.deleteCombos();
		jewelsToDelete.forEach(function(pos) {
			board[pos.x][pos.y].destroy();
			board[pos.x][pos.y] = null;
		});

		return jewelsToDelete.size();
	}

	public function updateBoard() {
		level.updateBoard();

		for (column in 0 ... level.boardW) {
			pushToBottom(column);
		}
	}

	private function pushToBottom(column: Int) {
		var sprites = new Array<FlxSprite>();
		for (j in 0 ... level.boardH) {
			if (board[column][j] != null)
				sprites.push(board[column][j]);
		}

		for (j in 0 ... level.boardH) {
			if (sprites.length > 0) {
				board[column][level.boardH - j - 1] = sprites.pop();
				board[column][level.boardH - j - 1].y = getPosY(level.boardH - j - 1);
			}
			else
				board[column][level.boardH - j - 1] = null;
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
		return borderSize + y * (tileSize + borderSize * 2) + (middleStep ? getStepSize() : 0);
	}

	public static function getStepSize(): Float {
		return tileSize / 2 + borderSize;
	}
}
