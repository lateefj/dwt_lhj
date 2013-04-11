dwt_lhj
=======

This is a combination of missing widgets that I find useful like LI and UI
Panels and some ideas that I am testing out like tables.

html_lists.dart
---------------
There is not much to see here really just simple wrappers around the LI and UI.
For some reason these where omitted in GWT and seem to be also ommitted in DWT.
Probably shoudl add OL at some point but haven't needed it yet.

tables.dart
-----------
Cellviews is a pretty complete library that I found to be kinda tedious to use
in GWT. Like most things Java it is very wordy to try and get a basic table
created. On the flip side datatables.net is easy to use but a real mess of an
API. This is an attempt to create an API that can be giving some simple configuration
however the full API is exposed so when the needs of the datatable get more complex
it is not confusing how to use it. Mainly driving the configuration via a backend I 
wanted a way the configuration could be json, making it easy for the types of data 
driven sites I am building.
