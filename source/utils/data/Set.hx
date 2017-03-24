package utils.data;

class Set<T> {
	private var array: Array<T>;
	private var compare: T -> T -> Bool;

	public function new(compare: T -> T -> Bool) {
		array = new Array<T>();
		this.compare = compare;
	}

	public function add(elem: T) {
		if (!contains(elem))
			array.push(elem);
	}

	public function addAll(elems: Set<T>) {
		elems.forEach(function (elem: T) {
			add(elem);
		});
	}

	public function contains(elem: T): Bool {
		var found = false;
		var i = 0;

		while (!found && i < array.length) {
			found = compare(elem, array[i]);
			i++;
		}

		return found;
	}

	public function getAll(): Array<T> {
		return array;
	}

	public function forEach(callback: T -> Void) {
		for (elem in array)
			callback(elem);
	}

	public function clear() {
		array.splice(0, array.length);
	}

	public function size(): Int {
		return array.length;
	}

	public function isEmpty(): Bool {
		return size() == 0;
	}
}
