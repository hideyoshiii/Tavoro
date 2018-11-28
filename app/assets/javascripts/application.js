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

//= require turbolinks
//= require_tree .
//= require serviceworker-companion

//lazyload.js
!function(t,e){"object"==typeof exports?module.exports=e(t):"function"==typeof define&&define.amd?define([],e(t)):t.LazyLoad=e(t)}("undefined"!=typeof global?global:this.window||this.global,function(t){"use strict";function e(t,e){this.settings=r(s,e||{}),this.images=t||document.querySelectorAll(this.settings.selector),this.observer=null,this.init()}const s={src:"data-src",srcset:"data-srcset",selector:".lazyload"},r=function(){let t={},e=!1,s=0,o=arguments.length;"[object Boolean]"===Object.prototype.toString.call(arguments[0])&&(e=arguments[0],s++);for(;s<o;s++)!function(s){for(let o in s)Object.prototype.hasOwnProperty.call(s,o)&&(e&&"[object Object]"===Object.prototype.toString.call(s[o])?t[o]=r(!0,t[o],s[o]):t[o]=s[o])}(arguments[s]);return t};if(e.prototype={init:function(){if(!t.IntersectionObserver)return void this.loadImages();let e=this,s={root:null,rootMargin:"0px",threshold:[0]};this.observer=new IntersectionObserver(function(t){t.forEach(function(t){if(t.intersectionRatio>0){e.observer.unobserve(t.target);let s=t.target.getAttribute(e.settings.src),r=t.target.getAttribute(e.settings.srcset);"img"===t.target.tagName.toLowerCase()?(s&&(t.target.src=s),r&&(t.target.srcset=r)):t.target.style.backgroundImage="url("+s+")"}})},s),this.images.forEach(function(t){e.observer.observe(t)})},loadAndDestroy:function(){this.settings&&(this.loadImages(),this.destroy())},loadImages:function(){if(!this.settings)return;let t=this;this.images.forEach(function(e){let s=e.getAttribute(t.settings.src),r=e.getAttribute(t.settings.srcset);"img"===e.tagName.toLowerCase()?(s&&(e.src=s),r&&(e.srcset=r)):e.style.backgroundImage="url("+s+")"})},destroy:function(){this.settings&&(this.observer.disconnect(),this.settings=null)}},t.lazyload=function(t,s){return new e(t,s)},t.jQuery){const s=t.jQuery;s.fn.lazyload=function(t){return t=t||{},t.attribute=t.attribute||"data-src",new e(s.makeArray(this),t),this}}return e});

//pushbar.js
class Pushbar {
	  constructor(config = { overlay: true }) {
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