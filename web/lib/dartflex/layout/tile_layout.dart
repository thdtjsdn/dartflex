part of dartflex;

class TileLayout implements ILayout {

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------

  //---------------------------------
  // useVirtualLayout
  //---------------------------------

  bool _useVirtualLayout = false;

  bool get useVirtualLayout => _useVirtualLayout;
  set useVirtualLayout(bool value) {
    if (value != _useVirtualLayout) {
      _useVirtualLayout = value;
    }
  }

  //---------------------------------
  // gap
  //---------------------------------

  int _gap = 10;

  int get gap => _gap;
  set gap(int value) => _gap = value;

  //---------------------------------
  // constrainToBounds
  //---------------------------------

  bool _constrainToBounds = true;

  bool get constrainToBounds => _constrainToBounds;
  set constrainToBounds(bool value) => _constrainToBounds = value;
  
  //---------------------------------
  // align
  //---------------------------------

  String _align = 'left';

  String get align => _align;
  set align(String value) => _align = value;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  TileLayout({bool constrainToBounds: true}) {
    _constrainToBounds = constrainToBounds;
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------

  void doLayout(int width, int height, int pageItemSize, int pageOffset, int pageSize, List<IUIWrapper> elements) {
    UIWrapper element;
    int percWidth = width;
    final int percWidthFloored = (pageItemSize == 0) ? 0 : (pageOffset ~/ pageItemSize * pageItemSize);
    int offset = _useVirtualLayout ? percWidthFloored : 0;
    int w, h, sx, i;
    int staticElmLen = 0;
    final int len = elements.length;
    
    for (i=0; i<len; i++) {
      element = elements[i];
      
      element.reflowManager.invalidateCSS(element.control, 'position', 'absolute');

      if (!element.includeInLayout) {
        staticElmLen++;
      } else if (
          (element.percentWidth == 0.0) &&
          (element.width > 0)
      ) {
        percWidth -= element.width;

        staticElmLen++;
      }
    }

    sx = elements.length - staticElmLen;

    percWidth -= staticElmLen * _gap;
    
    for (i=0; i<len; i++) {
      element = elements[i];
      
      if (element.includeInLayout) {
        if (element.percentWidth > 0.0) {
          w = (element.percentWidth * .01 * (percWidth - _gap * (sx - 1)) / sx).toInt() - element.paddingLeft - element.paddingRight;
        } else if (element.width > 0) {
          w = element.width - element.paddingLeft - element.paddingRight;
        }

        if (element.percentHeight > 0) {
          h = (height * element.percentHeight * .01).toInt() - element.paddingTop - element.paddingBottom;
        } else if (element.height > 0) {
          h = element.height - element.paddingTop - element.paddingBottom;
        }

        w = (w == null) ? 0 : w;
        h = (h == null) ? 0 : h;

        if (
            (pageSize == 0) ||
            ((offset + w) <= pageSize)
        ) {
          if (_align == 'left') {
            element.x = offset + element.paddingLeft;
          } else if (_align == 'right') {
            element.x = width - offset - element.paddingLeft - - element.paddingRight - element.width;
          }
        } else {
          element.x = element.paddingLeft;
        }

        if (_constrainToBounds) {
          element.y = (height * .5 - h * .5).toInt() + element.paddingTop;
        }

        if (element.autoSize) {
          element.width = w;
        }

        if (_constrainToBounds && element.autoSize) {
          element.height = h;
        }

        offset += w + _gap + element.paddingLeft + element.paddingRight;
      } else {
        element.x = element.paddingLeft;
        element.y = element.paddingTop;
      }
    }
  }

}





