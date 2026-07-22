class SolarDailyData {

    var loadKwh;
    var solarKwh;
    var batteryChargedKwh;
    var batteryDischargedKwh;
    var gridImportedKwh;
    var gridExportedKwh;
    var dateLabel;
    var hasCachedData;
    var partialDay;

    function initialize() {
        loadKwh = null;
        solarKwh = null;
        batteryChargedKwh = null;
        batteryDischargedKwh = null;
        gridImportedKwh = null;
        gridExportedKwh = null;

        dateLabel = "NO DAILY DATA";
        hasCachedData = false;
        partialDay = true;
    }
}
