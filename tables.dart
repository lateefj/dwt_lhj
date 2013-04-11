/**
  * Combination of insperation of GWT CellView stuff and http://datatables.net/. 
  * GWT verbosity seems exessive and datatables.net api is pretty lacking for customization. 
  * Hopefully this strikes a balance between quick to get started and easy to customize
  * as the datatable gets more complex and featureful.
  * Code theft from: https://github.com/akserg/dart_web_toolkit/blob/master/lib/src/ui/cell_panel.dart
  *
  */
part of dwt_lhj;
/**
  * Kinda redonkey but looks like the start of a very large class 
  * hierarchy....
  */
class AbstracComplexPanel extends ui.ComplexPanel implements ui.InsertPanelForIsWidget {
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

class Cell extends AbstracComplexPanel {
  Row _row; // Row this cell is associated with
  TableCellElement _cell;
  Cell(Row this._row, TableCellElement this._cell) {
    setElement(_cell);
  }
  setText(String text) {
    _cell.text = text;
  }
}

class Row extends AbstracComplexPanel {
  List<Cell> cells = new List<Cell>();
  TableRowElement _row;
  Row(TableRowElement this._row) {
    setElement(_row);
  }
  Cell addCell(String text) {
    Cell c = new Cell(this, _row.addCell());
    c.setText(text);
    cells.add(c);
    return c;
  }
}
class DTColumnConfig {
  String label;
  String key;
  int order;
  DTColumnConfig(this.label, this.key, this.order) { }
}

class DataTable extends ui.ComplexPanel {
  TableElement _table = new TableElement();
  TableSectionElement _body;
  TableSectionElement _head;
  List<Row> rows = new List<Row>();
  List<String> columnKeys = new List<String>();
  Map<String, DTColumnConfig> columnConfigMap = new Map<String, DTColumnConfig>();

  DataTable() {
  _body = _table.createTBody();
  _head = _table.createTHead();
    setElement(_table);
  }

  /**
    * Hadd the table header
    */
  Row addHead(List<DTColumnConfig> columns) {
    for(DTColumnConfig c in columns) {
      columnKeys.insert(c.order, c.key);
      columnConfigMap[c.key] = c;
    }
    List<String> labels = new List<String>();
    for(String k in columnKeys) {
      labels.add(columnConfigMap[k].label);
    }
    return _newRow(_head.addRow(), labels);
  }
  Row addHeadConfig(List<Map<String,String>> config) {
    List<DTColumnConfig> columns = new List<DTColumnConfig>();
    for(Map<String, String> c in config) {
      columns.add(new DTColumnConfig(c['label'], c['key'], c['order']));
    }
    addHead(columns);
  }

  /**
    * Add a single row and to the table
    */
  Row addRow(List<String> data) {
    return _newRow(_body.addRow(), data);
  }

  /**
    * Private wrapper for adding a list of data to a row
    */
  Row _newRow(TableRowElement tr, List<String> data) {
    Row r = new Row(tr);
    for(String s in data) {
      r.addCell(s);
    }
    return r;
  }

  updateRecords(List<Map<String, String>> data) {
    _body.children.clear();
    for(Map<String, String> r in data) {
      List<String> fields = new List<String>();
      for(String k in columnKeys) {
        fields.add(r[k]);
      }
      addRow(fields);
    }
  }
}
