package jiglib.plugin.papervision3d {
	import jiglib.plugin.ISkin3D;
	import jiglib.math.JMatrix3D;
	
	import org.papervision3d.core.math.Matrix3D;
	import org.papervision3d.objects.DisplayObject3D;	

	/**
	 * @author bartekd
	 */
	public class Pv3dMesh implements ISkin3D{
		
		private var do3d:DisplayObject3D;

		public function Pv3dMesh(do3d:DisplayObject3D) {
			this.do3d = do3d;
		}

		public function get transform():JMatrix3D {
			var tr:JMatrix3D = new JMatrix3D();
			tr.n11 = do3d.transform.n11; 
			tr.n12 = do3d.transform.n12; 
			tr.n13 = do3d.transform.n13; 
			tr.n14 = do3d.transform.n14;
			tr.n21 = do3d.transform.n21; 
			tr.n22 = do3d.transform.n22; 
			tr.n23 = do3d.transform.n23; 
			tr.n24 = do3d.transform.n24;
			tr.n31 = do3d.transform.n31; 
			tr.n32 = do3d.transform.n32; 
			tr.n33 = do3d.transform.n33; 
			tr.n34 = do3d.transform.n34;
			tr.n41 = do3d.transform.n41; 
			tr.n42 = do3d.transform.n42; 
			tr.n43 = do3d.transform.n43; 
			tr.n44 = do3d.transform.n44;
			 
			return tr;
		}
		
		public function set transform(m:JMatrix3D):void {
			var tr:Matrix3D = new Matrix3D();
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
			do3d.transform = tr;
		}
		
		public function get mesh():DisplayObject3D {
			return do3d;
		}
	}
}
