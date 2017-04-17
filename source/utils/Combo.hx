package utils;

import utils.data.Set;
import utils.data.TilePoint;

class Combo extends Set<TilePoint> {

	public var value: Int;

	public function new(value: Int) {
		super(TilePoint.equals);
		this.value = value;
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

	public static function canMerge(a: Combo, b: Combo): Bool {
		if (a.value != b.value)
			return false;

		var matches: Bool = false;
		a.forEach(function(pos) {
			matches = matches || b.contains(pos);
		});

		if (matches) return matches;

		a.forEach(function(posA) {
			b.forEach(function(posB) {
				var distance: Int = Utils.abs(posA.x - posB.x) + Utils.abs(posA.y - posB.y);
				matches = matches || (distance == 1);
			});
		});

		return matches;
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

			// Check if the new combo can be merged with an existing one
			var merged: Bool = false;
			forEach(function(eCombo) {
				if (!merged && Combo.canMerge(combo, eCombo)) {
					merged = true;

					combo.forEach(function(pos) {
						eCombo.addPosition(pos);
					});
				}
			});

			// Add all positions to be deleted
			combo.forEach(function(position) {
				positions.add(position);
			});

			if (!merged)
				add(combo);
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
