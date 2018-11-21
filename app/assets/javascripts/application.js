// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery.turbolinks
//= require rails-ujs
//= require bootstrap

//= require hammer
//= require hammer.min

//= require jquery.hammer

//= require hammer-time
//= require hammer-time.min

//= require touch-emulator

//= require turbolinks
//= require_tree .
//= require serviceworker-companion


//ハーフモーダル
class Pushbar {
	  constructor(config = { overlay: true, blur: false }) {
	    this.activeBar = null;
	    this.overlay = false;

	    if ($('div').hasClass("pushbar_overlay")) {
		  //class activeがあれば
		  } else if (!$('div').hasClass("pushbar_overlay")) {
		  //class activeが無かったら
		    if (config.overlay) {
		      this.overlay = document.createElement('div');
		      this.overlay.classList.add('pushbar_overlay');
		      document.querySelector('body').appendChild(this.overlay);
		    }
		}

	    if (config.blur) {
	      const mainContent = document.querySelector('.pushbar_main_content');
	      if (mainContent) {
	        mainContent.classList.add('pushbar_blur');
	      }
	    }

	    this.bindEvents();
	  }

	  get opened() {
	    const { activeBar } = this;
	    return Boolean(activeBar instanceof HTMLElement && activeBar.classList.contains('opened'));
	  }
	  
	  get activeBarId() {
	    const { activeBar } = this;
	    return activeBar instanceof HTMLElement && activeBar.getAttribute('data-pushbar-id');
	  }

	  static dispatchOpen(pushbar) {
	    const event = new CustomEvent('pushbar_opening', { bubbles: true, detail: { pushbar } });
	    pushbar.dispatchEvent(event);
	  }

	  static dispatchClose(pushbar) {
	    const event = new CustomEvent('pushbar_closing', { bubbles: true, detail: { pushbar } });
	    pushbar.dispatchEvent(event);
	  }

	  static findElementById(pushbarId) {
	    return document.querySelector(`[data-pushbar-id="${pushbarId}"]`);
	  }

	  handleOpenEvent(e) {
	    e.preventDefault();
	    const pushbarId = e.currentTarget.getAttribute('data-pushbar-target');
	    if (pushbarId) {
	      this.open(pushbarId);
	    }
	  }

	  handleCloseEvent(e) {
	    e.preventDefault();
	    this.close();
	  }

	  handleKeyEvent(e) {
	    if (this.opened && e.keyCode === 27) {
	      this.close();
	    }
	  }

	  bindEvents() {
	    const triggers = document.querySelectorAll('[data-pushbar-target]');
	    const closers = document.querySelectorAll('[data-pushbar-close]');

	    triggers.forEach(trigger => trigger.addEventListener('click', e => this.handleOpenEvent(e), false));
	    closers.forEach(closer => closer.addEventListener('click', e => this.handleCloseEvent(e), false));

	    if (this.overlay) {
	      this.overlay.addEventListener('click', e => this.handleCloseEvent(e), false);
	    }
	    document.addEventListener('keyup', e => this.handleKeyEvent(e));
	  }

	  open(pushbarId) {
	    // Current bar is already opened
	    if (String(pushbarId) === this.activeBarId && this.opened) {
	      return;
	    }
	    
	    // Get new pushbar target
	    const pushbar = Pushbar.findElementById(pushbarId);

	    if (!pushbar) return;
	    
	    // Close active bar (if exists)
	    if (this.opened) {
	      this.close();
	    }
	    
	    Pushbar.dispatchOpen(pushbar);
	    pushbar.classList.add('opened');

	    const Root = document.querySelector('html');
	    Root.classList.add('pushbar_locked');
	    Root.setAttribute('pushbar', pushbarId);
	    this.activeBar = pushbar;
	  }

	  close() {
	    const { activeBar } = this;
	    if (!activeBar) return;
	    
	    Pushbar.dispatchClose(activeBar);
	    activeBar.classList.remove('opened');

	    const Root = document.querySelector('html');
	    Root.classList.remove('pushbar_locked');
	    Root.removeAttribute('pushbar');
	    
	    this.activeBar = null;
	  }
};

//バウンス
(function(global){var startY=0;var enabled=false;var supportsPassiveOption=false;try{var opts=Object.defineProperty({},"passive",{get:function(){supportsPassiveOption=true}});window.addEventListener("test",null,opts)}catch(e){}var handleTouchmove=function(evt){var el=evt.target;var zoom=window.innerWidth/window.document.documentElement.clientWidth;if(evt.touches.length>1||zoom!==1){return}while(el!==document.body&&el!==document){var style=window.getComputedStyle(el);if(!style){break}if(el.nodeName==="INPUT"&&el.getAttribute("type")==="range"){return}var scrolling=style.getPropertyValue("-webkit-overflow-scrolling");var overflowY=style.getPropertyValue("overflow-y");var height=parseInt(style.getPropertyValue("height"),10);var isScrollable=scrolling==="touch"&&(overflowY==="auto"||overflowY==="scroll");var canScroll=el.scrollHeight>el.offsetHeight;if(isScrollable&&canScroll){var curY=evt.touches?evt.touches[0].screenY:evt.screenY;var isAtTop=startY<=curY&&el.scrollTop===0;var isAtBottom=startY>=curY&&el.scrollHeight-el.scrollTop===height;if(isAtTop||isAtBottom){evt.preventDefault()}return}el=el.parentNode}evt.preventDefault()};var handleTouchstart=function(evt){startY=evt.touches?evt.touches[0].screenY:evt.screenY};var enable=function(){window.addEventListener("touchstart",handleTouchstart,supportsPassiveOption?{passive:false}:false);window.addEventListener("touchmove",handleTouchmove,supportsPassiveOption?{passive:false}:false);enabled=true};var disable=function(){window.removeEventListener("touchstart",handleTouchstart,false);window.removeEventListener("touchmove",handleTouchmove,false);enabled=false};var isEnabled=function(){return enabled};var testDiv=document.createElement("div");document.documentElement.appendChild(testDiv);testDiv.style.WebkitOverflowScrolling="touch";var scrollSupport="getComputedStyle"in window&&window.getComputedStyle(testDiv)["-webkit-overflow-scrolling"]==="touch";document.documentElement.removeChild(testDiv);if(scrollSupport){enable()}var iNoBounce={enable:enable,disable:disable,isEnabled:isEnabled};if(typeof module!=="undefined"&&module.exports){module.exports=iNoBounce}if(typeof global.define==="function"){(function(define){define("iNoBounce",[],function(){return iNoBounce})})(global.define)}else{global.iNoBounce=iNoBounce}})(this);