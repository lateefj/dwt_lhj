/**
 * There is already a route API however I could get it to work with
 * wildcard.
 */
part of dwt_lhj;


typedef PatternHandler(String path);
class Router {
  Map<RegExp, PatternHandler> patterns = new Map<RegExp, PatternHandler>();

  addRegex(RegExp r, PatternHandler handler) {
    patterns[r] = handler;
  }

  listen() {
    ui.History.addValueChangeHandler(new event.ValueChangeHandlerAdapter<String>((event.ValueChangeEvent<String> e) {
          String path = e.value;
          window.console.debug('Changed path to $path');
          handle(path);
        }));
  }

  handle(String path) {
    for(RegExp r in patterns.keys) {
      if(r.firstMatch(path) != null) {
        patterns[r](path);
      }
    }
  }

}


