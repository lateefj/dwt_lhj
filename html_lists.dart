part of dwt_lhj;

/*
 * Based on https://github.com/akserg/dart_web_toolkit/blob/master/lib/src/ui/flow_panel.dart 
 */
class LiPanel extends AbstractComplexPanel {
  LiPanel() {
    setElement(new LIElement());
  }

  LiPanel.fromElement(LIElement e) {
    setElement(e);
  }
}

class UlListPanel extends AbstractComplexPanel {
  UlListPanel() {
    setElement(new UListElement());
  }

  UlListPanel.fromElement(UListElement e) {
    setElement(e);
  }
}
