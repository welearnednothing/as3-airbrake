/**
* Written by Cleversoap (clever@cleversoap.com)
* https://github.com/cleversoap/as3-airbrake
* MIT License (http://opensource.org/licenses/MIT)
*/
package com.cleversoap.airbrake
{
	import flash.errors.IllegalOperationError;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;

	/**
	* Core AirBrake notifier functionality.
	*
	* @important	This class should not be instantiated!
	*
	* http://help.airbrake.io/kb/api-2/notifier-api-v3
	*/
	internal class AirBrake
	{
		//-------------------------------------------------------------[MEMBERS]

		// Several properties are common (and useful) to both API versions
		protected var _apiKey         :String;
		protected var _environment    :Object;
		protected var _session        :Object;

		// Notifier Data
		protected var _notifier       :Object;

		// URL Request Params
		protected var _contentType    :String;
		protected var _apiUrl         :String;

		//---------------------------------------------------------[CONSTRUCTOR]

		/**
		* Initialises the core of the AirBrake functionality and properties.
		* 
		* @param $apiKey         AirBrake API key for your project.
		* @param $environment    Reporting environment such as "staging" or "production".
		* @param $projectVersion Version of project to report errors for.
		* @param $projectRoot    Root of the project and where the files are located.
		*/
		public function AirBrake($apiKey:String, $environment:Object, $session:Object = null)
		{
			// Assign core member properties that all AirBrake notifiers need.
			_apiKey = $apiKey;

			// Setup Environment
			_environment = $environment ? $environment : {};
			if (!_environment.hasOwnProperty("name"))
				_environment.name = "development";
			if (!_environment.hasOwnProperty("version"))
				_environment.version = "0.0";
			if (!_environment.hasOwnProperty("root"))
				_environment.root = "./";
				

			// Setup Session
			_session = $session ? $session : {};

			// Define the notifier to tell AirBrake that
			// what is reporting to it.
			_notifier = {
				"name"    : "com.cleversoap.AirBrake",
				"version" : "0.7",
				"url"     : "https://github.com/cleversoap/as3-airbrake"
			};
		}

		//----------------------------------------------------------[PROPERTIES]

		public function get environment():Object
		{
			return _environment;
		}

		public function get session():Object
		{
			return _session;
		}

		
		/**
		* AirBrake API key for the project.
		*/
		public function get apiKey():String
		{
			return _apiKey;
		}

		/**
		* AirBrake environment that errors will be reported to for the project.
		*/
		public function get environmentName():String
		{
			return _environment.name;
		}

		/**
		* Project root directory.
		*/
		public function get root():String
		{
			return _environment.root; 
		}

		/**
		* Project version that errors will be reported for.
		*/
		public function get version():String
		{
			return _environment.version; 
		}

		//----------------------------------------------------[MEMBER FUNCTIONS] 

		/**
		* Make a URLRequest object that contains the data generated by child
		* implementations of this class. References the _contentType and
		* _apiUrl members.
		*
		* @param $notice Implementation specific notice data.
		*/
		protected function makeRequest($notice:*):URLRequest
		{
			var request:URLRequest = new URLRequest();
			request.method         = URLRequestMethod.POST;
			request.contentType    = _contentType;
			request.url            = _apiUrl;
			request.data           = $notice;
			return request;
		}

		/**
		* Parse an Error object's stack trace and extract all relevant
		* meta-data; in particular the function, file, and line number
		* of each entry. This function also calls makeBackTraceLine which
		* should be implemented by child classes.
		*
		* @param $stackTrace The stack trace string of the Error object.
		*/
		protected function parseStackTrace($stackTrace:String):Array
		{
			var backTrace:Array = [];	

			var lineRegExp:RegExp = /at (?P<type>[\w\.:]+):*\/*(?P<method>\w+)?\(\)(\[(?P<file>.*):(?P<line>\d+)\])?/g;
			
			// Iterate over each entry and call the hopefully implemented
			// makeBackTraceLine to store the entry in the array.
			var match:Object;
			while (match = lineRegExp.exec($stackTrace))
			{
				backTrace.push(makeBackTraceLine(
					(match.file ? match.file : match.type),    // File
					uint(match.line ? match.line : 0),         // Line Number
					(match.method ? match.method : match.type) // Function
				));
			}

			return backTrace;
		}


		/**
		* Parse out the class that the error occurred in.
		* This is useful for specifying a component param in the request
		* element of the response.
		*
		* @param $stackTrace The stack trace string of the Error object.
		*/
        protected function parseComponent($stackTrace:String) : String
        {
            var lineRegExp:RegExp = /at (?P<type>[\w\.:]+):*\/*(?P<method>\w+)?\(\)(\[(?P<file>.*):(?P<line>\d+)\])?/;
            var match:Object = lineRegExp.exec($stackTrace);
            return match ? match.type : null;
        }


		/**
		* Should be used by child classes to make an implementation specific
		* data structure for each stack trace entry.
		*
		* @param $file     File in which the error occurred or was called.
		* @param $line     Line at which the error occurred or was called.
		* @param $function Function in which the error occurred or was called.
		*/
		protected function makeBackTraceLine($file:String, $line:uint, $function:String):*
		{
			throw new IllegalOperationError("makeBackTraceLine must be called from child class implementation only");
		}
	}
}
