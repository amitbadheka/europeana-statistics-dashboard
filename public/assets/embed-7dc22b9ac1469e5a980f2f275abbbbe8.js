window.onload=function(){if("Grid"===chart_name)if("csv"===gon.dataformat){var n={};n.dsv=function(n,r){function e(n,e,o){arguments.length<3&&(o=e,e=null);var i=d3_xhr(n,r,null==e?t:a(e),o);return i.row=function(n){return arguments.length?i.response(null==(e=n)?t:a(n)):e},i}function t(n){return e.parse(n.responseText)}function a(n){return function(r){return e.parse(r.responseText,n)}}function o(r){return r.map(i).join(n)}function i(n){return u.test(n)?'"'+n.replace(/\"/g,'""')+'"':n}var u=new RegExp('["'+n+"\n]"),c=n.charCodeAt(0);return e.parse=function(n,r){var t;return e.parseRows(n,function(n,e){if(t)return t(n,e-1);var a=new Function("d","return {"+n.map(function(n,r){return JSON.stringify(n)+": d["+r+"]"}).join(",")+"}");t=r?function(n,e){return r(a(n),e)}:a})},e.parseRows=function(n,r){function e(){if(f>=s)return i;if(a)return a=!1,o;var r=f;if(34===n.charCodeAt(r)){for(var e=r;e++<s;)if(34===n.charCodeAt(e)){if(34!==n.charCodeAt(e+1))break;++e}f=e+2;var t=n.charCodeAt(e+1);return 13===t?(a=!0,10===n.charCodeAt(e+2)&&++f):10===t&&(a=!0),n.slice(r+1,e).replace(/""/g,'"')}for(;s>f;){var t=n.charCodeAt(f++),u=1;if(10===t)a=!0;else if(13===t)a=!0,10===n.charCodeAt(f)&&(++f,++u);else if(t!==c)continue;return n.slice(r,f-u)}return n.slice(r)}for(var t,a,o={},i={},u=[],s=n.length,f=0,l=0;(t=e())!==i;){for(var d=[];t!==o&&t!==i;)d.push(t),t=e();r&&null==(d=r(d,l++))||u.push(d)}return u},e.format=function(r){if(Array.isArray(r[0]))return e.formatRows(r);var t=new d3_Set,a=[];return r.forEach(function(n){for(var r in n)t.has(r)||a.push(t.add(r))}),[a.map(i).join(n)].concat(r.map(function(r){return a.map(function(n){return i(r[n])}).join(n)})).join("\n")},e.formatRows=function(n){return n.map(o).join("\n")},e},n.csv=n.dsv(",","text/csv"),config_data.data=n.csv.parse(gon.data_file),$.ajax({url:rumi_api_endpoint+gon.rumiparams+"column/all_columns?data_types=true&original_names=true&token="+gon.token,type:"GET",data:obj,dataType:"json",success:function(n){for(var r=Object.keys(config_data.data[0]),e=r.length,t=n.columns.original_column_names,a=0;e>a;a++){var o=t[r[a]];o&&(r[a]=o)}config_data.colHeaders=r,$(selector)[initializer](config_data)}})}else{var r=gon.data_file;"json"==gon.dataformat&&(r=JSON.parse(gon.data_file)),document.getElementById("chart_container_display").innerText=JSON.stringify(r,null,"	")}else{obj.data=gon.data_file,obj.selector=selector;var e=new initializer(obj);e.execute()}};