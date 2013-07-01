/**
 * There is already a route API however I could get it to work with
 * wildcard.
 */
part of dwt_lhj;

logging.Logger routeLog = new logging.Logger('lhj_dwt.router');

typedef PatternHandler(String path);
class Router {
  bool debug = false;
  Map<RegExp, PatternHandler> patterns = new Map<RegExp, PatternHandler>();

  addRegex(RegExp r, PatternHandler handler) {
    patterns[r] = handler;
  }

  listen() {
    ui.History.addValueChangeHandler(new event.ValueChangeHandlerAdapter<String>((event.ValueChangeEvent<String> e) {
          String path = e.value;
          if(debug) {
            routeLog.finest('dwt_lhj.Router path change: $path');
          }
          handle(path);
        }));
  }

  handle(String path) {
    for(RegExp r in patterns.keys) {
      if(r.firstMatch(path) != null) {
          if(debug) {
            routeLog.finer('dwt_lhj.Router found match for path: $path');
          }
        patterns[r](path);
        return; // Only match a single pattern
      }
    }
  }
}


