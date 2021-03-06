part of dartflex;

abstract class IViewStackElement implements IUIWrapper {
  
  //---------------------------------
  //
  // Events
  //
  //---------------------------------
  
  Stream<FrameworkEvent> get onRequestViewChange;

}

class ViewStack extends UIWrapper {

  //---------------------------------
  //
  // Private properties
  //
  //---------------------------------

  bool _isScrollPolicyInvalid = false;

  //---------------------------------
  //
  // Public properties
  //
  //---------------------------------
  
  //---------------------------------
  // container
  //---------------------------------
  
  Group _container;
  
  Group get container => _container;
  
  //---------------------------------
  // registeredViews
  //---------------------------------
  
  List<ViewStackElementData> _registeredViews = new List<ViewStackElementData>();
  
  List<ViewStackElementData> get registeredViews => _registeredViews;
  
  //---------------------------------
  // activeView
  //---------------------------------
  
  String get activeView => (_activeViewStackElement != null) ? _activeViewStackElement.uniqueId : null;
  
  //---------------------------------
  // activeViewStackElement
  //---------------------------------
  
  ViewStackElementData _activeViewStackElement;
  ViewStackElementData _inactiveViewStackElement;
  
  ViewStackElementData get activeViewStackElement => _activeViewStackElement;

  //---------------------------------
  //
  // Constructor
  //
  //---------------------------------

  ViewStack({String elementId: null}) : super(elementId: elementId) {
  	_className = 'ViewStack';
  	
  	_createChildren();
  }

  //---------------------------------
  //
  // Public methods
  //
  //---------------------------------
  
  void addComponent(IUIWrapper element, {bool prepend: false}) {
    throw new ArgumentError('Please use addView() instead');
  }
  
  void addView(String uniqueId, IViewStackElement element) {
    ViewStackElementData viewStackElement;
    int i = _registeredViews.length;
    
    while (i > 0) {
      viewStackElement = _registeredViews[--i];
      
      if (viewStackElement.uniqueId == uniqueId) {
        return;
      }
    }
    
    viewStackElement = new ViewStackElementData();
    
    viewStackElement.element = element;
    viewStackElement.uniqueId = uniqueId;
    
    element.onRequestViewChange.listen(_viewStackElement_requestViewChangeHandler);
    
    _registeredViews.add(viewStackElement);
  }
  
  int _xOffset = 0;
  int _xOffsetSwitch = 0;
  
  bool show(String uniqueId) {
    if (_container == null) {
      onControlChanged.listen(
          (FrameworkEvent event) => show(uniqueId)
      );
    } else {
      ViewStackElementData viewStackElement;
      final int currentIndex = (_activeViewStackElement != null) ? _registeredViews.indexOf(_activeViewStackElement) : -1;
      int newIndex = -1;
      int i = _registeredViews.length;
      
      while (i > 0) {
        viewStackElement = _registeredViews[--i];
        
        if (viewStackElement.uniqueId == uniqueId) {
          newIndex = i;
          
          break;
        }
      }
      
      if (
          (currentIndex == newIndex) ||
          (newIndex == -1)
      ) {
        return false;
      }
      
      viewStackElement.element.visible = true;
      viewStackElement.element.preInitialize(this);
      
      if (currentIndex >= 0) {
        _inactiveViewStackElement = _activeViewStackElement;
        
        if (newIndex > currentIndex) {
          --_xOffset;
          
          _xOffsetSwitch = 1;
        } else {
          ++_xOffset;
          
          _xOffsetSwitch = -1;
        }
      }
      
      _activeViewStackElement = viewStackElement;
      
      _reflowManager.invalidateCSS(_container.control, 'transition', 'left .75s ease-out');
      _reflowManager.invalidateCSS(_container.control, 'transitionDelay', '.6s');
      
      _container.addComponent(viewStackElement.element);
      
      _updateLayout();
      
      return true;
    }
    
    return false;
  }

  //---------------------------------
  //
  // Protected methods
  //
  //---------------------------------

  void _createChildren() {
    if (_control == null) {
      _setControl(new DivElement());
    }
    
    _layout = new AbsoluteLayout();
    
    _container = new Group()
    ..inheritsDefaultCSS = false
    ..classes = ['_ViewStackSlider']
    .._layout = new AbsoluteLayout();
    
    _reflowManager.invalidateCSS(
        _container._control,
        'position',
        'absolute'
    );
    
    super.addComponent(_container);
    
    _container.control.onTransitionEnd.listen(_container_transitionEndHandler);

    super._createChildren();
  }
  
  void _updateLayout() {
    super._updateLayout();
    
    if (_container != null) {
      _container.x = _xOffset * _width;
      _container.width = 2 * _width;
      _container.height = _height;
    }

    if (_activeViewStackElement != null) {
      _activeViewStackElement.element.x = _xOffset * -_width;
      _activeViewStackElement.element.width = _width;
      _activeViewStackElement.element.height = _height;
    }
  }
  
  void _viewStackElement_requestViewChangeHandler(ViewStackEvent event) {
    if (event.namedView != null) {
      show(event.namedView);
    } else if (event.sequentialView > 0) {
      final int len = _registeredViews.length;
      final int index = _registeredViews.indexOf(_activeViewStackElement);
      ViewStackElementData requestedElement;
      int requestedIndex;
      
      if (event.sequentialView == ViewStackEvent.REQUEST_PREVIOUS_VIEW) {
        requestedIndex = index - 1;
      } else if (event.sequentialView == ViewStackEvent.REQUEST_NEXT_VIEW) {
        requestedIndex = index + 1;
      } else if (event.sequentialView == ViewStackEvent.REQUEST_FIRST_VIEW) {
        requestedIndex = 0;
      } else if (event.sequentialView == ViewStackEvent.REQUEST_LAST_VIEW) {
        requestedIndex = len - 1;
      }
      
      requestedIndex = (requestedIndex < 0) ? (len - 1) : (requestedIndex >= len) ? 0 : requestedIndex;
      
      requestedElement = _registeredViews[requestedIndex];
      
      show(requestedElement.uniqueId);
    }
  }
  
  void _container_transitionEndHandler(Event event) {
    if (_inactiveViewStackElement != null) {
      _reflowManager.scheduleMethod(this, _container_hideInactiveView, [], forceSingleExecution: true);
    }
    
    _reflowManager.invalidateCSS(_container.control, 'transition', 'left 0s ease-out');
    _reflowManager.invalidateCSS(_container.control, 'transitionDelay', '0s');
  }
  
  void _container_hideInactiveView() {
    _inactiveViewStackElement.element.visible = false;
    
    _inactiveViewStackElement = null;
  }
}

class ViewStackElementData {
  
  IUIWrapper element;
  String uniqueId;
  
}

