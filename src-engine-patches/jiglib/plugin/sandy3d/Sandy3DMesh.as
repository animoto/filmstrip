package jiglib.plugin.sandy3d 
{
	import jiglib.math.JMatrix3D;
	import jiglib.plugin.ISkin3D;
	
	import sandy.core.data.Matrix4;
	import sandy.core.scenegraph.Shape3D;

	/**
	 * @author bartekd
	 */
	public class Sandy3DMesh implements ISkin3D
	{
		
		private var shape:Shape3D;

		public function Sandy3DMesh(shape:Shape3D) 
		{
			this.shape = shape;
		}

		public function get transform():JMatrix3D 
		{
			var tr:JMatrix3D = new JMatrix3D();
			tr.n11 = this.shape.matrix.n11; 
			tr.n12 = this.shape.matrix.n12; 
			tr.n13 = this.shape.matrix.n13; 
			tr.n14 = this.shape.matrix.n14;
			tr.n21 = this.shape.matrix.n21; 
			tr.n22 = this.shape.matrix.n22; 
			tr.n23 = this.shape.matrix.n23; 
			tr.n24 = this.shape.matrix.n24;
			tr.n31 = this.shape.matrix.n31; 
			tr.n32 = this.shape.matrix.n32; 
			tr.n33 = this.shape.matrix.n33; 
			tr.n34 = this.shape.matrix.n34;
			tr.n41 = this.shape.matrix.n41; 
			tr.n42 = this.shape.matrix.n42; 
			tr.n43 = this.shape.matrix.n43; 
			tr.n44 = this.shape.matrix.n44;
			 
			return tr;
		}
		
		public function set transform(m:JMatrix3D):void 
		{
			var tr:Matrix4 = new Matrix4();
			//
			tr.n11 = m.n11; 
			tr.n12 = m.n12; 
			tr.n13 = m.n13; 
			tr.n14 = m.n14;
			tr.n21 = m.n21; 
			tr.n22 = m.n22; 
			tr.n23 = m.n23; 
			tr.n24 = m.n24;
			tr.n31 = m.n31; 
			tr.n32 = m.n32; 
			tr.n33 = m.n33; 
			tr.n34 = m.n34;
			tr.n41 = m.n41; 
			tr.n42 = m.n42; 
			tr.n43 = m.n43; 
			tr.n44 = m.n44;
			//
			this.shape.initFrame();
			this.shape.matrix = tr;
		}
		
		public function get mesh():Shape3D 
		{
			return shape;
		}
	}
}
