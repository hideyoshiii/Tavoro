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

//遅延ロード
!function(t,e){"object"==typeof exports?module.exports=e(t):"function"==typeof define&&define.amd?define([],e(t)):t.LazyLoad=e(t)}("undefined"!=typeof global?global:this.window||this.global,function(t){"use strict";function e(t,e){this.settings=r(s,e||{}),this.images=t||document.querySelectorAll(this.settings.selector),this.observer=null,this.init()}const s={src:"data-src",srcset:"data-srcset",selector:".lazyload"},r=function(){let t={},e=!1,s=0,o=arguments.length;"[object Boolean]"===Object.prototype.toString.call(arguments[0])&&(e=arguments[0],s++);for(;s<o;s++)!function(s){for(let o in s)Object.prototype.hasOwnProperty.call(s,o)&&(e&&"[object Object]"===Object.prototype.toString.call(s[o])?t[o]=r(!0,t[o],s[o]):t[o]=s[o])}(arguments[s]);return t};if(e.prototype={init:function(){if(!t.IntersectionObserver)return void this.loadImages();let e=this,s={root:null,rootMargin:"0px",threshold:[0]};this.observer=new IntersectionObserver(function(t){t.forEach(function(t){if(t.intersectionRatio>0){e.observer.unobserve(t.target);let s=t.target.getAttribute(e.settings.src),r=t.target.getAttribute(e.settings.srcset);"img"===t.target.tagName.toLowerCase()?(s&&(t.target.src=s),r&&(t.target.srcset=r)):t.target.style.backgroundImage="url("+s+")"}})},s),this.images.forEach(function(t){e.observer.observe(t)})},loadAndDestroy:function(){this.settings&&(this.loadImages(),this.destroy())},loadImages:function(){if(!this.settings)return;let t=this;this.images.forEach(function(e){let s=e.getAttribute(t.settings.src),r=e.getAttribute(t.settings.srcset);"img"===e.tagName.toLowerCase()?(s&&(e.src=s),r&&(e.srcset=r)):e.style.backgroundImage="url("+s+")"})},destroy:function(){this.settings&&(this.observer.disconnect(),this.settings=null)}},t.lazyload=function(t,s){return new e(t,s)},t.jQuery){const s=t.jQuery;s.fn.lazyload=function(t){return t=t||{},t.attribute=t.attribute||"data-src",new e(s.makeArray(this),t),this}}return e});
