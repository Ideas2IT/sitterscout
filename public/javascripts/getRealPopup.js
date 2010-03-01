// =========================================================================
//  getRealPopup v1.42
//      by John Norton - http://www.amplifystudios.com
//      Last Modified: 6/3/08
//
// Licensed under the Creative Commons Attribution 2.5 License - http://creativecommons.org/licenses/by/2.5/
//  	- Free for use in both personal and commercial projects
//		- Attribution requires leaving author name, author link, and the license info intact.
//
// How to use:
//     To use the popup function make sure you import the apropreate libraries 
//     ( those found in this example ). No modifications have been made to any 
//     acompaning javascript libraries. Once you have imported the libraries 
//     call the showPop() function ( see TOC for proper formatting ). To set 
//     any default features please modify the variable below. To close a popup 
//     all the hidePopup() function ( see TOC for proper formatting ).
//
// ============================= EDIT THIS VARIABLE ============================= 
// PopupVariables = [float FadeDuration, float FadeValue, string MaskColor, bool UseAutoPopupPosition, int PopupWidth, int PopupHeight];
var PopupVariables = [0.5, 0.6, '#000000', true, 200, 200];
// ============================= EDIT THIS VARIABLE ============================= 
// 
//    Table of contents:
//   ---------------------
//   Variables
//     - getPageSize()
//     - hidePop( string PopupObject )
//     - PopupVariables[]
//     - showPop( string PopupObject, int Width(Optional), int Height(Optional) )
//     - SetEventHandler( string EventName, function EventHandler )
//   Classes
//     - PopupClass
//   PopupControl Class
//     - PopupControl
//     - PopupControl.FadeDuration       : 0.0 -> ...
//     - PopupControl.FadeVal            : 0.0 -> 1.0
//     - PopupControl.MaskColor          : #000000 -> #FFFFFF OR red, blue, ect...
//     - PopupControl.UseAutoPopupPos    : true | false
//     - PopupControl.PopupWidth         : 1 -> ...
//     - PopupControl.PopupHeight        : 1 -> ...
//     - PopupControl.CurrentPopup       : Dont set this. The popup functions modify this when needed.
//     - PopupControl.CurrentPopupW      : Dont set this. The popup functions modify this when needed.
//     - PopupControl.CurrentPopupH      : Dont set this. The popup functions modify this when needed.
//     - PopupControl.createMask()
//     - PopupControl.togglePopup( string PopupObject, bool ShowPopup, int Width, int Height )
//     - PopupControl.getPopPos( int Width, int Height )
//     - PopupControl.autoPosFix()
//     - PopupControl.togMask( bool ShowMask )
//     - PopupControl.report()
// 
// =========================================================================

// =========================================================================
// Popup Class
var PopupClass = Class.create({
	initialize: function(PopupVariables) {
    	this.FadeDuration = PopupVariables[0];
    	this.FadeVal = PopupVariables[1];
		this.MaskColor = PopupVariables[2];
		this.UseAutoPopupPos = PopupVariables[3];
		this.PopupWidth = PopupVariables[4];
		this.PopupHeight = PopupVariables[5];
		this.CurrentPopup = null;   //I get overwriten alot. I wouldnt bother with me
		this.CurrentPopupW = null;   //I get overwriten alot. I wouldnt bother with me
		this.CurrentPopupH = null;   //I get overwriten alot. I wouldnt bother with me
		this.createMask(PopupVariables[2]);
  	},
	// PopupControl.createMask();
	createMask: function(mc){
		//create popup function
		var bo = document.getElementsByTagName("body").item(0);
		var objS = document.createElement("div");
		objS.setAttribute('id','popFadeO');
		objS.style.zIndex = 100;
		objS.style.position = 'absolute';
		objS.style.lineHeight = '0px';
		objS.style.left = '0px';
		objS.style.backgroundColor = mc;
		objS.style.display = 'none';
		objS.style.top = '0px';
		bo.appendChild(objS);
		$( 'popFadeO' ).style.width = getPageSize()[0] + "px";
		$( 'popFadeO' ).style.height = getPageSize()[1] + "px";
		//initialize page events
	},
	
	// PopupControl.togglePopup( string PopupObject, bool ShowPopup, int Width, int Height );
	togglePopup: function( o, b, w, h ){
		if( b )
		{	//show popup
			PopupControl.CurrentPopup = o;
			PopupControl.CurrentPopupW = w;
			PopupControl.CurrentPopupH = h;
			$( o ).style.top = this.setPopPos( w, h )[0] + "px";
			$( o ).style.left = (this.setPopPos( w, h )[1])/2 + "px";
			$( o ).style.right = (this.setPopPos( w, h )[1])/2 + "px";	
			$( o ).style.position = 'absolute';			
			$( o ).style.backgroundColor = '#CEDEFF';
			$( o ).style.borderWidth = '1px';
			$( o ).style.borderColor =  '#003399';
												
			this.togMask( true );
			$( o ).style.zIndex = 101; //so we dont have to do it in the css
			new Effect.Appear( o, { duration: PopupControl.FadeDuration, from: 0.0, to: 1.0 });
		}
		else
		{	//hide popup
			this.togMask( false );
			this.CurrentPopup = null;
			new Effect.Fade( o, { duration: PopupControl.FadeDuration, from: 1.0, to: 0.0 });
		}
	},
	
	// PopupControl.getPopPos( int Width, int Height );
	setPopPos: function( w, h )
	{
//		alert('setPopPos');
		var top = (((getPageSize()[3] - h) / 2) < 0) ? 0 : ((getPageSize()[3] - h) / 2);
		top += getPageSize()[5];
		var right = (((getPageSize()[2] - w) / 2) < 0) ? 0 : ((getPageSize()[2] - w) / 2);
		right += getPageSize()[4];
		return [top, right];
	},

	// PopupControl.autoPosFix();
	autoPosFix: function()
	{
		if( PopupControl.CurrentPopup != null && PopupControl.UseAutoPopupPos )
		{
//			$( PopupControl.CurrentPopup ).style.top = PopupControl.setPopPos( PopupControl.CurrentPopupW, PopupControl.CurrentPopupH )[0] + "px";
//			$( PopupControl.CurrentPopup ).style.left = PopupControl.setPopPos( PopupControl.CurrentPopupW, PopupControl.CurrentPopupH )[1]/2 + "px";
		}
		$( 'popFadeO' ).style.width = getPageSize()[0] + "px";
		$( 'popFadeO' ).style.height = getPageSize()[1] + "px";
	},

	// PopupControl.togMask( bool ShowMask );
	togMask: function( b )
	{	//Note: calling this function alone will result in an inacesable site. 
		//		This displays NO close buttons. Just the mask.
		if( b )
		{
			new Effect.Appear('popFadeO', { duration: PopupControl.FadeDuration, from: 0.0, to: PopupControl.FadeVal });
		}
		else
		{
			new Effect.Fade('popFadeO', { duration: PopupControl.FadeDuration, from: PopupControl.FadeVal, to: 0.0 });
		}
	},

	// PopupControl.report();
	report: function() 
	{
		alert("Reporting popup class object variables:" +
			  "\nFadeDuration=" + PopupControl.FadeDuration + 
			  "\nFadeVal=" + PopupControl.FadeVal +
			  "\nMaskColor=" + PopupControl.MaskColor +
			  "\nUseAutoPopupPos=" + PopupControl.UseAutoPopupPos +
			  "\nPopupWidth=" + PopupControl.PopupWidth +
			  "\nPopupHeight=" + PopupControl.PopupHeight);
	}
});
// =========================================================================

// =========================================================================
// Popup Display Functions
var PopupControl = null;
// showPop( string PopupObject, int Width(Optional), int Height(Optional) );
function showPop( o, w, h ) 
{ 	//This is a simple go-between. you dont need it but it makes it easier to call popups.
	//See togglePopup for actual popup calls.
	if( PopupControl == null )
	{   //create the popup object if it dosn't exist yet.
		PopupControl = new PopupClass(PopupVariables);
		SetEventHandler("resize", PopupControl.autoPosFix);
		SetEventHandler("scroll", PopupControl.autoPosFix);
	}
	w = (w == null) ? PopupControl.PopupWidth : w;
	h = (h == null) ? PopupControl.PopupHeight : h;
	PopupControl.togglePopup( o, true, w, h );
}

	function showPop1(id1,width,height){
        var id = document.getElementById(id1);
        if (id != null) {
            id.style.display = "";
            id.style.zIndex = 998;
            id.style.backgroundColor = '#FFFFFF';
            id.style.textAlign = 'center';
            id.style.overflow = 'hidden';
 		    id.style.width = width;
			id.style.height = height;			
            id.style.position = 'fixed';
	        id.style.top = '10%';
            id.style.left = '10%';			

			RedBox.showOverlay();
        }
    }
	
	function showPop2(id1,width,height){
        var id = document.getElementById(id1);
        if (id != null) {
            id.style.display = "";
            id.style.zIndex = 998;
            id.style.backgroundColor = '#FFFFFF';
            id.style.textAlign = 'center';
            id.style.overflow = 'hidden';
 		    id.style.width = width;
			id.style.height = height;			
            id.style.position = 'fixed';
	        id.style.top = '30%';
            id.style.left = '25%';			

			RedBox.showOverlay();
        }
    }
	
// hidePop( string PopupObject );
function hidePop( o ) 
{ 	//This is a simple go-between. you dont need it but it makes it easier to call popups.
	//See togPop for actual popup calls.
	if( PopupControl == null )
	{   //just incase we need to hide a popup before we use the show function.
		PopupControl = new PopupClass( PopupVariables );
		SetEventHandler("resize", PopupControl.autoPosFix);
		SetEventHandler("scroll", PopupControl.autoPosFix);
	}
	PopupControl.togglePopup( o, false ); 
}

// =========================================================================
// Page Functions

// getPageSize();
function getPageSize() 
{
	var xScroll, yScroll;
	
	var xScrollPos, yScrollPos;
	
	if (window.innerHeight && window.scrollMaxY) 
	{	
		xScroll = window.innerWidth + window.scrollMaxX;
		yScroll = window.innerHeight + window.scrollMaxY;
		xScrollPos = window.pageXOffset;
		yScrollPos = window.pageYOffset;
	} 
	else if (document.body.scrollHeight > document.body.offsetHeight)
	{ // all but Explorer Mac
		xScroll = document.body.scrollWidth + 20;
		yScroll = document.body.scrollHeight + 28;
		xScrollPos = document.documentElement.scrollLeft;
		yScrollPos = document.documentElement.scrollTop;
	} 
	else 
	{ // Explorer Mac...would also work in Explorer 6 Strict, Mozilla and Safari
		xScroll = document.body.offsetWidth + 20;
		yScroll = document.body.offsetHeight + 28;
		xScrollPos = document.documentElement.scrollLeft;
		yScrollPos = document.documentElement.scrollTop;
	}
	
	var windowWidth, windowHeight;
	
	if (self.innerHeight) 
	{	// all except Explorer
		if(document.documentElement.clientWidth){
			windowWidth = document.documentElement.clientWidth; 
		} 
		else 
		{
			windowWidth = self.innerWidth;
		}
		windowHeight = self.innerHeight;
	} 
	else if (document.documentElement && document.documentElement.clientHeight) 
	{ // Explorer 6 Strict Mode
		windowWidth = document.documentElement.clientWidth;
		windowHeight = document.documentElement.clientHeight;
	} 
	else if (document.body) 
	{ // other Explorers
		windowWidth = document.body.clientWidth + 20;
		windowHeight = document.body.clientHeight + 28;
	}	
	
	// for small pages with total height less then height of the viewport
	if(yScroll < windowHeight)
	{
		pageHeight = windowHeight;
	} 
	else 
	{ 
		pageHeight = yScroll;
	}
	
	// for small pages with total width less then width of the viewport
	if(xScroll < windowWidth){	
		pageWidth = xScroll;		
	} else {
		pageWidth = windowWidth;
	}
	
	return [pageWidth, pageHeight, windowWidth, windowHeight, xScrollPos, yScrollPos];
}

// SetEventHandler( string EventName, function EventHandler );
function SetEventHandler(eventname, handler)
{
	if(window.addEventListener)
	{
		window.addEventListener(eventname, handler, false);
	}
	else if(window.attachEvent)
	{
		window.attachEvent("on" + eventname, handler);
	}
}



// =========================================================================
