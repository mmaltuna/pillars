package utils;

class CallbackPool {

	public var totalCalls: Int;
	public var expectedCalls: Int;

	public function new(expectedCalls: Int) {
		totalCalls = 0;
		this.expectedCalls = expectedCalls;
	}

	public function onCallback(callback: Void->Void) {
		totalCalls++;

		if (totalCalls == expectedCalls)
			callback();
	}
}
