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
  set text(String text) {
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
    if(text == null) {
      text = '';
    }
    c.text = text;
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


/**
 * Function signiture when a page is selected it will call this function
 * with the page as the first param and page multiplied by the size as
 * the second param.
 */
typedef SelectedPage(int page, int start);

/**
 * Rough draft of a paginator. I am currently using bootstrap paginator for this.
 * TODO: Don't display all pages just the previous and next couple from the relative page
 */
class Paginator extends ui.Composite {
  static final String PAGE_ID_PREFIX = 'dwt_lhj-page-';
  ui.FlowPanel main = new ui.FlowPanel();
  UlListPanel pager = new UlListPanel();
  LiPanel first = new LiPanel();
  LiPanel last = new LiPanel();
  event.ClickHandlerAdapter selectPageHandler;
  SelectedPage selectedCallback;
  /**
   * This disables the paginator
   */
  String disabledClass = 'disabled';
  /**
   * Set on whatever is the currently active page.
   */
  String activeClass = 'active';
  /**
   * The main div class.
   */
  String divWrapperClass = 'pagination';

  //TODO: Need to add support for classes to the first and last page
  /**
   * The first page
   */
  String firstPageIcon = '<<';
  /**
   * The last page icon
   */
  String lastPageIcon = '>>';

  /**
    * The total number of pages to display.
    */
  int pagesLimit = 10;  // TODO: Implement that pages as being relative to the current page

  /**
   * Default page size
   */
  int _pageSize = 10;
  set pageSize(int s) {
    _pageSize = s;
    updatePages();
  }
  int _totalRecords = null;
  /**
   * Resetting the total number of records need to recalculate the
   * number of pages. Then if the current page the reset limit then
   * need to place it at the last page. Best compromize compared to
   * just resetting to the first page?
   */
  set totalRecords(int s) {
    if(_totalRecords == null || _totalRecords != s) {
      int page = 0;
      if(current != null) {
        page = _parsePageId(current.getElement().children[0].id);
      }
      _totalRecords = s;
      updatePages();
      if(current != null) {
        // First make sure the page is not after the current number pages that are available
        if(page * _pageSize >= s - _pageSize) {
          // Get the last page if it is past it
          page = (_totalRecords / _pageSize).ceil() - 1;
        }
        setPage(page);
      }
    }
  }

  LiPanel current = null;
  Paginator([SelectedPage selectedCallback = null]) {
    this.selectedCallback = selectedCallback;

    selectPageHandler = new event.ClickHandlerAdapter((event.ClickEvent e) {
        pageSelected(e.getRelativeElement().id);
        });
    ui.Anchor fa = new ui.Anchor();
    fa.html = firstPageIcon;
    fa.getElement().id = '${PAGE_ID_PREFIX}first';
    fa.addClickHandler(selectPageHandler);
    first.add(fa);
    ui.Anchor la = new ui.Anchor();
    la.html = lastPageIcon;
    la.getElement().id = '${PAGE_ID_PREFIX}last';
    last.add(la);
    la.addClickHandler(selectPageHandler);
    initWidget(main);
    main.getElement().classes.add(divWrapperClass);
    main.add(pager);
  }

  /**
   * Set the page for with is being selected
   */
  setPage(int p) {
    if(current != null) {
      current = new LiPanel.fromElement(current.getElement());
      current.getElement().classes.remove(disabledClass);
      current.getElement().classes.remove(activeClass);
    }
    // Find the current element
    current = new LiPanel.fromElement(pager.getElement().children[p+1]);
    // Set it to activeClass
    current.getElement().classes.add(activeClass);
    //current.getElement().classes.add(disabledClass);
    // If first then disable the firt page option
    if(p == 0) {
      first.getElement().classes.add(disabledClass);
      first.getElement().classes.add(activeClass);
    } else {
      first.getElement().classes.remove(disabledClass);
      first.getElement().classes.remove(activeClass);
    }
    // If last then disable the last page option
    if(p == pager.getElement().children.length -3) {
      last.getElement().classes.add(disabledClass);
    } else {
      last.getElement().classes.remove(disabledClass);
      last.getElement().classes.remove(activeClass);
    }
  }

  /**
   * Regenerate the list of pages based on change in result set or
   * if page size has changed. Or could be called because maybe data
   * changed on the backend.
   */
  updatePages() {
    int pages = (_totalRecords / _pageSize).ceil();
    pager.clear();
    pager.add(first);
    for(int i=0; i<pages; i++) {
      ui.Anchor a = new ui.Anchor();
      a.html = '${i+1}';
      a.getElement().id = '${PAGE_ID_PREFIX}${i}';
      a.addClickHandler(selectPageHandler);
      LiPanel l = new LiPanel();
      l.add(a);
      pager.add(l);
    }
    pager.add(last);
    setPage(0);
  }

  int _parsePageId(String key) {
    key = key.replaceFirst(PAGE_ID_PREFIX, '');
    int p = 0;
    if(key == 'first') {
      p = 0;
    } else if (key == 'last') {
      p = pager.getElement().children.length - 3;
    } else {
      p = int.parse(key);
    }
    return p;
  }
  /**
   * Called when a page is selected this parses the page number
   * and calls back to whatever is set for the callback function
   */
  pageSelected(String key) {
    int p = _parsePageId(key);
    int start = p * _pageSize;
    // Need to do call back passing para
    if(selectedCallback != null) {
      selectedCallback(p, start);
    }
    setPage(p);
  }
}

