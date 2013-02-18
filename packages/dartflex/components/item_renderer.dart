part of dartflex.components;

abstract class IItemRenderer implements IUIWrapper {
  
  int get index;
  set index(int value);
  
  String get state;
  set state(String value);
  
  int get width;
  set width(int value);
  
  int get height;
  set height(int value);
  
  bool get selected;
  set selected(bool value);
  
  Object get data;
  set data(Object value);
  
  void createChildren();
  
  void invalidateData();
  
  void updateLayout();
  
  void updateAfterInteraction();
  
}

class ItemRenderer extends UIWrapper implements IItemRenderer {
  
  //---------------------------------
  //
  // Protected properties
  //
  //---------------------------------
  
  Graphics _selectIndicator;
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // index
  //---------------------------------
  
  int _index = 0;
  
  int get index => _index;
  set index(int value) {
    if (value != _index) {
      _index = value;
    }
  }
  
  //---------------------------------
  // data
  //---------------------------------
  
  Object _data;
  
  Object get data => _data;
  set data(Object value) {
    if (value != _data) {
      _data = value;
      
      _invalidateData();
    }
  }
  
  //---------------------------------
  // state
  //---------------------------------
  
  String _state = 'mouseout';
  
  String get state => _state;
  set state(String value) {
    if (value != _state) {
      _state = value;
      
      later > _updateAfterInteraction;
    }
  }
  
  //---------------------------------
  // selected
  //---------------------------------
  
  bool _selected = false;
  bool _isSelectionInvalid = false;
  
  bool get selected => _selected;
  set selected(bool value) {
    if (value != _selected) {
      _selected = value;
      _isSelectionInvalid = true;
      
      later > _updateAfterInteraction;
    }
  }
  
  //---------------------------------
  // selected
  //---------------------------------
  
  String get interactionStyle {
    List<String> enum = new List<String>();
    
    if (_selected) {
      enum.add('selected');
    }
    
    enum.add(_state);
    
    return enum.join('_');
  }
  
  //---------------------------------
  // autoDrawBackground
  //---------------------------------
  
  bool _autoDrawBackground;
  
  bool get autoDrawBackground => _autoDrawBackground;
  set autoDrawBackground(bool value) {
    if (value != _autoDrawBackground) {
      _autoDrawBackground = value;
    }
  }
  
  //---------------------------------
  // gap
  //---------------------------------
  
  int _gap = 0;
  
  int get gap => _gap;
  set gap(int value) {
    if (value != _gap) {
      _gap = value;
      
      later > _updateLayout;
    }
  }
  
  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------
  
  ItemRenderer({String elementId: null, bool autoDrawBackground: true}) : super(elementId: null) {
    _autoDrawBackground = autoDrawBackground;
  }
  
  static ItemRenderer construct() {
    return new ItemRenderer();
  }
  
  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  void createChildren() {
  }
  
  void invalidateData() {
  }
  
  void updateLayout() {
  }
  
  void updateAfterInteraction() {
  }
  
  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------
  
  void _createChildren() {
    super._createChildren();
    
    DivElement container = new DivElement();
    
    _setControl(container);
    
    _control.style.overflow = 'hidden';
    
    container.style.border = '1px solid #cccccc';
    
    createChildren();
    
    later > _invalidateData;
  }
  
  void _invalidateData() {
    invalidateData();
  }
  
  void _updateLayout() {
    super._updateLayout();
    
    if (_autoDrawBackground) {
      later > _updateAfterInteraction;
    }
    
    updateLayout();
  }
  
  double _fraction;
  
  void _updateAfterInteraction() {
    if (!_autoDrawBackground) {
      return;
    }
    
    if (
        (_selectIndicator != null) &&
        (_selectIndicator.context != null)
    ) {
      _selectIndicator.x = _x;
      _selectIndicator.y = _y;
      _selectIndicator.width = _width;
      _selectIndicator.height = _height;
      
      if (_selected) {
        if (_isSelectionInvalid) {
          _isSelectionInvalid = false;
          
          _fraction = .0;
          
          later > _applySelectionAlpha;
        }
      } else if (_state != 'mouseout') {
        _selectIndicator.context.clearRect(0, 0, _width, _height);
        
        _selectIndicator.context.beginPath();
        
        _selectIndicator.context.globalAlpha = .5;
        _selectIndicator.context.fillStyle = '#80bbee';
        _selectIndicator.context.fillRect(0, 0, _width, _height);
        
        _selectIndicator.context.closePath();
      } else {
        _selectIndicator.context.clearRect(0, 0, _width, _height);
      }
    } else if (_selectIndicator == null) {
      _selectIndicator = new Graphics();
      
      add(_selectIndicator, prepend: true);
    } else {
      later > _updateAfterInteraction;
    }
    
    updateAfterInteraction();
  }
  
  void _applySelectionAlpha() {
    if (_selected) {
      _fraction += .025;
      
      IEaser easer = new Sine();
      double currentFraction = easer.ease((_fraction > 1.0) ? 1.0 : _fraction);
      
      _selectIndicator.context.clearRect(0, 0, _width, _height);
      
      _selectIndicator.context.beginPath();
      
      _selectIndicator.context.globalAlpha = currentFraction;
      _selectIndicator.context.fillStyle = '#80bbee';
      _selectIndicator.context.fillRect(0, 0, _width, _height);
      
      _selectIndicator.context.closePath();
      
      if (_fraction < 1.0) {
        later > _applySelectionAlpha;
      }
    }
  }
}
