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


//ローディング画面
!function(i){function s(){var s=i(window).width(),c=i(window).height(),d=i(".fl").outerWidth(),e=i(".fl").outerHeight();i(".fl").css({position:"absolute",left:s/2-d/2,top:c/2-e/2})}i.fn.fakeLoader=function(c){var d=i.extend({timeToHide:1200,pos:"fixed",top:"0px",left:"0px",width:"100%",height:"100%",zIndex:"999",bgColor:"#2ecc71",spinner:"spinner7",imagePath:""},c),e='<div class="fl spinner1"><div class="double-bounce1"></div><div class="double-bounce2"></div></div>',l='<div class="fl spinner2"><div class="spinner-container container1"><div class="circle1"></div><div class="circle2"></div><div class="circle3"></div><div class="circle4"></div></div><div class="spinner-container container2"><div class="circle1"></div><div class="circle2"></div><div class="circle3"></div><div class="circle4"></div></div><div class="spinner-container container3"><div class="circle1"></div><div class="circle2"></div><div class="circle3"></div><div class="circle4"></div></div></div>',n='<div class="fl spinner3"><div class="dot1"></div><div class="dot2"></div></div>',v='<div class="fl spinner4"></div>',a='<div class="fl spinner5"><div class="cube1"></div><div class="cube2"></div></div>',r='<div class="fl spinner6"><div class="rect1"></div><div class="rect2"></div><div class="rect3"></div><div class="rect4"></div><div class="rect5"></div></div>',t='<div class="fl spinner7"><div class="circ1"></div><div class="circ2"></div><div class="circ3"></div><div class="circ4"></div></div>',o=i(this),h={position:d.pos,width:d.width,height:d.height,top:d.top,left:d.left};return o.css(h),o.each(function(){var i=d.spinner;switch(i){case"spinner1":o.html(e);break;case"spinner2":o.html(l);break;case"spinner3":o.html(n);break;case"spinner4":o.html(v);break;case"spinner5":o.html(a);break;case"spinner6":o.html(r);break;case"spinner7":o.html(t);break;default:o.html(e)}""!=d.imagePath&&o.html('<div class="fl"><img src="'+d.imagePath+'"></div>'),s()}),setTimeout(function(){i(o).fadeOut()},d.timeToHide),this.css({backgroundColor:d.bgColor,zIndex:d.zIndex})},i(window).load(function(){s(),i(window).resize(function(){s()})})}(jQuery);


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


