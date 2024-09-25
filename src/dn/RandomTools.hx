package dn;

/**
	This class should be imported with an alias for easier use.
	```haxe
	import RandomTools as R;
	```
**/

class RandomTools {

	/** Random Float value within specified range. If `sign` is true, the value will be either between [min,max] or [-max,-min].**/
	public static inline function rnd(min:Float, max:Float, sign=false) {
		if( sign )
			return (min + Math.random()*(max-min)) * (Std.random(2)*2-1);
		else
			return min + Math.random()*(max-min);
	}

	@:noCompletion @:deprecated("Use RandomTools.rnd()")
	public static inline function rng(min:Float, max:Float, sign=false) {
		return rnd(min,max,sign);
	}


	/** Random Integer value within specified range. If `sign` is true, the value will be either between [min,max] or [-max,-min]. **/
	public static inline function irnd(min:Int, max:Int, sign=false) {
		if( sign )
			return (min + Std.random(max-min+1)) * (Std.random(2)*2-1);
		else
			return min + Std.random(max-min+1);
	}

	/** Randomly variate given value `v` in +/- `pct`%. If `sign` is true, the value will some times be multiplied by -1. **/
	public static inline function around(v:Float, pct=10, sign=false) {
		return v * ( 1 + rnd(0,pct/100,true) ) * ( sign ? RandomTools.sign() : 1 );
	}

	/** Randomly variate given value `v` in +/- `pct`%. If `sign` is true, the value will some times be multiplied by -1. **/
	public static inline function iaround(v:Int, pct=10, sign=false) : Int {
		return M.round( v * ( 1 + rnd(0,pct/100,true) ) * ( sign ? RandomTools.sign() : 1 ) );
	}

	/** Returns -1 or 1 randomly **/
	public static inline function sign() {
		return Std.random(2)*2-1;
	}

	/** Randomly variate given value `v` in +/- `pct`%, and ensures result is in range [0,1] **/
	public static inline function aroundZTO(v:Float, pct=10) {
		return M.fclamp( v * ( 1 + rnd(0,pct/100,true) ), 0, 1 );
	}

	/** Randomly variate given value `v` in +/- `pct`%, and ensures result is capped to 1 **/
	public static inline function aroundBO(v:Float, pct=10) {
		return M.fmin( v * ( 1 + rnd(0,pct/100,true) ), 1 );
	}

	/** Random float value in range [0,v]. If `sign` is true, the value will be in [-v,v]. **/
	public static inline function zeroTo(v:Float, sign=false) {
		return rnd(0,v,sign);
	}

	/** Random float in range [0,1]. If `sign` is true, the value will be in [-1,1]. **/
	public static inline function zto(sign=false) {
		return rnd(0,1, sign);
	}

	/** Random color by interpolating R, G & B components **/
	public static inline function colorMix(minColor:UInt, maxColor:UInt) : UInt {
		return dn.legacy.Color.interpolateInt( minColor, maxColor, rnd(0,1) );
	}

	/** Create a color with optional HSL parameters. If `hue` is omitted, it will be random. **/
	public static inline function color(?hue:Float, sat=1.0, lum=1.0) {
		return dn.legacy.Color.makeColorHsl( hue==null ? zto() : hue, sat, lum );
	}

	/** Random radian angle in range [0,2PI] **/
	public static inline function fullCircle() return rnd(0, M.PI2);

	/** Random radian angle in range [0,PI] **/
	public static inline function halfCircle() return rnd(0, M.PI);

	/** Random radian angle in range [0,PI/2] **/
	public static inline function quarterCircle() return rnd(0, M.PIHALF);

	/** Random radian angle in range [ang-maxDist, ang+maxDist] **/
	public static inline function angleAround(ang:Float, maxDist:Float) {
		return ang + rnd(0, maxDist, true);
	}

	public static inline function flipCoin() return Std.random(2)==0;

	/** Return TRUE if a random percentage (ie. 0-100) is below given threshold **/
	public static inline function pct(thresholdOrBelow:Int) {
		return Std.random(100) < thresholdOrBelow;
	}

	/** Return TRUE if a random percentage (ie. 0-1) is below given threshold **/
	public static inline function pctf(thresholdOrBelow:Float) {
		return Std.random(100) < thresholdOrBelow*100;
	}


	public static inline function either<T>(a:T, b:T, aChance=0.5) : T {
		return rnd(0,1)<aChance ? a : b;
	}

	public static inline function oneOf2<T>(main:T, mainWeight:Float, alt:T, altWeight:Float) : T {
		return rnd(0,mainWeight+altWeight)<=mainWeight ? main : alt;
	}

	public static inline function oneOf3<T>(main:T, mainWeight:Float, alt1:T, alt1Weight:Float, alt2:T, alt2Weight) : T {
		var r = rnd(0, mainWeight + alt1Weight + alt2Weight);
		return r<=mainWeight ? main
			: r<=mainWeight+alt1Weight ? alt1
			: alt2;
	}


	/** Pick a value randomly in an array **/
	public static inline function pick<T>(a:Array<T>, removeAfterPick=false) : Null<T> {
		return a==null || a.length==0
			? null
			: removeAfterPick
				? a.splice( Std.random(a.length), 1 )[0]
				: a[ Std.random(a.length) ];
	}


	/**
		Randomly spread `value` in `nbStacks` stacks. Example:
	**/
	public static function spreadInStacks(value:Int, nbStacks:Int, ?maxStackValue:Null<Int>, randFunc:Int->Int) : Array<Int> {
		if( value<=0 || nbStacks<=0 )
			return new Array();

		if( maxStackValue!=null && value/nbStacks>maxStackValue ) {
			var a = [];
			for(i in 0...nbStacks)
				a.push(maxStackValue);
			return a;
		}

		if( nbStacks>value ) {
			var a = [];
			for(i in 0...value)
				a.push(1);
			return a;
		}

		var plist = new Array();
		for (i in 0...nbStacks)
			plist[i] = 1;

		var remain = value-plist.length;
		while (remain>0) {
			var move = M.ceil(value*(randFunc(8)+1)/100);
			if (move>remain)
				move = remain;

			var p = randFunc(nbStacks);
			if( maxStackValue!=null && plist[p]+move>maxStackValue )
				move = maxStackValue - plist[p];
			plist[p]+=move;
			remain-=move;
		}
		return plist;
	}


	/** Shuffle an array in place **/
	public static function shuffleArray<T>(arr:Array<T>, randFunc:Int->Int) {
		// WARNING!! Now modifies the array itself (changed on Apr. 27 2016)
		// Source: http://bost.ocks.org/mike/shuffle/
		var m = arr.length;
		var i = 0;
		var tmp = null;
		while( m>0 ) {
			i = randFunc(m--);
			tmp = arr[m];
			arr[m] = arr[i];
			arr[i] = tmp;
		}
	}

	/** Shuffle a vector in place **/
	public static function shuffleVector<T>(arr:haxe.ds.Vector<T>, randFunc:Int->Int) {
		// Source: http://bost.ocks.org/mike/shuffle/
		var m = arr.length;
		var i = 0;
		var tmp = null;
		while( m>0 ) {
			i = randFunc(m);
			m--;
			tmp = arr[m];
			arr[m] = arr[i];
			arr[i] = tmp;
		}
	}



	#if deepnightLibsTests
	public static function test() {
		// TODO
	}
	#end
}