/*

==============================================================
XHTML/CSS/DHTML Semantically correct drop down menu
==============================================================
Original author: Sam Hampton-Smith
Site: http://www.hampton-smith.com

Description:	This script takes a nested set of <ul>s
				and turns it into a fully functional
				DHTML menu. All that is required is
				the correct use of class names, and
				the application of some CSS.

Use:			Please leave this information at the
				top of this file, and it would be nice
				if you credited me/dropped me an email
				to let me know you have used the menu.
				sam AT hampton-smith.com
Credits: 		Inspiration/Code borrowed from
				Dave Lindquist (http://www.gazingus.org)
				Menu hide functionality was aided by some
				code I found on http://www.jessett.com/

==============================================================
Custom uitbreidingingen
© 2006 Bas & Ferry
http://www.bas-ferry.nl/
in opdracht van
Strik Design
http://www.strikdesign.nl/
==============================================================
*/



	// Hoofdmenu actief laten na mouseOut?
	var keepMainMenuActive = true;

	// Submenu automatisch verbergen bij mouseOut op hoofdmenu?
	var hideSubmenu = true;

	// Submenu verticaal statisch positioneren?
	var staticYPosition = false;

	// Submenu horizontaal statisch positioneren?
	var staticXPosition = false;

	// Submenu verticale positie corrigeren?
	var correctionYPosition = -6;

	// Submenu horizontale positie corrigeren?
	var correctionXPosition = -5;

	// 'sub'-class toewijzen aan opties met onderliggende opties? (let op traag)?
	var useSubClassForOptionWithChildren = true;

	// Bij het laden van een pagina automatisch het bijbehorende mainmenu actief maken?
	var activateMainMenuAfterLoad = false;

	// Bij het laden van een nieuwe pagina automatisch het bijbehorende submenu uitklappen (let op traag)?
	var activateSubMenuAfterLoad = false;

	// Bij het laden van de beginpagina automatisch het eerste submenu uitklappen?
	var activateFirstMenuAfterLoad = false;

/* Eind custom uitbreidingingen*/


	var currentMenu = null;
	var mytimer = null;
	var ulTeller = 0;
	var timerOn = false;
	var opera = window.opera ? true : false;


	if (!document.getElementById)
		document.getElementById = function() { return null; }



	function initialiseMenu(menu, starter, root) {
		menu.id = 'ul_'+ulTeller++;
		var leftstarter = false;

		if (menu == null || starter == null) return;
			currentMenu = menu;

		if (useSubClassForOptionWithChildren) addClassesToSubmenuOptions(starter, root);


		starter.onmouseover = function() {
			if (currentMenu) {
				if (this.parentNode.parentNode!=currentMenu) {
					currentMenu.style.visibility = "hidden";
				}
				if (this.parentNode.parentNode==root) {
					tempCurrentMenu = currentMenu
					while (tempCurrentMenu.parentNode.parentNode!=root) {
						tempCurrentMenu.parentNode.parentNode.style.visibility = "hidden";
						tempCurrentMenu = tempCurrentMenu.parentNode.parentNode;
					}
				}
				currentMenu = null;
				this.showMenu();

	     }
			mouseOutStarters(starter);
	   	}

		menu.onmouseover = function() {
			if (currentMenu) {
				currentMenu = null;
				this.showMenu();
	   	}
		}

		starter.showMenu = function() {
			if (!opera) {
				if (this.parentNode.parentNode==root) {
					if (!staticXPosition) {
						menu.style.left = this.offsetLeft + correctionXPosition + "px";
					}
					if (!staticYPosition) {
						menu.style.top = this.offsetTop + correctionYPosition + this.offsetHeight + "px";
					}
				}
				else {
				 	menu.style.left = this.offsetLeft + this.offsetWidth + "px";
				 	menu.style.top = this.offsetTop + "px";
				}
			}
			else {
				if (this.parentNode.parentNode==root) {
					if (!staticXPosition) {
						menu.style.left = this.offsetLeft + "px";
					}
					if (!staticYPosition) {
						menu.style.top = this.offsetHeight + "px";
					}
				}
				else {
				 	menu.style.left = this.offsetWidth + "px";
				 	menu.style.top = this.offsetTop + "px"; //menu.style.top - menu.style.offsetHeight + "px";
				}

			}
			menu.style.visibility = "visible";
			currentMenu = menu;
		}

		starter.onfocus	 = function() {
			starter.onmouseover();
		}

		menu.onfocus	 = function() {
//			currentMenu.style.visibility="hidden";
		}

		menu.showMenu = function() {
			menu.style.visibility = "visible";
			currentMenu = menu;
			stopTime();
		}

		menu.hideMenu = function()  {
			if (!timerOn) {
				mytimer = setInterval("killMenu('" + this.id + "', '" + root.id + "');", 1000);
				timerOn = true;
				for (var x=0;x<menu.childNodes.length;x++) {
					if (menu.childNodes[x].nodeName=="LI") {
						if (menu.childNodes[x].getElementsByTagName("UL").length>0) {
							menuItem = menu.childNodes[x].getElementsByTagName("UL").item(0);
							menuItem.style.visibility = "hidden";
						}
					}
				}
			}
		}

		menu.onmouseout = function(event) {
			this.hideMenu();
		}

		starter.onmouseout = function() {
			if (hideSubmenu) {
				for (var x=0;x<menu.childNodes.length;x++) {
					if (menu.childNodes[x].nodeName=="LI") {
						if (menu.childNodes[x].getElementsByTagName("UL").length>0) {
							menuItem = menu.childNodes[x].getElementsByTagName("UL").item(0);
							menuItem.style.visibility = "hidden";
						}
					}
				}
				menu.style.visibility = "hidden";
			}
			if (!keepMainMenuActive) {
				appendToClassName(starter,'starter');
			}
		}
}

	function killMenu(menu, root) {
		var menu = document.getElementById(menu);
		var root = document.getElementById(root);

		if (!hideSubmenu && menu.parentNode.parentNode == root) return;

		menu.style.visibility = "hidden";
		for (var x=0;x<menu.childNodes.length;x++) {
			if (menu.childNodes[x].nodeName=="LI") {
				if (menu.childNodes[x].getElementsByTagName("UL").length>0) {
					menuItem = menu.childNodes[x].getElementsByTagName("UL").item(0);
					menuItem.style.visibility = "hidden";
				}
			}
		}

	if (hideSubmenu) {
		while (menu.parentNode.parentNode!=root) {
			menu.parentNode.parentNode.style.visibility = "hidden";
			menu = menu.parentNode.parentNode;
		}
	} else if (menu.parentNode.parentNode!=root) {
		while (menu.parentNode.parentNode.parentNode.parentNode!=root) {
			menu.parentNode.parentNode.style.visibility = "hidden";
			menu = menu.parentNode.parentNode;
		}
	}
	stopTime();
	}
	function stopTime() {
		if (mytimer) {
		 	 clearInterval(mytimer);
			 mytimer = null;
			 timerOn = false;
		}
	}



	function initMenu() {
		var root = document.getElementById("menuList");

		getMenus(root, root);
		if (activateFirstMenuAfterLoad && !activeSubmenu()) {
			activateHoofdmenu(root);
		}
		if (activateMainMenuAfterLoad || activateSubMenuAfterLoad) {
			addActivateCodes(root);
			activateSubmenu(root);
		}
	}


function getMenus(elementItem, root) {
	var selectedItem;
	var menuStarter;
	var menuItem;
	for (var x=0;x<elementItem.childNodes.length;x++) {
		if (elementItem.childNodes[x].nodeName=="LI") {
			if (elementItem.childNodes[x].getElementsByTagName("UL").length>0) {
				menuStarter = elementItem.childNodes[x].getElementsByTagName("A").item(0);
				menuItem = elementItem.childNodes[x].getElementsByTagName("UL").item(0);
				getMenus(menuItem, root);
				initialiseMenu(menuItem, menuStarter, root);
			}
		}
	}
	//return true;
}

function activeSubmenu() {
	var submenuId = getQueryVariable('menu');
	var menu = document.getElementById(submenuId);
	if (menu == null) return false;
	return true;
}

function activateSubmenu(root) {
	var submenuId = getQueryVariable('menu');
	var menu = document.getElementById(submenuId);
	if (menu == null) return false;


	menu.showMenu();
	var starter = menu.parentNode.getElementsByTagName("A").item(0);
	mouseOutStarters(starter);
	appendToClassName(starter.parentNode,'active');
	if (!activateSubMenuAfterLoad) starter.onmouseout.call(); // direct dichtklappen
	return true;
}


function activateHoofdmenu(root) {
	for (var x=0;x<root.childNodes.length;x++) {
		if (root.childNodes[x].nodeName=="LI") { //starter!
			var menu = root.childNodes[x].getElementsByTagName("UL").item(0);
			break;
		}
	}
	if (menu == null) return false;
	menu.showMenu();
	mouseOutStarters(menu.parentNode.getElementsByTagName("A").item(0));
	return true;
}

function addActivateCodes(root) {
	var starterId;
	var links;
	for (var x=0;x<root.childNodes.length;x++) {
		if (root.childNodes[x].nodeName=="LI") { //starter!
			starterId = root.childNodes[x].getElementsByTagName("UL").item(0).id;
			links     = root.childNodes[x].getElementsByTagName("A");

			addStarterIdToLinks(starterId, links);
		}
	}
}
function addStarterIdToLinks(starterId, links) {
	var koppelteken;
	var anker;
	var ankerPos;
	var oldSubMenu = "menu="+getQueryVariable('menu');


	for (var x=0;x<links.length;x++) {
		if (links[x].href.length > 0) {
			// eerst de menuvar er weer afslopen
			links[x].href = links[x].href.replace('&'+oldSubMenu, '');
			links[x].href = links[x].href.replace('?'+oldSubMenu, '');

			koppelteken = getKoppelTeken(links[x]);

			ankerPos    = links[x].href.indexOf("#");
			if (ankerPos > -1) {
				anker = links[x].href.substring(ankerPos, links[x].href.length);
				links[x].href = links[x].href.substring(0,ankerPos);
			} else {
				anker = '';
			}
			links[x].href += koppelteken+'menu='+starterId+anker;
		}
	}
}

function getKoppelTeken(link) {
	if (link.href.indexOf("?") > -1) {
		return "&";
	} else {
		return "?";
	}
}


function mouseOutStarters(starter) {
	var root = document.getElementById("menuList");
	if (starter.parentNode.parentNode != root) return;

	var menuStarter;
	var t;
	t = 0;
	for (var x=0;x<	root.childNodes.length;x++) {
		t++;
		if (root.childNodes[x].nodeName=="LI") {
			if (root.childNodes[x].getElementsByTagName("UL").length>0) {
				menuStarter = root.childNodes[x].getElementsByTagName("A").item(0);
				if (starter == menuStarter) {
					appendToClassName(root.childNodes[x],'hover'); //li
				} else {
					removeFromClassName(root.childNodes[x],'hover');
				}
			}
		}
	}
}


function addClassesToSubmenuOptions(starter, root) {
	if (starter.parentNode.parentNode.parentNode.parentNode ==root) { //submenuopties
		addClassToOption(starter);
	}
}
function getPos(el) {
	elHtml = el.innerHTML;
	var parent = el.parentNode;
	for (var x=0;x<parent.childNodes.length;x++) {
		if (parent.childNodes[x].innerHTML === elHtml)	return x+1;
	}
	return 0;
}

function addClassToOption(a) {
	var li  = a.parentNode;
	var as  = li.getElementsByTagName("A");
	var pos = getPos(li);

	clsName = '';
	if (pos == 1) clsName= 'first';
	if (pos == li.parentNode.childNodes.length) clsName= 'last';
	appendToClassName(a,clsName);

	if (as.length >1) {
		for (var x=1;x<as.length;x++) {
			addClassToOption(as[x]);
		}
		appendToClassName(a,'sub');
	}
}

function getQueryVariable(variable) {
  var query = window.location.search.substring(1);
	var vars = query.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    if (pair[0] == variable) {
      return pair[1];
    }
  }
  return false;
}


function appendToClassName(elem, strClassName)
{
	if (!elem) return;
	var classNames = elem.className.split(' ');
	classNames[classNames.length] = strClassName;
	elem.className = classNames.join(' ');
}

function removeFromClassName(elem, strClassName)
{
	if (!elem) return;
	var classNames = elem.className.split(' ');
	var newClassNames = new Array();
	for (var i in classNames)
	{
		var className = classNames[i];
		if (className!=strClassName) newClassNames[newClassNames.length] = className;
	}
	elem.className = newClassNames.join(' ');
}


if (document.addEventListener) {
	document.addEventListener("DOMContentLoaded", initMenu, false);
} else {
	  document.onreadystatechange = function() {
  	if (this.readyState == "complete") {
			initMenu();
  	}
 	}
}