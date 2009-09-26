var SelectAutocompleter = {}
SelectAutocompleter.Base = Class.create(); //<label id="code.create" />
Object.extend(Object.extend(SelectAutocompleter.Base.prototype,
                            Autocompleter.Base.prototype), {
    selectBaseInitialize: function(element, update, options) {
        this.baseInitialize(element, update, options);			
        this.select = null;
        this.valueElement = null;
    	this.cache = [];
		
        this.options["rowCount"] = this.options["rowCount"] || 7;
		this.options["useCache"] = !(this.options["useCache"] == false)
    },
      
    onBlur: function(event) {
      // needed to make click events working
      blurTimer = setTimeout(this.hide.bind(this), 250);
      this.hasFocus = false;
      this.active = false;     
    },

    onSelectFocus: function(event) {
	    clearTimeout(blurTimer);
    },

    updateChoices: function(choices) {
	    if(!this.changed && this.hasFocus) {
	      this.update.innerHTML = choices;
	      Element.cleanWhitespace(this.update);
	      Element.cleanWhitespace(this.update.down());
    	
	      if(this.update.firstChild && this.update.down().childNodes) {
	  	    this.select = this.update.firstChild;
		    this.select.style.width = '100%';
		    this.select.size = this.options["rowCount"];
	        this.entryCount = this.select.length;
		    Event.observe(this.select, "focus", this.onSelectFocus.bindAsEventListener(this));
		    Event.observe(this.select, "keypress", this.onSelectKeyPress.bindAsEventListener(this));
		    Event.observe(this.select, "blur", this.onBlur.bindAsEventListener(this));
		    Event.observe(this.select, "click", this.onSelectClick.bindAsEventListener(this));
	      } else { 
	        this.entryCount = 0;
	      }

	      this.stopIndicator();
		  if (this.options["useCache"] == true)
    	  	this.cache[this.getToken()] = choices;
		  
	      if(this.select.length == 1 && this.options.autoSelect) {
	        this.selectEntry();
	        this.hide();
	      } else {
	        this.render();
	      }
	    }
      }, 

    render: function() {
    if(this.select.length > 0) {
      if(this.hasFocus) { 
        this.show();
        this.active = true;
      }
    } else {
      this.active = false;
      this.hide();
    }
    },

    show: function() {
    if(Element.getStyle(this.update, 'display')=='none') this.options.onShow(this.element, this.update);
    },

    hide: function() {
    this.stopIndicator();
    if(Element.getStyle(this.update, 'display')!='none') this.options.onHide(this.element, this.update);
    },

    onKeyPress: function(event) {
    if(this.active)
      switch(event.keyCode) {
       case Event.KEY_TAB:
       case Event.KEY_RETURN:
         this.selectEntry();
         Event.stop(event);
       case Event.KEY_ESC:
         this.hide();
         this.active = false;
         Event.stop(event);
         return;
       case Event.KEY_LEFT:
       case Event.KEY_RIGHT:
         return;
       case Event.KEY_DOWN:
	     if (this.select && this.select.length > 0) {
			if (this.select.length > 1)
	 	    	this.select.selectedIndex = 1;	
	 	    this.select.focus();			
     	    Event.stop(event);
     	    return;
	      }
      }
     else 
       if(event.keyCode==Event.KEY_TAB || event.keyCode==Event.KEY_RETURN || 
         (navigator.appVersion.indexOf('AppleWebKit') > 0 && event.keyCode == 0)) return;

    this.changed = true;
    this.hasFocus = true;

    if(this.observer) clearTimeout(this.observer);
      this.observer = 
        setTimeout(this.onObserverEvent.bind(this), this.options.frequency*1000);
      },

    getCurrentEntry: function() {
      return this.select.options[this.select.selectedIndex];
    },

    updateElement: function(selectedElement) {
    if (this.options.redirect_url) {
		this.hide();
	    location = this.options.redirect_url.replace(/%3F%3F|\?\?/i, selectedElement.value);
		return;	
	}
    this.element.value = selectedElement.text;
    if (!this.valueElement)
		this.valueElement = $(this.options.valueElement);
	if (this.valueElement)
	    this.valueElement.value = selectedElement.value;	
    this.element.focus();
    if (this.options.afterUpdateElement)
      this.options.afterUpdateElement(this.element, selectedElement);
    },
	
	onObserverEvent: function() {
	  this.changed = false;
	  var token = this.getToken();
	  if(token.length>=this.options.minChars) {
	  	if (this.options["useCache"] == true && this.cache[token]) {
			this.updateChoices(this.cache[token]);
		} else {
	    	this.startIndicator();
	    	this.getUpdatedChoices();
		}
	  } else {
	    this.active = false;
	    this.hide();
	  }
	},

    onSelectKeyPress: function(event) {
      switch(event.keyCode) {
       case Event.KEY_TAB:
       case Event.KEY_RETURN:
         this.selectEntry();
         Event.stop(event);
       case Event.KEY_ESC:
         this.hide();
         this.element.focus();
         Event.stop(event);
      }
    },

    onSelectClick: function(event) {
    this.selectEntry();
    this.hide();
    }
    });

    Ajax.SelectAutocompleter = Class.create();
    Object.extend(Object.extend(Ajax.SelectAutocompleter.prototype, SelectAutocompleter.Base.prototype), {
    initialize: function(element, update, url, options) {
    this.selectBaseInitialize(element, update , options);
    this.options.asynchronous  = true;
    this.options.onComplete    = this.onComplete.bind(this);
    this.options.defaultParams = this.options.parameters || null;
    this.url                   = url;
    },

    getUpdatedChoices: function() {
    entry = encodeURIComponent(this.options.paramName) + '=' + 
      encodeURIComponent(this.getToken());

    this.options.parameters = this.options.callback ?
      this.options.callback(this.element, entry) : entry;

    if(this.options.defaultParams) 
      this.options.parameters += '&' + this.options.defaultParams;

    new Ajax.Request(this.url, this.options);
    },

    onComplete: function(request) {
    this.updateChoices(request.responseText);
    }

});