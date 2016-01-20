﻿/**
 * @license Copyright (c) 2003-2014, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

/*
skin.js
=========

In this file we interact with the CKEditor JavaScript API to register the skin
and enable additional skin related features.

The level of complexity of this file depends on the features available in the
skin. There is only one mandatory line of code to be included here, which is
setting CKEDITOR.skin.name. All the rest is optional, but recommended to be
implemented as they make higher quality skins.

For this skin, the following tasks are achieved in this file:

	1. Register the skin.
	2. Register browser specific skin files.
	3. Define the "Chameleon" feature.
	4. Register the skin icons, to have them used on the development version of
	  the skin.
*/

// 1. Register the skin
// ----------------------
// The CKEDITOR.skin.name property must be set to the skin name. This is a
// lower-cased name, which must match the skin folder name as well as the value
// used on config.skin to tell the editor to use the skin.
//
// This is the only mandatory property to be defined in this file.
CKEDITOR.skin.name = 'office2013';

// 2. Register browser specific skin files
// -----------------------------------------
// (http://docs.cksource.com/CKEditor_4.x/Skin_SDK/Browser_Hacks)
//
// To help implementing browser specific "hacks" to the skin files and have it
// easy to maintain, it is possible to have dedicated files for such browsers,
// for both the main skin CSS files: editor.css and dialog.css.
//
// The browser files must be named after the main file names, appended by an
// underscore and the browser name (e.g. editor_ie.css, dialog_ie8.css).
//
// The accepted browser names must match the CKEDITOR.env properties. The most
// common names are: ie, opera, webkit and gecko. Check the documentation for
// the complete list:
// http://docs.ckeditor.com/#!/api/CKEDITOR.env
//
// Internet explorer is an expection and the browser version is also accepted
// (ie7, ie8, ie9, ie10), as well as a special name for IE in Quirks mode (iequirks).
//
// The available browser specific files must be set separately for editor.css
// and dialog.css.
CKEDITOR.skin.ua_editor = '';
CKEDITOR.skin.ua_dialog = '';

// 3. Define the "Chameleon" feature
// -----------------------------------
// (http://docs.cksource.com/CKEditor_4.x/Skin_SDK/Chameleon)
//
// "Chameleon" is a unique feature available in CKEditor. It makes it possible
// to end users to specify which color to use as the basis for the editor UI.
// It is enough to set config.uiColor to any color value and voila, the UI is
// colored.
//
// The only detail here is that the skin itself must be compatible with the
// Chameleon feature. That's because the skin CSS files are the responsible to
// apply colors in the UI and each skin do that in different way and on
// different places.
//
// Implementing the Chameleon feature requires a bit of JavaScript programming.
// The CKEDITOR.skin.chameleon function must be defined. It must return the CSS
// "template" to be used to change the color of a specific CKEditor instance
// available in the page. When a color change is required, this template is
// appended to the page holding the editor, overriding styles defined in the
// skin files.
//
// The "$color" placeholder can be used in the returned string. It'll be
// replaced with the desired color.
CKEDITOR.skin.chameleon = function() {
	return '';
};

// %REMOVE_START%

// 4. Register the skin icons for development purposes only
// ----------------------------------------------------------
// (http://docs.cksource.com/CKEditor_4.x/Skin_SDK/Icons)
//
// Note: As "moono" is the default CKEditor skin, it provides no custom icons,
// thus this code is commented out.
//
// This code is here just to make the skin work fully when using its "source"
// version. Without this, the skin will still work, but its icons will not be
// used (again, on source version only).
//
// This block of code is not necessary on the release version of the skin.
// Because of this it is very important to include it inside the REMOVE_START
// and REMOVE_END comment markers, so the skin builder will properly clean
// things up.
//
// If a required icon is not available here, the plugin defined icon will be
// used instead. This means that a skin is not required to provide all icons.
// Actually, it is not required to provide icons at all.
//
(function() {
		// The available icons. This list must match the file names (without
		// extension) available inside the "icons" folder.
		var icons = ( 'about,anchor-rtl,anchor,autocorrect,bgcolor,bidiltr,bidirtl,blockquote,' +
			'bold,bulletedlist-rtl,bulletedlist,button,checkbox,copy-rtl,copy,' +
			'cut-rtl,cut,docprops-rtl,docprops,find-rtl,find,form,' + //TODO creatediv,flash,
			'hiddenfield,horizontalrule,icons,iframe,image,imagebutton,indent-rtl,' +
			'indent,italic,justifyblock,justifycenter,justifyleft,justifyright,' +
			'language,link,mathjax,maximize,newpage-rtl,newpage,numberedlist-rtl,numberedlist,' +
			'outdent-rtl,outdent,pagebreak-rtl,pagebreak,paste-rtl,paste,' +
			'pastefromword-rtl,pastefromword,pastetext-rtl,pastetext,preview-rtl,' +
			'preview,print,radio,redo-rtl,redo,removeformat,replace,save,scayt,' +
			'select-rtl,select,selectall,showblocks-rtl,showblocks,smiley,' +
			'sourcedialog-rtl,sourcedialog,source-rtl,source,specialchar,spellchecker,strike,subscript,' +
			'superscript,table,templates-rtl,templates,textarea-rtl,textarea,' +
			'textcolor,textfield-rtl,textfield,uicolor,underline,undo-rtl,undo,unlink' ).split( ',' );

		var iconsFolder = CKEDITOR.getUrl( CKEDITOR.skin.path() + 'icons/' + ( CKEDITOR.env.hidpi ? 'hidpi/' : '' ) );

		for ( var i = 0; i < icons.length; i++ ) {
			CKEDITOR.skin.addIcon( icons[ i ], iconsFolder + icons[ i ] + '.png' );
		}
})();

// %REMOVE_END%
