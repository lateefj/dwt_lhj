/**
  * Wrappers so that json requests have less typing involved
  */

part of dwt_lhj;
logging.Logger reqLog = new logging.Logger('lhj_dwt.request');

/**
  * Response handler converts to json.
  */
typedef HttpResponseHandler(dynamic data);

/**
  * If it does not return a 200 this error is called
  */
typedef HttpErrorHandler(HttpRequest req);

/**
  * Any exception for making the request this is called.
  */
typedef ExceptionErrorHandler(HttpRequest req, Exception e);

/**
  * My style request handler
  */
sendRequest(String url, String method, HttpErrorHandler errh, {HttpResponseHandler responseHandler:null, dynamic data:null, ExceptionErrorHandler exceptionHandler:null}) {
  reqLog.finest('Ulr for sendRequest $url');
  HttpRequest req = new HttpRequest();
  req.open(method, url);
  req.setRequestHeader('Content-type','application/json');
  try{
    req.onLoadEnd.listen((e) {
      reqLog.finest('Got request response and it is');
        if (req.status != 200) {
          reqLog.finest('Uh oh, error in investor by id ${req.status}');
          errh(req);
        } else {
          if(req.responseText != '' && responseHandler != null) {
            reqLog.finest('Response is being hanbdled');
            responseHandler(json.parse(req.responseText));
          }
        }
        });
    if(data != null) {
      req.send(json.stringify(data));
    } else {
      req.send('');
    }
  } on Exception catch(e) {
    if(exceptionHandler != null) {
      exceptionHandler(req, e);
    }
  }
}

getRequest(String url, HttpErrorHandler errh, {HttpResponseHandler responseHandler:null, dynamic data:null, ExceptionErrorHandler exceptionHandler:null}) {
  sendRequest(url, 'GET', errh, responseHandler:responseHandler, data:data, exceptionHandler:exceptionHandler);
}

postRequest(String url, HttpErrorHandler errh, {HttpResponseHandler responseHandler:null, dynamic data:null, ExceptionErrorHandler exceptionHandler:null}) {
  sendRequest(url, 'POST', errh, responseHandler:responseHandler, data:data, exceptionHandler:exceptionHandler);
}

putRequest(String url, HttpErrorHandler errh, {HttpResponseHandler responseHandler:null, dynamic data:null, ExceptionErrorHandler exceptionHandler:null}) {
  sendRequest(url, 'PUT', errh, responseHandler:responseHandler, data:data, exceptionHandler:exceptionHandler);
}

deleteRequest(String url, HttpErrorHandler errh, {HttpResponseHandler responseHandler:null, dynamic data:null, ExceptionErrorHandler exceptionHandler:null}) {
  sendRequest(url, 'DELETE', errh, responseHandler:responseHandler, data:data, exceptionHandler:exceptionHandler);
}

