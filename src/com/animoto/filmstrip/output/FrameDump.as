package com.animoto.filmstrip.output
{
	import com.animoto.animotor.events.OutputModuleEvent;
	import com.animoto.animotor.events.RenderEvent;
	import com.animoto.animotor.interfaces.IAnimotorRenderer;
	import com.animoto.animotor.interfaces.IOutputModule;
	import com.animoto.animotor.model.ProjectModel;
	import com.animoto.animotor.model.RenderQueueItemVO;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.graphics.ImageSnapshot;
	import mx.graphics.codec.IImageEncoder;
	import mx.graphics.codec.JPEGEncoder;
	import mx.graphics.codec.PNGEncoder;

	public class FrameDump extends EventDispatcher implements IOutputModule
	{
		public var vo: RenderQueueItemVO;
		
		//--
		
		protected var step:Number = 0;
		protected var encoder:IImageEncoder;
		protected var encode:Boolean = false;
		protected var folderName:String;
		protected var width:Number;
		protected var height:Number;
		protected var frameRate: Number;
		protected var fileBase:File;
		
		//--

		public function FrameDump(queue:IAnimotorRenderer=null) {
			if (queue!=null)
				init(queue);
		}
		
		public function init(queue:IAnimotorRenderer):void
		{
			//trace("Frame Dump Module.init()");
			this.vo = queue.vo;
			queue.addEventListener(RenderEvent.FRAME_RENDERED, handleRenderEvents);
			queue.addEventListener(RenderEvent.RENDER_COMPLETE, handleRenderEvents);
			
			switch (vo.outputExtension) {
				case ".png" : encoder = new PNGEncoder(); encode = true; break;
				case ".jpg" : encoder = new JPEGEncoder(100); encode = true; break;
			}

			// generate output directory
			// folderName = documentsFolder;
			folderName = vo.outputFolderPath;
			if (folderName==null) {
				// default outputFolderPath
				folderName = File.userDirectory.nativePath + "/" + RenderQueueItemVO.OUTPUT_FOLDER_PATH + "/" + ProjectModel.inst().projectName;
				if (folderName.indexOf(".aeml")>-1)
					folderName = folderName.slice(0, folderName.indexOf(".aeml"));
				else if (folderName.indexOf(".xml")>-1)
					folderName = folderName.slice(0, folderName.indexOf(".xml"));
				if (vo.outputExtension.length>0)
					folderName += "-" + vo.outputExtension.slice(1);
				if (vo.outputDefault!=null)
					folderName += "-" + vo.outputDefault;
			}
			fileBase = new File(folderName);
			if (fileBase.exists) {
				//trace("** Moving old framedump directory to trash ('"+ folderName +"') **");
				fileBase.moveToTrash();
			}
			fileBase.createDirectory();
			
			var infoFile:File = fileBase.resolvePath("_info.txt");
			var fs:FileStream = new FileStream(); 
			fs.open(infoFile, FileMode.WRITE);
			fs.writeUTF("width,height,framerate:"+vo.width+","+vo.height+","+vo.frameRate); 
			fs.close();
		}
		
		public function handleRenderEvents(e:RenderEvent=null):void {
			switch (e.type) {
				case RenderEvent.FRAME_RENDERED: addFrame(e); return;
				case RenderEvent.RENDER_COMPLETE: logStats(e.stats); return;
			}
		}
		
		protected function addFrame(e:RenderEvent):void {
			var zeros:String = "0000";
			var path:String = String(step);
			path = zeros.slice(path.length) + path;
			//path = folderName + "/" + ProjectModel.inst().projectName + extension;
			path = folderName + "/" + path + vo.outputExtension;
			var file:File = fileBase.resolvePath(path); 
			var fs:FileStream = new FileStream(); 
			fs.open(file, FileMode.WRITE);
			if (encode) {
				var i:ImageSnapshot = ImageSnapshot.captureImage(e.bitmapData, 0, encoder);
				var imagedata:ByteArray = i.data;
				fs.writeBytes(imagedata, 0, imagedata.length);
			}
			else {
				fs.writeBytes(e.bitmapData.getPixels(e.bitmapData.rect));
			}
			fs.close();
			step++;
			this.dispatchEvent(new OutputModuleEvent(OutputModuleEvent.FRAME_SAVED, e.time));
		}
		
		protected function logStats(stats:String=null): void {
			if (stats==null)
				return;
			if (stats.length==0)
				return;
			
			var statsFile:File = fileBase.resolvePath("_stats.txt");
			var fs:FileStream = new FileStream(); 
			fs.open(statsFile, FileMode.WRITE);
			fs.writeUTF(stats); 
			fs.close();
		}
	}
}