package;

import utils.data.Set;
import utils.data.TilePoint;

class Level {
	public var boardW: Int;
	public var boardH: Int;

	private var board: Array<Array<Int>>;	// Rows, columns

	public function new() {
		boardW = 6;
		boardH = 12;

		board = new Array<Array<Int>>();
		for (i in 0 ... boardW) {
			var column = new Array<Int>();
			for (j in 0 ... boardH) {
				column.push(-1);
			}
			board.push(column);
		}
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

		for (i in 0 ... boardW) {
			for (j in 0 ... boardH) {
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
		return x >= 0 && x < boardW && y >= 0 && y < boardH;
	}

	public function deleteCombos(): Set<TilePoint> {
		var jewelsToDelete: Set<TilePoint> = findCombos();
		if (!jewelsToDelete.isEmpty()) {
			jewelsToDelete.forEach(function(pos) {
				setCellValue(pos.x, pos.y, -1);
			});
		}

		return jewelsToDelete;
	}

	public function updateBoard() {
		for (i in 0 ... boardW)
			pushToBottom(i);
	}

	public function pushToBottom(column: Int) {
		var jewels = new Array<Int>();
		for (j in 0 ... boardH) {
			if (getCellValue(column, j) > -1)
				jewels.push(getCellValue(column, j));
		}

		for (j in 0 ... boardH) {
			if (jewels.length > 0)
				setCellValue(column, boardH - j - 1, jewels.pop());
			else
				setCellValue(column, boardH - j - 1, -1);
		}
	}
}
