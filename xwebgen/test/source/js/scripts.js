
function enlargeTextarea(tId) {
	var txtarea = document.getElementById(tId);
	txtarea.rows += 15;
	var reducebutton = document.getElementById('REDUCE_' + tId);
	reducebutton.style.display = 'inline';
}

function reduceTextarea(tId) {
	var txtarea = document.getElementById(tId);
	var txtnewsize = txtarea.rows - 15;
	if (txtnewsize <= 10) {
	    txtNewSize = 10;
	    var reducebutton = document.getElementById('REDUCE_' + tId);
	    reducebutton.style.display = 'none';
	}
	txtarea.rows = txtnewsize;
}
