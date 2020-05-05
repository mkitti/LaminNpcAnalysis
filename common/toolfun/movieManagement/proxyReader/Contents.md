The ProxyReader family of classes makes use of the proxy and decorator design patterns
to extend the functionality of Reader.

Rather than implement new functionality of Reader in each backend specific subclass
of Reader, these subclasses add functionality at runtime to any class implementing the
Reader interface.

These functional interface enhancements include:

* Inline caching that obviates the need for preloading steps, see CachedReader and CachedStackReader
* MATLAB-style linear indexing into the CTZ dimensions, see LinearReader
* MATLAB-style cell datatype interface to image planes, see CellReader
* Reading YXZ volumes with a cell datatype interface, see VolumeReader
* Reading YXT time series stacks via a cell datatype interface, see TimeSeriesReader
* Limit reader to a subset of the underlying data, see SubIndexReader and ChannelReader

Class tree is as follows

* ProxyReader
    * CachedReader
        * CachedStackReader
    * SubIndexReader
        * ChannelReader
    * LinearReader
        * CellReader
            * SqueezedCellReader
            * VolumeReader
            * TimeSeriesReader
    * LoadStackTestReader

List of classes:

  CachedReader        - CachedReader Reader proxy class that caches loadImage and loadStack calls
  CachedStackReader   - CachedStackReader Uses Reader.loadStack where possible to optimize
  CellReader          - CellReader Reader proxy class that presents a cell like interface
  ChannelReader       - ChannelReader Creates a reader confined to a single channel
  LinearReader        - LinearReader Allows for images to be loaded using linear indexing
  LoadStackTestReader - LoadStackTestReader compares the optimized loadStack to the generic loadStack
  ProxyReader         - ProxyReader Facilitates the use of a proxy design pattern to extend
  SubIndexReader      - SubIndexReader Creates a reader with a subindex for subindexing into
  TimeSeriesReader    - TimeSeriesReader Reads XYT matrices as if arranged in a CxZ cell array
  VolumeReader        - VolumeReader Reads XYZ matrices as if arranged in a cell array
