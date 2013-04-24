/**
 * Combination of insperation of GWT CellView stuff and http://datatables.net/.
 * GWT verbosity seems exessive and datatables.net api is pretty combersome.
 * Hopefully this strikes a balance between quick to get started and easy to customize
 * as the datatable gets more complex and featureful.
 * Code theft from: https://github.com/akserg/dart_web_toolkit/blob/master/lib/src/ui/cell_panel.dart
 *
 */
part of dwt_lhj;

/**
  * Wrapper around TableCellElement
  */
class Cell extends AbstractComplexPanel {
  Cell(Row _row) {
    setElement(_row.addCell());
    _row.add(this);
  }

  Cell.fromElement(TableCellElement e) {
    setElement(e);
  }
}

/**
  * Wrapper around TableRowElement
  */
class Row extends AbstractComplexPanel {
  TableRowElement _row;
  Row(TableRowElement this._row) {
    setElement(this._row);
  }

  Row.fromElement(TableRowElement this._row) {
    setElement(_row);
  }

  Cell addCell(ui.Widget w) {
    Cell c = new Cell.fromElement(_row.addCell());
    add(c);
    c.add(w);
    return c;
  }
}

/**
  * Wrraper around TableSectionElement
  */
class Table extends AbstractComplexPanel {
  TableSectionElement _table;
  Table.fromElement(TableSectionElement this._table) {
    setElement(this._table);
  }
  Row addRow() {
    Row r = new Row.fromElement(_table.addRow());
    add(r);
    return r;
  }
}

/**
  * Sort ordering
  */
const int SORT_ASCENDING = 0;
const int SORT_DESCENDING = 1;
/**
  * Will be called with the column key for which colum
  * needs to be sorted.
  */
typedef void SortColumn(String key, int order);

/**
  * Allow for custom formatting of a cell so that a column can call it when rendering the data
  */
typedef ui.Widget CustomFormatter(String field, dynamic row);

/**
  * This is pretty shaky right now need to think this though better
  * But it holds the column configuration for now. Will need to have
  * formatters and formatter callbacks eventually.
  */
class DTColumnConfig {
  String label;
  String key;
  int order;
  bool sortable;
  CustomFormatter formatter;

  DTColumnConfig(this.label, this.key, this.order, {bool this.sortable: false, CustomFormatter this.formatter: null}) { }
}


class DataTable extends AbstractComplexPanel {
  TableElement _table = new TableElement();
  Table _body;
  Table _head;
  SortColumn sortCallback;
  String upArrowClass;
  String downArrowClass;
  List<Row> rows = new List<Row>();
  List<String> columnKeys = new List<String>();
  Map<String, DTColumnConfig> columnConfigMap = new Map<String, DTColumnConfig>();

  DataTable({SortColumn sortCallback: null, String this.upArrowClass: 'icon-arrow-up', String this.downArrowClass: 'icon-arrow-down'}) {
    this.sortCallback = sortCallback;
    _body = new Table.fromElement(_table.createTBody());
    _head = new Table.fromElement(_table.createTHead());
    setElement(_table);
    add(_body);
    add(_head);
  }

  /**
   * Add the table header
   * TODO: This code is kinda a mess waiting for more 
   * options to shake out before it gets rewritten
   */
  Row addHead(List<DTColumnConfig> columns) {
    for(DTColumnConfig c in columns) {
      columnKeys.insert(c.order, c.key);
      columnConfigMap[c.key] = c;
    }
    List<ui.Widgets> labels = new List<ui.Widgets>();
    for(String k in columnKeys) {
      DTColumnConfig cConfig = columnConfigMap[k];
      ui.Label label = new ui.Label(cConfig.label);
      // Setup sorting if available
      if(cConfig.sortable) {
        ui.FlowPanel p = new ui.FlowPanel();
        // Keep the container from wrapping in the table column header 
        label.getElement().style.float = 'left';
        p.add(label);
        ui.Anchor upArrow = new ui.Anchor(true);
        upArrow.getElement().classes.add(upArrowClass);
        p.add(upArrow);
        ui.Anchor downArrow = new ui.Anchor(true);
        downArrow.getElement().classes.add(downArrowClass);
        p.add(downArrow);
        labels.add(p);
        // If we have a sort callback then call it
        if(sortCallback != null) {
          upArrow.addClickHandler(new event.ClickHandlerAdapter((event.ClickEvent e) {
                sortCallback(k, SORT_ASCENDING);
                }));
          downArrow.addClickHandler(new event.ClickHandlerAdapter((event.ClickEvent e) {
                sortCallback(k, SORT_DESCENDING);
                }));
        }
      } else {
        labels.add(label);
      }
    }
    return _newRow(_head.addRow(), labels);
  }

  Row addHeadConfig(List<Map<String,String>> config) {
    List<DTColumnConfig> columns = new List<DTColumnConfig>();
    for(Map<String, String> c in config) {
      bool sortable = false;
      if(c.containsKey('sortable')) {
        sortable = c['sortable'];
      }
      CustomFormatter f = null;
      if(c.containsKey('formatter')) {
        f = c['formatter'];
      }
      columns.add(new DTColumnConfig(c['label'], c['key'], c['order'], sortable:sortable, formatter:f));
    }
    addHead(columns);
  }

  /**
   * Add a single row and to the table
   */
  Row addRow(List<ui.Widgets> data) {
    return _newRow(_body.addRow(), data);
  }

  /**
   * Private wrapper for adding a list of data to a row
   */
  Row _newRow(Row tr, List<ui.Widgets> data) {
    for(Widget s in data) {
      tr.addCell(s);
    }
    return tr;
  }
  /**
    * Pass in a set of widgets. Helpful if already have a set of 
    * butons or handlers.
    */
  updateTable(List<Map<String, ui.Widget>> data) {
    _body.clear();
    for(Map<String, ui.Widget> r in data) {
      List<String> fields = new List<String>();
      for(String k in columnKeys) {
        ui.Widget w = r[k];
        DTColumnConfig c  = columnConfigMap[k];
        if(c.formatter != null) {
          w = c.formatter(r[k], r);
        }
        fields.add(w);
      }
      addRow(fields);
    }
  }

  /**
    * Update the data in the table
    */
  updateRecords(List<Map<String, String>> data) {
    _body.clear();
    for(Map<String, String> r in data) {
      List<String> fields = new List<String>();
      for(String k in columnKeys) {
        ui.Widget w = new ui.Html(r[k]);
        DTColumnConfig c  = columnConfigMap[k];
        if(c.formatter != null) {
          w = c.formatter(r[k], r);
        }
        // Hack hack ui.Html should support ui.widget!!
        fields.add(w);
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
  static final String PAGE_ID_PREFIX = 'dwt-lhj-page-';
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
    * This provides a way to set which page to start on numerically.
    * The actual page number will get computed programatically. This way
    * the client code can just keep track of the start and limit and not 
    * worry about computing how that renders on the pagination.
    */
  int _start = null;
  set start(int start) {
    _start = start;
  }


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

        // Provide override of which page to start on
        if(_start != null) {
          page = (_start / _pageSize).ceil();
          // Rest to null since the pagination is taking over now
          _start = null;
        }

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

