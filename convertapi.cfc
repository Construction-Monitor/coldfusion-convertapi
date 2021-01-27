component accessors="true"{
	
	function init(string secret){
		variables.apiKey = secret;
		variables.baseUrl = "https://v2.convertapi.com/";
		return this;
	}

	function convertDoc(fromFormat,toFormat,localFile,newFilePath) hint="Error codes found at https://www.convertapi.com/doc/content-types" {
		var convertAPI = new http();
		convertAPI.setURL("https://v2.convertapi.com/#fromFormat#/to/#toFormat#?Secret=#variables.apiKey#");
		convertAPI.setMethod("POST");
		convertAPI.addParam(type="file", file=localFile, name="file");
		var convertAPIResponse = convertAPI.send().getPrefix();
		var newHttpResponse = structNew();
		if(!structKeyExists(convertAPIResponse, 'Responseheader') || !structKeyExists(convertAPIResponse['Responseheader'], 'Status_Code') || convertAPIResponse.Responseheader.Status_Code != 200) {
			var serverError = "";
			if(structKeyExists(convertAPIResponse, "Filecontent") && isJSON(convertAPIResponse.Filecontent)) {
				var serverErrorJson = deserializeJSON(convertAPIResponse.Filecontent);
				var serverError = (structKeyExists(serverErrorJson, "Message") ? serverErrorJson['Message'] & ' ' : '') & (structKeyExists(serverErrorJson, "Code") ? "Code: #serverErrorJson['code']# " : '');
				if(len(serverError)) {
					serverError = serverError & ' (https://www.convertapi.com/doc/content-types)';
				}
			}

			throw(type="convertapi.convertDoc.error", message=(len(serverError) ? serverError : "Something went wrong with ConvertAPI and we got no error information back from their servers."));
		}

		if(structKeyExists(convertAPIResponse,"Filecontent") && isJSON(trim(convertAPIResponse.filecontent))){
			var fileContent = deserializeJSON(convertAPIResponse.fileContent);
			structInsert(newHttpResponse, "Filecontent", fileContent, true);
			if(structKeyExists(newHttpResponse.Filecontent, 'Files') && isArray(newHttpResponse.Filecontent.Files) && arrayLen(newHttpResponse.Filecontent.Files) > 0 && structKeyExists(newHttpResponse.Filecontent.Files[1], 'FileData')) {
				fileWrite(newFilePath,tobinary(newHttpResponse.Filecontent.Files[1].FileData));
				return true;
			}
		}
		return false;
	}
}
