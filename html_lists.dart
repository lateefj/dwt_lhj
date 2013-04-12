part of dwt_lhj;

class AbstracListPanel extends ui.ComplexPanel implements ui.InsertPanelForIsWidget {
  /**
   * Adds a new child widget to the panel.
   *
   * @param w the widget to be added
   */
  void add(ui.Widget w) {
    addWidget(w, getElement());
  }

  void clear() {
    try {
      doLogicalClear();
    } finally {
      // Remove all existing child nodes.
      for (Element element in getElement().children) {
        element.remove();
      }
    }
  }
  void insertIsWidget(ui.IsWidget w, int beforeIndex) {
    insertWidget(asWidgetOrNull(w), beforeIndex);
  }

  /**
   * Inserts a widget before the specified index.
   *
   * @param w the widget to be inserted
   * @param beforeIndex the index before which it will be inserted
   * @throws IndexOutOfBoundsException if <code>beforeIndex</code>code> is out of
   *           range
   */
  void insertWidget(ui.Widget w, int beforeIndex) {
    insert(w, getElement(), beforeIndex, true);
  }
}
/*
 * Based on https://github.com/akserg/dart_web_toolkit/blob/master/lib/src/ui/flow_panel.dart 
 */
class LiPanel extends AbstracListPanel {
  LiPanel() {
    setElement(new LIElement());
  }
  LiPanel.fromElement(LIElement e) {
    setElement(e);
  }
}

class UlListPanel extends AbstracListPanel {
  UlListPanel() {
    setElement(new UListElement());
  }
}
