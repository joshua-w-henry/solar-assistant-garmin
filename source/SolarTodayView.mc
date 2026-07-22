using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Application.Storage;

class SolarTodayView extends WatchUi.View {

    var dailyData;

    function initialize() {
        View.initialize();
        dailyData = new SolarDailyData();
    }

    function onLayout(dc) {
    }

    function onShow() {
        loadDailySnapshot();
    }

    function loadDailySnapshot() {
        dailyData = new SolarDailyData();

        var savedValue;

        savedValue = Storage.getValue("todayLoadKwh");
        if (savedValue != null) {
            dailyData.loadKwh = savedValue;
            dailyData.hasCachedData = true;
        }

        savedValue = Storage.getValue("todaySolarKwh");
        if (savedValue != null) {
            dailyData.solarKwh = savedValue;
            dailyData.hasCachedData = true;
        }

        savedValue = Storage.getValue(
            "todayBatteryChargedKwh"
        );
        if (savedValue != null) {
            dailyData.batteryChargedKwh =
                savedValue;
            dailyData.hasCachedData = true;
        }

        savedValue = Storage.getValue(
            "todayBatteryDischargedKwh"
        );
        if (savedValue != null) {
            dailyData.batteryDischargedKwh =
                savedValue;
            dailyData.hasCachedData = true;
        }

        savedValue = Storage.getValue(
            "todayGridImportedKwh"
        );
        if (savedValue != null) {
            dailyData.gridImportedKwh = savedValue;
            dailyData.hasCachedData = true;
        }

        savedValue = Storage.getValue(
            "todayGridExportedKwh"
        );
        if (savedValue != null) {
            dailyData.gridExportedKwh = savedValue;
            dailyData.hasCachedData = true;
        }

        savedValue = Storage.getValue(
            "todayDateLabel"
        );
        if (savedValue != null) {
            dailyData.dateLabel = savedValue;
        }

        savedValue = Storage.getValue(
            "todayPartialDay"
        );
        if (savedValue != null) {
            dailyData.partialDay = savedValue;
        }
    }

    function onUpdate(dc) {
        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        );

        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();

        dc.drawText(
            width / 2,
            18,
            Graphics.FONT_MEDIUM,
            "TODAY",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        dc.drawText(
            width / 2,
            65,
            Graphics.FONT_XTINY,
            dailyData.dateLabel,
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var y = 102;
        var rowSpacing = 48;

        drawRow(
            dc,
            y,
            "PV PRODUCED",
            formatEnergy(dailyData.solarKwh)
        );

        y += rowSpacing;

        drawRow(
            dc,
            y,
            "LOAD",
            formatEnergy(dailyData.loadKwh)
        );

        y += rowSpacing;

        drawRow(
            dc,
            y,
            "BATTERY CHARGED",
            formatEnergy(
                dailyData.batteryChargedKwh
            )
        );

        y += rowSpacing;

        drawRow(
            dc,
            y,
            "BATTERY DISCHARGED",
            formatEnergy(
                dailyData.batteryDischargedKwh
            )
        );

        y += rowSpacing;

        drawRow(
            dc,
            y,
            "GRID IMPORT",
            formatEnergy(
                dailyData.gridImportedKwh
            )
        );

        y += rowSpacing;

        drawRow(
            dc,
            y,
            "GRID EXPORT",
            formatEnergy(
                dailyData.gridExportedKwh
            )
        );

        dc.drawText(
            width / 2,
            height - 34,
            Graphics.FONT_XTINY,
            getFooterText(),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function getFooterText() {
        if (!dailyData.hasCachedData) {
            return "NO DAILY DATA";
        }

        if (dailyData.partialDay) {
            return "PARTIAL DAY TOTALS";
        }

        return "COMPLETE DAY TOTALS";
    }

    function drawRow(dc, y, label, value) {
        var leftMargin = 30;
        var rightMargin = dc.getWidth() - 30;

        dc.drawText(
            leftMargin,
            y,
            Graphics.FONT_XTINY,
            label,
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.drawText(
            rightMargin,
            y - 3,
            Graphics.FONT_SMALL,
            value,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function formatEnergy(value) {
        if (value == null) {
            return "--";
        }

        return value.format("%.1f") + " kWh";
    }

    function onHide() {
    }
}
