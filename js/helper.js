
function ajaxGet(url,data,callback) {
	return $.ajax({
		url: url,
		data: data,
		dataType: 'json',
		success: callback,
		error: function(jqXHR, textStatus, errorThrown) {
			alert("Ajax error: " + textStatus);
		}
	});
}

function debug(data) {
	alert(JSON.stringify(data));
}

function keys(hash) {
	return Object.keys(hash);
}
function sortkeys(hash) {
	var res = Object.keys(hash);
	res.sort();
	return res;
}
function nsortkeys(hash) {
	var res = Object.keys(hash);
	res.sort(function(a,b) { return parseInt(a)-parseInt(b) });
	return res;
}
function isFunction(functionToCheck) {
	var getType = {};
	return functionToCheck && getType.toString.call(functionToCheck) === '[object Function]';
}

function addDays(date,days) {
    var dat = new Date(date.valueOf());
    dat.setUTCDate(dat.getUTCDate() + days);
    return dat;
}

function getDates(startDate, stopDate) {
    var dateArray = new Array();
    var currentDate = startDate;
    while (currentDate <= stopDate) {
        dateArray.push( new Date (currentDate) )
        currentDate = addDays(currentDate,1);
    }
    return dateArray;
}

function rgbhex(r,g,b) {
	return ("00" + parseInt(r).toString(16)).substr(-2) + 
	       ("00" + parseInt(g).toString(16)).substr(-2) +
	       ("00" + parseInt(b).toString(16)).substr(-2);
}

function sq2lnglat(s) {
	s = s.toUpperCase();
	var lng = (s.charCodeAt(0)-"A".charCodeAt(0)) * 20 - 180;
	var lat = (s.charCodeAt(1)-"A".charCodeAt(0)) * 10 - 90;
	lng    += (s.charCodeAt(2)-"0".charCodeAt(0)) * 2;
	lat    += (s.charCodeAt(3)-"0".charCodeAt(0)) * 1;
	if(s.length == 6) {
		lng    += (s.charCodeAt(4)-"A".charCodeAt(0)) * 5.0 / 60;
		lat    += (s.charCodeAt(5)-"A".charCodeAt(0)) * 2.5 / 60;
	}
	return { lng: lng, lat: lat };
}

