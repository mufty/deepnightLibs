package dn.struct;

/**
	A simple class to manage a value within bounds.
	Typically useful to store some game value, like player HP.
**/
@:generic
class Stat<T:Float> {
	/** Current value, clamped between `min` and `max` **/
	public var v(default,set) : T;

	public var min(default,set) : T;
	public var max(default,set) : T;

	/** Ratio of the current "maxed" ratio (0=value is zero, to 1=value is maxed) **/
	public var fullRatio(get,never) : Float;

	/** Ratio of the current "emptied" ratio (0=value is maxed, to 1=value is zero) **/
	public var emptyRatio(get,never) : Float;

	/** Same as `fullRatio` but with 2 digits max **/
	public var prettyFullRatio(get,never) : Float;

	var zero : T = cast 0;

	/** Callback when `v` changes **/
	public var onChange : Null< Void->Void >;

	public function new() {
		init(zero,zero,zero);
	}

	@:keep public function toString() {
		return min==zero ? '$v/$max' : '[$min]$v/$max';
	}

	public inline function clone() : Stat<T> {
		var s = new Stat<T>();
		s.init(v,min,max);
		s.onChange = onChange;
		return s;
	}

	public inline function isZero() return v==zero;
	public inline function isMin() return v==min;
	public inline function isMax() return v==max;
	public inline function isMinOrMax() return v==min || v==max;

	public inline function setBounds(min:T, max:T) {
		this.min = min;
		this.max = max;
		v = clamp(v);
	}

	/** Set stat value using either: `set(value,max)` or `set(value,min,max)` **/
	public inline function init(value:T, maxOrMin:T, ?max:T) {
		if( max==null ) {
			this.max = maxOrMin;
			this.v = value;
		}
		else {
			this.min = maxOrMin;
			this.max = max;
			this.v = value;
		}
	}

	/** Customize the `max`, and set `min` and `v` to 0 **/
	public inline function initZeroOnMax(max:T) {
		init(zero, zero,max);
	}

	/** Set both `v` and `max` to `value`, and set `min` to 0 **/
	public inline function initMaxOnMax(value:T) {
		init(value, zero,value);
	}

	public inline function empty() {
		v = min;
	}

	public inline function maxOut() {
		v = max;
	}

	inline function clamp(value:T) : T {
		return
			value<min ? min :
			value>max ? max :
			value;
	}

	inline function set_v(value:T) : T{
		if( onChange==null )
			v = clamp(value);
		else {
			var old = v;
			v = clamp(value);
			if( old!=v )
				onChange();
		}
		return v;
	}

	inline function set_max(value:T) : T {
		max = value;
		if( min>max )
			min = max;
		v = clamp(v);
		return max;
	}

	inline function set_min(value:T) : T {
		min = value;
		if( max<min )
			max = min;
		v = clamp(v);
		return max;
	}

	inline function get_fullRatio() {
		return max==min ? 0 : (v-min)/(max-min);
	}

	inline function get_emptyRatio() {
		return 1-fullRatio;
	}

	inline function get_prettyFullRatio() {
		return M.pretty(fullRatio,2);
	}
}


#if deepnightLibsTests
class StatTest {
	public static function test() {
		// Int stat
		var s : Stat<Int> = new Stat();
		s.initZeroOnMax(3);
		CiAssert.equals( Type.typeof(s.v), Type.ValueType.TInt );
		CiAssert.equals( s.v, 0 );
		CiAssert.equals( s.max, 3 );

		// v clamp
		CiAssert.equals( --s.v, 0 );
		CiAssert.equals( ++s.v, 1 );
		CiAssert.equals( ++s.v, 2 );
		CiAssert.equals( ++s.v, 3 );
		CiAssert.equals( ++s.v, 3 );

		// Max change
		CiAssert.equals( { s.max--; s.toString(); }, "2/2" );
		CiAssert.equals( { s.max--; s.toString(); }, "1/1" );
		CiAssert.equals( { s.max++; s.toString(); }, "1/2" );
		CiAssert.equals( { s.max++; s.toString(); }, "1/3" );

		// Min change
		CiAssert.equals( { s.min=1; s.toString(); }, "[1]1/3" );
		CiAssert.equals( { s.min=2; s.toString(); }, "[2]2/3" );
		CiAssert.equals( { s.min=3; s.toString(); }, "[3]3/3" );

		// Ratio
		s.initZeroOnMax(2);
		CiAssert.equals( s.toString(), "0/2" );
		CiAssert.equals( { s.v=0; s.ratio; }, 0 );
		CiAssert.equals( { s.v=1; s.ratio; }, 0.5 );
		CiAssert.equals( { s.v=2; s.ratio; }, 1 );
		CiAssert.equals( { s.v=5; s.ratio; }, 1 );

		// Ratio with min
		s.init(0, 1,3);
		CiAssert.equals( s.toString(), "[1]1/3" );
		CiAssert.equals( { s.v=1; s.ratio; }, 0 );
		CiAssert.equals( { s.v=2; s.ratio; }, 0.5 );
		CiAssert.equals( { s.v=3; s.ratio; }, 1 );

		// Negative min
		s.init(0, -1,3);
		CiAssert.equals( s.toString(), "[-1]0/3" );
		CiAssert.equals( { s.v--; s.toString(); }, "[-1]-1/3" );
		CiAssert.equals( { s.v--; s.toString(); }, "[-1]-1/3" );
		CiAssert.equals( { s.min=0; s.toString(); }, "0/3" );

		// Pretty ratio
		s.initZeroOnMax(3);
		CiAssert.equals( s.toString(), "0/3" );
		CiAssert.equals( { s.v=1; s.toString(); }, "1/3" );
		CiAssert.equals( s.prettyRatio, 0.33 );

		// Weird min/max changes
		s.initZeroOnMax(3);
		CiAssert.equals( s.toString(), "0/3" );
		CiAssert.equals( { s.min=5; s.toString(); }, "[5]5/5" );
		CiAssert.equals( { s.max=2; s.toString(); }, "[2]2/2" );
		CiAssert.equals( { s.max=3; s.toString(); }, "[2]2/3" );
		CiAssert.equals( { s.min=1; s.toString(); }, "[1]2/3" );
		CiAssert.equals( { s.min=0; s.toString(); }, "2/3" );
		CiAssert.equals( { s.max=-1; s.toString(); }, "[-1]-1/-1" );
		CiAssert.equals( { s.max=2; s.toString(); }, "[-1]-1/2" );
		CiAssert.equals( { s.min=0; s.toString(); }, "0/2" );
		CiAssert.equals( { s.min=s.max*2; s.toString(); }, "[4]4/4" );
		CiAssert.equals( { s.max=-s.min; s.toString(); }, "[-4]-4/-4" );

		// Cloning
		var c = s.clone();
		CiAssert.equals( c.v, s.v );
		CiAssert.equals( c.min, s.min );
		CiAssert.equals( c.max, s.max );
	}
}
#end