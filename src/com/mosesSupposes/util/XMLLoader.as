/**
 * Copyright (c) 2008 Moses Gunesch
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package com.mosesSupposes.util {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Dictionary;

	/**
	 * Simple XML loading class with load retries & error handling.
	 * 
	 * <p>Your callback should receive the xml as a single argument, in 
	 * which case you don't have to retain any reference to the XMLLoader
	 * instance, it will persist until finished then clean itself up.
	 * Instances are not reusable.</p>
	 * 
	 * <p>IOErrorEvent is re-dispatched after all xmlLoadAttempts.
	 * If you include a root scope, errorMessage will be drawn onscreen.</p>
	 * 
	 * <pre>
	 * // Simplest usage: No references or listeners required!
	 * new XMLLoader(onXMLLoad, "path/to/my.xml");
	 * </pre>
	 * 
	 * @author moses gunesch
	 */
	public class XMLLoader extends EventDispatcher
	{
		// Class settings
		public static var xmlLoadAttempts: uint = 3;
		public static var errorMessage: String = "XML Load Error!";
		
		// Class automated instantiation
		public static function create(loadCallback:Function, xmlPath:String=null, root:Sprite=null, sendDataInsteadOfXML:Boolean=false):XMLLoader {
			return new XMLLoader(loadCallback, xmlPath, root, sendDataInsteadOfXML);
		}
		
		// Public properties
		public var xml: XML;
		public var xmlPath: String;
		
		// Private
		private static var _retainer: Dictionary = new Dictionary(false);
		private var _root: Sprite;
		private var _xmlLoadAttempt: uint = 0;
		private var _loader: URLLoader;
		private var _request: URLRequest;
		private var _loadCallback: Function;
		private var _sendData: Boolean;
		
		/**
		 * Constructor.
		 * @param loadCallback			You must define one callback for successful load, which can have a single input to receive the XML object.
		 * @param xmlPath				Optional, or you can set it after instantiation via the xmlPath setter.
		 * @param root					If specified, the errorMessage string will be drawn on stage in a textfield.
		 * @param sendDataInsteadOfXML	If true, the raw loaded data is passed instead of an XML object.
		 * 
		 */
		public function XMLLoader(loadCallback:Function, xmlPath:String=null, root:Sprite=null, sendDataInsteadOfXML:Boolean=false)
		{
			_retainer[this] = 1;
			_root = root;
			this.xmlPath = xmlPath;
			_request = new URLRequest( xmlPath );
			_loader = new URLLoader();
			_loader.addEventListener(Event.COMPLETE, onXMLLoad);
			_loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_loadCallback = loadCallback;
			_sendData = sendDataInsteadOfXML;
			if (xmlPath!=null)
				loadXML();
		}
		
		public function destroy():void {
			_root = null;
			xml = null;
			xmlPath = null;
			_loader = null;
			_request = null;
			_loadCallback = null;
			delete _retainer[this];
		}
		
		private function loadXML() : void {
			//trace("loadXML");
			if (xmlPath!=null && xmlPath.length>4)
				_loader.load( _request );
			else
				Util.softError("No XML path has been set.");
		}
		
		private function ioErrorHandler(event:IOErrorEvent) : void {
			if (++_xmlLoadAttempt < xmlLoadAttempts) {
				loadXML();
				return;
			}
			displayLoadError();
			dispatchEvent(event.clone());
			trace("********** ioError *********");
			trace(errorMessage);
			trace(event.text);
			trace("****************************");
			destroy();
		}
		
		private function onXMLLoad(event:Event) : void 
		{
			if (_sendData)
				_loadCallback(_loader.data);
			else
				_loadCallback(new XML(_loader.data));
			destroy();
		}
		
		public function displayLoadError() : void {
			if (_root==null)
				return;
			var errorText : TextField = new TextField();
			errorText.autoSize = "left";
			errorText.embedFonts = true;
			errorText.antiAliasType = AntiAliasType.ADVANCED;
			errorText.text = errorMessage;
			errorText.setTextFormat(new TextFormat("Courier New", 13, 0, false, true, false, null, null, "center"));
			errorText.x = int( _root.stage.stageWidth - errorText.width*0.5 );
			errorText.y = int( _root.stage.stageHeight - errorText.height*0.5 );
			_root.addChild(errorText);
		}
	}
}
