Rumali.buildCharts = (function () {

	var loadReportChart = function(){
		if (gon.is_autogenerated){
			Rumali.autoCharts.loadReportChart();
		}
	}

	return{
		loadReportChart:loadReportChart
	}
}());
