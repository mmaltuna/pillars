package ui;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

class Column extends FlxTypedGroup<FlxSprite> {
	public var jewels: Array<Jewel>;

	public var x: Float;
	public var y: Float;

	public function new(x: Float, y: Float, values: Array<Int>) {
		super();

		jewels = new Array<Jewel>();

		this.x = x;
		this.y = y;
		visible = true;

		var jewelA = new Jewel(x, y);
		add(jewelA);

		var jewelB = new Jewel(x, y + 2 * Board.getStepSize());
		add(jewelB);

		var jewelC = new Jewel(x, y + 4 * Board.getStepSize());
		add(jewelC);

		jewels.push(jewelA);
		jewels.push(jewelB);
		jewels.push(jewelC);

		setValues(values);
	}

	public function moveTo(x: Float, y: Float) {
		jewels[0].x = x;
		jewels[0].y = y;

		jewels[1].x = x;
		jewels[1].y = y + 2 * Board.getStepSize();

		jewels[2].x = x;
		jewels[2].y = y + 4 * Board.getStepSize();

		this.x = x;
		this.y = y;
	}

	public function shift() {
		var bottom = jewels[2].y;
		var bottomJewel = jewels[2];

		jewels[2].y = jewels[0].y;
		jewels[0].y = jewels[1].y;
		jewels[1].y = bottom;

		jewels[2] = jewels[1];
		jewels[1] = jewels[0];
		jewels[0] = bottomJewel;
	}

	public function moveJewel(index: Int, x: Float, y: Float) {
		jewels[index].x = x;
		jewels[index].y = y;
	}

	public function setValues(values: Array<Int>) {
		jewels[0].setValue(values[0]);
		jewels[1].setValue(values[1]);
		jewels[2].setValue(values[2]);
	}

	public function getValues(): Array<Int> {
		return [
			jewels[0].getValue(),
			jewels[1].getValue(),
			jewels[2].getValue()
		];
	}
}
