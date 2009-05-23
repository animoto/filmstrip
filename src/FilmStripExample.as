package {
	import filmstripexamples.Dice;
	
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;

	[SWF(backgroundColor="#FFFFFF", frameRate="30")]
	
	public class FilmStripExample extends Sprite
	{
		private var t:TextField;
		public function FilmStripExample()
		{
			super();
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			var d:Dice = new Dice();
			addChild(d);
		}
	}
}
