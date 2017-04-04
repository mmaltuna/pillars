package utils;

import utils.data.Set;
import utils.data.TilePoint;

class Combo extends Set<TilePoint> {

	public function new() {
		super(TilePoint.equals);
	}

	public function addPosition(position: TilePoint) {
		if (!contains(position)) {
			add(position);
		}
	}

	public function getScore(): Int {
		return size() * 10 * Utils.max(1, size() - 2);
	}

	public function doesContain(combo: Combo): Bool {
		if (combo == null)
			return false;

		var b: Bool = true;
		combo.forEach(function(elem) {
			b = b && contains(elem);
		});

		return b;
	}

	public static function equals(a: Combo, b: Combo): Bool {
		if (a == null || b == null || a.size() != b.size())
			return false;

		return a.doesContain(b) && b.doesContain(a);
	}
}

class Combos extends Set<Combo> {

	private var positions: Set<TilePoint>;

	public function new() {
		super(Combo.equals);
		positions = new Set<TilePoint>(TilePoint.equals);
	}

	public function addCombo(combo: Combo) {
		if (!doesContain(combo)) {
			add(combo);
			combo.forEach(function(position) {
				positions.add(position);
			});
		}
	}

	public function getScore(): Int {
		var totalScore: Int = 0;

		forEach(function(combo) {
			totalScore += combo.getScore();
		});

		return totalScore * size();
	}

	public function getPositions(): Set<TilePoint> {
		return positions;
	}

	public function doesContain(combo: Combo): Bool {
		if (contains(combo))
			return true;

		var isContained: Bool = false;
		forEach(function(elem) {
			isContained = isContained || elem.doesContain(combo);
		});

		return isContained;
	}
}
