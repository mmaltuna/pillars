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
	public static var boardW: Int = 6;
	public static var boardH: Int = 12;

	public static inline var STATUS_FALLING: Int = 0;
	public static inline var STATUS_SETTLING: Int = 1;
	public static inline var STATUS_PAUSED: Int = 2;

	private static var instance: PlayState = null;

	private var board: Array<Array<Int>>;	// Rows, columns
	private var cursor: Cursor;

	private var background: FlxSprite;

	private var level: Int = 1;
	private var speed: Int = 1;		// speed = 1 => 1 step per second

	private var lastUpdated: Float = 0;

	public var status: Int = STATUS_PAUSED;
	public var previousStatus: Int = STATUS_FALLING;

	override public function create() {
		super.create();

		instance = this;

		board = new Array<Array<Int>>();
		for (i in 0 ... boardW) {
			var column = new Array<Int>();
			for (j in 0 ... boardH) {
				column.push(-1);
			}
			board.push(column);
		}

		background = new FlxSprite(0, 0);
		background.loadGraphic("assets/images/background-6x12.png", 60, 120);
		add(background);

		cursor = new Cursor();
		cursor.move(2, 0);
		add(cursor);
	}

	override public function update(elapsed: Float) {
		switch status {
			case STATUS_PAUSED:
				if (FlxG.keys.justPressed.ENTER) {
					status = previousStatus;
				}

			default:
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
					cursor.rotate();
				}

				if (lastUpdated < (1.0 / speed)) {
					lastUpdated += elapsed;
				} else {
					lastUpdated = 0;
					if (status == STATUS_FALLING) {
						cursor.move(cursor.x, cursor.y + 1);
					} else if (status == STATUS_SETTLING) {
						settleCursor();
						cursor.reload();
					}
				}
		}

		super.update(elapsed);
	}

	public function settleCursor() {
		var jewelA = cursor.jewels[0].clone();
		jewelA.x = getPosX(cursor.x);
		jewelA.y = getPosY(cursor.y);
		add(jewelA);

		var jewelB = cursor.jewels[1].clone();
		jewelB.x = getPosX(cursor.x);
		jewelB.y = getPosY(cursor.y + 1);
		add(jewelB);

		var jewelC = cursor.jewels[2].clone();
		jewelC.x = getPosX(cursor.x);
		jewelC.y = getPosY(cursor.y + 2);
		add(jewelC);

		board[cursor.x][cursor.y] = jewelA.animation.frameIndex;
		board[cursor.x][cursor.y + 1] = jewelB.animation.frameIndex;
		board[cursor.x][cursor.y + 2] = jewelC.animation.frameIndex;
	}

	public function getCellValue(x: Int, y: Int): Int {
		var returnValue = -1;
		if (x >= 0 && x < boardW && y >= 0 && y < boardH) {
			returnValue = board[x][y];
		}

		return returnValue;
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
