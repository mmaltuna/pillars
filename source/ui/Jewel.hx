package ui;

import flixel.FlxSprite;

class Jewel extends FlxSprite {

	private var value: Int;

	public function new(x: Float, y: Float) {
		super(x, y);

		loadGraphic("assets/images/jewel-set-1.png", true, 8, 8);

		animation.add("0-flicker", [0, 17, 0, 17, 0, 17, 0, 17, 0, 17, 0, 17], 12, false);
		animation.add("1-flicker", [1, 17, 1, 17, 1, 17, 1, 17, 1, 17, 1, 17], 12, false);
		animation.add("2-flicker", [2, 17, 2, 17, 2, 17, 2, 17, 2, 17, 2, 17], 12, false);
		animation.add("3-flicker", [3, 17, 3, 17, 3, 17, 3, 17, 3, 17, 3, 17], 12, false);
		animation.add("4-flicker", [4, 17, 4, 17, 4, 17, 4, 17, 4, 17, 4, 17], 12, false);
		animation.add("5-flicker", [5, 17, 5, 17, 5, 17, 5, 17, 5, 17, 5, 17], 12, false);
		animation.add("vanish", [7, 8, 9, 10, 11, 12, 13, 14, 15, 16], 30, false);
	}

	public function setValue(v: Int) {
		value = v;

		if (value == -1)
			animation.frameIndex = 17;
		else if (value >= 0 && value < 6)
			animation.frameIndex = value;
	}

	public function getValue() {
		return value;
	}

	override public function clone(): Jewel {
		var newJewel: Jewel = new Jewel(x, y);
		newJewel.setValue(value);
		return newJewel;
	}
}
