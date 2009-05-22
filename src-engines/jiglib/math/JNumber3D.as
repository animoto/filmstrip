/*
 *  PAPER    ON   ERVIS  NPAPER ISION  PE  IS ON  PERVI IO  APER  SI  PA
 *  AP  VI  ONPA  RV  IO PA     SI  PA ER  SI NP PE     ON AP  VI ION AP
 *  PERVI  ON  PE VISIO  APER   IONPA  RV  IO PA  RVIS  NP PE  IS ONPAPE
 *  ER     NPAPER IS     PE     ON  PE  ISIO  AP     IO PA ER  SI NP PER
 *  RV     PA  RV SI     ERVISI NP  ER   IO   PE VISIO  AP  VISI  PA  RV3D
 *  ______________________________________________________________________
 *  papervision3d.org 茂驴?blog.papervision3d.org 茂驴?osflash.org/papervision3d
 */

/*
 * Copyright 2006 (c) Carlos Ulloa Matesanz, noventaynueve.com.
 *
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

// ______________________________________________________________________
//                                                               Number3D

package jiglib.math {

	/**
	 * The Number3D class represents a value in a three-dimensional coordinate system.
	 *
	 * Properties x, y and z represent the horizontal, vertical and z the depth axes respectively.
	 *
	 */
	public class JNumber3D {

		/**
		 * The horizontal coordinate value.
		 */
		public var x:Number;

		/**
		 * The vertical coordinate value.
		 */
		public var y:Number;

		/**
		 * The depth coordinate value.
		 */
		public var z:Number;

		
		/**
		 * Creates a new Number3D object whose three-dimensional values are specified by the x, y and z parameters. If you call this constructor function without parameters, a Number3D with x, y and z properties set to zero is created.
		 *
		 * @param	x	The horizontal coordinate value. The default value is zero.
		 * @param	y	The vertical coordinate value. The default value is zero.
		 * @param	z	The depth coordinate value. The default value is zero.
		 */
		public function JNumber3D( x:Number = 0, y:Number = 0, z:Number = 0 ) {
			this.x = x;
			this.y = y;
			this.z = z;
		}

		
		/**
		 * Returns a new Number3D object that is a clone of the original instance with the same three-dimensional values.
		 *
		 * @return	A new Number3D instance with the same three-dimensional values as the original Number3D instance.
		 */
		public function clone():JNumber3D {
			return new JNumber3D(this.x, this.y, this.z);
		}

		/**
		 * Copies the values of this number3d to the passed number3d.
		 * 
		 */
		public function copyTo(n:JNumber3D):void {
			n.x = x;
			n.y = y;
			n.z = z;
		}

		
		
		// ______________________________________________________________________ MATH

		/**
		 * Modulo
		 */
		public function get modulo():Number {
			return Math.sqrt(this.x * this.x + this.y * this.y + this.z * this.z);
		}

		
		/**
		 * Add
		 */
		public static function add( v:JNumber3D, w:JNumber3D ):JNumber3D {
			return new JNumber3D(v.x + w.x, v.y + w.y, v.z + w.z);
		}

		/**
		 * Substract.
		 */
		public static function sub( v:JNumber3D, w:JNumber3D ):JNumber3D {
			return new JNumber3D(v.x - w.x, v.y - w.y, v.z - w.z);
		}

		
		
		/**
		 * Dot product.
		 */
		public static function dot( v:JNumber3D, w:JNumber3D ):Number {
			return ( v.x * w.x + v.y * w.y + w.z * v.z );
		}

		/**
		 * Cross product.
		 */
		public static function cross( v:JNumber3D, w:JNumber3D ):JNumber3D {
			return new JNumber3D((w.y * v.z) - (w.z * v.y), (w.z * v.x) - (w.x * v.z), (w.x * v.y) - (w.y * v.x));
		}

		public function isFinite():Boolean {
			if (this.x > 1000000 || this.x < -1000000 ) return true;
			if (this.y > 1000000 || this.y < -1000000 ) return true;
			if (this.z > 1000000 || this.z < -1000000 ) return true;
			return false;
		}

		/**
		 * Normalize.
		 */
		public function normalize():void {
			var mod:Number = this.modulo;

			if( mod != 0 && mod != 1) {
				this.x /= mod;
				this.y /= mod;
				this.z /= mod;
			}
		}

		
		// ______________________________________________________________________



		/**
		 * Returns a Number3D object with x, y and z properties set to zero.
		 *
		 * @return A Number3D object.
		 */
		static public function get ZERO():JNumber3D {
			return new JNumber3D(0, 0, 0);
		}

		
		/**
		 * Returns a string value representing the three-dimensional values in the specified Number3D object.
		 *
		 * @return	A string.
		 */
		public function toString():String {
			return 'x:' + x + ' y:' + y + ' z:' + z;
		}

		
		
		
		
		
		
		/*
		 * modify by Muzer
		 */
		public function setTo(x:Number = 0, y:Number = 0, z:Number = 0):void {
			this.x = x;
			this.y = y;
			this.z = z;
		}

		public function toArray():Array {
			return new Array(this.x, this.y, this.z);
		}

		public function get modulo2():Number {
			return this.x * this.x + this.y * this.y + this.z * this.z;
		}

		public static function multiply(v:JNumber3D,w:Number):JNumber3D {
			return new JNumber3D(v.x * w, v.y * w, v.z * w);
		}

		public static function divide(v:JNumber3D,w:Number):JNumber3D {
			if(w != 0) {
				return new JNumber3D(v.x / w, v.y / w, v.z / w);
			} else {
				return new JNumber3D
				{
				0,
				0,
				0
				};
			}
		}
		
		public static function getNormal(v0:JNumber3D, v1:JNumber3D, v2:JNumber3D):JNumber3D {
			var E:JNumber3D = v1.clone();
			E = JNumber3D.sub(E, v0);
			var F:JNumber3D = v2.clone();
			F = JNumber3D.sub(F, v1);
			var N:JNumber3D = JNumber3D.cross(F, E);
			N.normalize();
			
			return N;
		}
		
		public function copyFromArray(arr:Array):void {
			if (arr.length >= 3) {
				this.x = arr[0];
				this.y = arr[1];
				this.z = arr[2];
			}
		}
		
		public static function limiteNumber(num:Number,min:Number,max:Number):Number {
			var n:Number = num;
			if (n < min) {
				n = min;
			} else if (n > max) {
				n = max;
			}
			return n;
		}

		static public function get UP():JNumber3D {
			return new JNumber3D(0, 1, 0);
		}

		static public function get RIGHT():JNumber3D {
			return new JNumber3D(1, 0, 0);
		}

		static public function get FRONT():JNumber3D {
			return new JNumber3D(0, 0, 1);
		}

		static public function get NUM_TINY():Number {
			return 0.00001;
		}

		static public function get NUM_HUGE():Number {
			return 100000;
		}
	}
}
