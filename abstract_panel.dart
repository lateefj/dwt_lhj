/**
 * Kinda redonkey but looks like the start of a very large class
 * hierarchy....
 */
class AbstractComplexPanel extends ui.ComplexPanel implements ui.InsertPanelForIsWidget {
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

