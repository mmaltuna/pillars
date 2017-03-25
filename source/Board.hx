package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;

import utils.data.Set;
import utils.data.TilePoint;
import ui.Cursor;
import ui.Column;

class Board {

	public static var tileSize: Int = 8;
	public static var borderSize: Int = 1;
	public static var columnSize: Int = 10;
	public static var setSize: Int = 6;

	public static inline var STATUS_FALLING: Int = 0;
	public static inline var STATUS_SETTLING: Int = 1;
	public static inline var STATUS_PAUSED: Int = 2;
	public static inline var STATUS_GAMEOVER: Int = 3;

	public var width: Int;
	public var height: Int;
	public var middleStep: Bool;

	private var x: Int;
	private var y: Int;
	private var lastUpdated: Float = 0;
	private var speed: Float = 2;		// speed = 1 => 1 step per second

	private var board: Array<Array<Int>>;	// Rows, columns
	private var boardGfx: Array<Array<FlxSprite>>;
	public var gfxSet: FlxTypedGroup<FlxSprite>;

	private var cursor: Cursor;
	private var background: FlxSprite;
	public var indicator: Column;

	public var status: Int;
	public var previousStatus: Int;

	public function new(x: Int, y: Int) {
		width = 6;
		height = 12;

		this.x = x;
		this.y = y;

		status = STATUS_FALLING;
		previousStatus = STATUS_PAUSED;

		gfxSet = new FlxTypedGroup<FlxSprite>();

		background = new FlxSprite(x, y);
		background.loadGraphic("assets/images/background-6x12.png", 60, 120);
		gfxSet.add(background);

		board = new Array<Array<Int>>();
		for (i in 0 ... width) {
			var column = new Array<Int>();
			for (j in 0 ... height) {
				column.push(-1);
			}
			board.push(column);
		}

		boardGfx = new Array<Array<FlxSprite>>();
		for (i in 0 ... width)
			boardGfx[i] = new Array<FlxSprite>();

		cursor = new Cursor(this);
		for (member in cursor.members)
			gfxSet.add(member);

		indicator = new Column(x + width * columnSize + columnSize + borderSize,
			y + borderSize, cursor.getValues());
		for (member in indicator)
			gfxSet.add(member);
	}

	public function update(elapsed: Float) {
		switch status {
			case STATUS_PAUSED:
				onStatusPaused();

			case STATUS_FALLING:
				onStatusFalling(elapsed);

			case STATUS_SETTLING:
				onStatusSettling(elapsed);
		}
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
			if (cursor.y < 0) {
				// It's still partially hidden
				indicator.shift();
			}
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

			if (!isInbounds(cursor.x, cursor.y))
				status = STATUS_GAMEOVER;
			else {
				cursor.setValues(indicator.getValues());
				cursor.reload();
			}
		}

		if (!cursor.isPlaced())
			status = STATUS_FALLING;
	}

	public function settleCursor() {
		var jewelA = cursor.getJewels()[0].clone();
		jewelA.x = getPosX(cursor.x);
		jewelA.y = getPosY(cursor.y);
		boardGfx[cursor.x][cursor.y] = jewelA;
		gfxSet.add(jewelA);

		var jewelB = cursor.getJewels()[1].clone();
		jewelB.x = getPosX(cursor.x);
		jewelB.y = getPosY(cursor.y + 1);
		boardGfx[cursor.x][cursor.y + 1] = jewelB;
		gfxSet.add(jewelB);

		var jewelC = cursor.getJewels()[2].clone();
		jewelC.x = getPosX(cursor.x);
		jewelC.y = getPosY(cursor.y + 2);
		boardGfx[cursor.x][cursor.y + 2] = jewelC;
		gfxSet.add(jewelC);

		setCellValue(cursor.x, cursor.y, jewelA.animation.frameIndex);
		setCellValue(cursor.x, cursor.y + 1, jewelB.animation.frameIndex);
		setCellValue(cursor.x, cursor.y + 2, jewelC.animation.frameIndex);
	}

	public function getCellValue(x: Int, y: Int): Int {
		var returnValue = -1;
		if (isInbounds(x, y)) {
			returnValue = board[x][y];
		}

		return returnValue;
	}

	public function setCellValue(x: Int, y: Int, value: Int) {
		if (isInbounds(x, y)) {
			board[x][y] = value;
		}
	}

	private function findCombos(): Set<TilePoint> {
		var positions: Set<TilePoint> = new Set<TilePoint>(TilePoint.equals);

		for (i in 0 ... width) {
			for (j in 0 ... height) {
				positions.addAll(findCombosPosition(i, j));
			}
		}

		return positions;
	}

	private function findCombosPosition(x: Int, y: Int): Set<TilePoint> {
		var v = getCellValue(x, y);
		var positions: Set<TilePoint> = new Set<TilePoint>(TilePoint.equals);

		if (v > -1) {
			var combos: Array<Array<TilePoint>> = new Array<Array<TilePoint>>();
			for (i in [-1, 0, 1]) {
				for (j in [-1, 0, 1]) {
					var k: Int = 1;
					var combo: Array<TilePoint> = null;

					while ((i != 0 || j != 0) && isInbounds(x + i * k, y + j * k) && getCellValue(x + i * k, y + j * k) == v) {
						if (combo == null) {
							combo = new Array<TilePoint>();
							combo.push(new TilePoint(x, y));
						}

						combo.push(new TilePoint(x + i * k, y + j * k));

						k++;
					}

					if (combo != null && combo.length >= 3)
						combos.push(combo);
				}
			}

			for (combo in combos)
				for (pos in combo)
					positions.add(pos);
		}

		return positions;
	}

	public function isInbounds(x: Int, y: Int): Bool {
		return x >= 0 && x < width && y >= 0 && y < height;
	}

	public function deleteCombos(): Int {
		var jewelsToDelete: Set<TilePoint> = findCombos();
		if (!jewelsToDelete.isEmpty()) {
			jewelsToDelete.forEach(function(pos) {
				setCellValue(pos.x, pos.y, -1);
				boardGfx[pos.x][pos.y].destroy();
				boardGfx[pos.x][pos.y] = null;
			});
		}

		return jewelsToDelete.size();
	}

	public function updateBoard() {
		for (i in 0 ... width)
			pushToBottom(i);
	}

	public function pushToBottom(column: Int) {
		var jewels = new Array<Int>();
		var sprites = new Array<FlxSprite>();

		for (j in 0 ... height) {
			if (getCellValue(column, j) > -1) {
				jewels.push(getCellValue(column, j));
				sprites.push(boardGfx[column][j]);
			}
		}

		for (j in 0 ... height) {
			if (jewels.length > 0) {
				setCellValue(column, height - j - 1, jewels.pop());
				boardGfx[column][height - j - 1] = sprites.pop();
				boardGfx[column][height - j - 1].y = getPosY(height - j - 1);
			} else {
				setCellValue(column, height - j - 1, -1);
				boardGfx[column][height - j - 1] = null;
			}
		}
	}

	public function coordsToPoint(x: Int, y: Int): FlxPoint {
		var point: FlxPoint = new FlxPoint();
		point.x = getPosX(x);
		point.y = getPosY(y);

		return point;
	}

	public function getPosX(x: Int): Float {
		return this.x + borderSize + x * (tileSize + borderSize * 2);
	}

	public function getPosY(y: Int): Float {
		return this.y + borderSize + y * (tileSize + borderSize * 2) + (middleStep ? getStepSize() : 0);
	}

	public static function getStepSize(): Float {
		return tileSize / 2 + borderSize;
	}
}
