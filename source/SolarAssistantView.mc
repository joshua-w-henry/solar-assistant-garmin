using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.System;
using Toybox.Lang;
using Toybox.PersistedContent;
using Toybox.Timer;
using Toybox.Application.Storage;
using Toybox.Time;
using Toybox.Time.Gregorian;

class SolarAssistantView extends WatchUi.View {

    const REFRESH_INTERVAL_MS = 30000;
    const STATUS_INTERVAL_MS = 1000;
    const STALE_AFTER_SECONDS = 120;

    var solarData;

    var refreshTimer;
    var statusTimer;
    var isRefreshing;

    var hasData;
    var lastUpdatedEpoch;
    var lastRequestFailed;
    var sourceConnected;

    function initialize() {
        View.initialize();

        solarData = new SolarData();

        refreshTimer = new Timer.Timer();
        statusTimer = new Timer.Timer();

        isRefreshing = false;
        hasData = false;
        lastUpdatedEpoch = null;
        lastRequestFailed = false;
        sourceConnected = true;

        loadSnapshot();
    }

    function onLayout(dc) {
    }

    function onShow() {
        beginLiveRefresh();

        refreshTimer.start(
            method(:onRefreshTimer),
            REFRESH_INTERVAL_MS,
            true
        );

        statusTimer.start(
            method(:onStatusTimer),
            STATUS_INTERVAL_MS,
            true
        );
    }

    function onRefreshTimer() {
        if (!isRefreshing) {
            beginLiveRefresh();
        }
    }

    function onStatusTimer() {
        WatchUi.requestUpdate();
    }

    function beginLiveRefresh() {
        if (isRefreshing) {
            return;
        }

        isRefreshing = true;
        WatchUi.requestUpdate();

        var options = {
            :method =>
                Communications.HTTP_REQUEST_METHOD_GET,

            :headers => {
                "Authorization" =>
                    "Bearer " + SolarConfig.API_TOKEN,

                "Accept" => "application/json"
            },

            :responseType =>
                Communications
                    .HTTP_RESPONSE_CONTENT_TYPE_JSON
        };

        System.println(
            "Requesting solar summary"
        );

        Communications.makeWebRequest(
            SolarConfig.API_URL,
            null,
            options,
            method(:onSummaryReceive)
        );
    }

    function onSummaryReceive(
        responseCode as Lang.Number,
        data as Lang.Dictionary
            or Lang.String
            or PersistedContent.Iterator
            or Null
    ) as Void {

        System.println(
            "Solar summary response code: " +
            responseCode
        );

        isRefreshing = false;

        if (
            responseCode != 200 ||
            !(data instanceof Lang.Dictionary)
        ) {
            lastRequestFailed = true;
            WatchUi.requestUpdate();
            return;
        }

        var live = data.get("live");
        var today = data.get("today");

        if (
            !(live instanceof Lang.Dictionary) ||
            !(today instanceof Lang.Dictionary)
        ) {
            lastRequestFailed = true;
            WatchUi.requestUpdate();
            return;
        }

        solarData.pvWatts = readNumber(
            live,
            "pv_w",
            solarData.pvWatts
        );

        solarData.loadWatts = readNumber(
            live,
            "load_w",
            solarData.loadWatts
        );

        solarData.batteryVoltage = readNumber(
            live,
            "battery_v",
            solarData.batteryVoltage
        );

        solarData.batteryWatts = readNumber(
            live,
            "battery_w",
            solarData.batteryWatts
        );

        solarData.gridWatts = readNumber(
            live,
            "grid_w",
            solarData.gridWatts
        );

        sourceConnected = readBoolean(
            data,
            "mqtt_connected",
            false
        );

        var updatedText = readString(
            data,
            "updated_at",
            null
        );

        var parsedEpoch = parseIsoEpoch(
            updatedText
        );

        if (parsedEpoch == null) {
            parsedEpoch = Time.now().value();
        }

        lastUpdatedEpoch = parsedEpoch;
        lastRequestFailed = false;
        hasData = true;

        saveSnapshot(data, today);

        if (sourceConnected) {
            SolarComplications.publishValues(
                solarData.loadWatts,
                solarData.pvWatts,
                readNumber(today, "pv_kwh", 0.0),
                solarData.batteryVoltage
            );
        } else {
            SolarComplications.publishUnavailable();
        }

        WatchUi.requestUpdate();
    }

    function saveSnapshot(summary, today) {
        Storage.setValue(
            "pvWatts",
            solarData.pvWatts
        );

        Storage.setValue(
            "loadWatts",
            solarData.loadWatts
        );

        Storage.setValue(
            "batteryVoltage",
            solarData.batteryVoltage
        );

        Storage.setValue(
            "batteryWatts",
            solarData.batteryWatts
        );

        Storage.setValue(
            "gridWatts",
            solarData.gridWatts
        );

        Storage.setValue(
            "updatedEpoch",
            lastUpdatedEpoch
        );

        Storage.setValue(
            "sourceConnected",
            sourceConnected
        );

        Storage.setValue(
            "todaySolarKwh",
            readNumber(today, "pv_kwh", 0.0)
        );

        Storage.setValue(
            "todayLoadKwh",
            readNumber(today, "load_kwh", 0.0)
        );

        Storage.setValue(
            "todayBatteryChargedKwh",
            readNumber(
                today,
                "battery_in_kwh",
                0.0
            )
        );

        Storage.setValue(
            "todayBatteryDischargedKwh",
            readNumber(
                today,
                "battery_out_kwh",
                0.0
            )
        );

        Storage.setValue(
            "todayGridImportedKwh",
            readNumber(
                today,
                "grid_in_kwh",
                0.0
            )
        );

        Storage.setValue(
            "todayGridExportedKwh",
            readNumber(
                today,
                "grid_out_kwh",
                0.0
            )
        );

        Storage.setValue(
            "todayPartialDay",
            readBoolean(
                summary,
                "partial_day",
                true
            )
        );

        Storage.setValue(
            "todayDateLabel",
            readString(
                summary,
                "date",
                "TODAY"
            )
        );
    }

    function loadSnapshot() {
        var savedValue;

        savedValue = Storage.getValue("pvWatts");
        if (savedValue != null) {
            solarData.pvWatts = savedValue;
        }

        savedValue = Storage.getValue("loadWatts");
        if (savedValue != null) {
            solarData.loadWatts = savedValue;
        }

        savedValue = Storage.getValue(
            "batteryVoltage"
        );
        if (savedValue != null) {
            solarData.batteryVoltage = savedValue;
        }

        savedValue = Storage.getValue(
            "batteryWatts"
        );
        if (savedValue != null) {
            solarData.batteryWatts = savedValue;
        }

        savedValue = Storage.getValue("gridWatts");
        if (savedValue != null) {
            solarData.gridWatts = savedValue;
        }

        savedValue = Storage.getValue(
            "updatedEpoch"
        );
        if (savedValue != null) {
            lastUpdatedEpoch = savedValue;
            hasData = true;
        }

        savedValue = Storage.getValue(
            "sourceConnected"
        );
        if (savedValue != null) {
            sourceConnected = savedValue;
        }
    }

    function readNumber(dictionary, key, fallback) {
        var value = dictionary.get(key);

        if (value instanceof Lang.Number) {
            return value.toFloat();
        }

        if (value instanceof Lang.Float) {
            return value;
        }

        if (value instanceof Lang.Long) {
            return value.toFloat();
        }

        if (value instanceof Lang.Double) {
            return value.toFloat();
        }

        return fallback;
    }

    function readBoolean(dictionary, key, fallback) {
        var value = dictionary.get(key);

        if (value instanceof Lang.Boolean) {
            return value;
        }

        return fallback;
    }

    function readString(dictionary, key, fallback) {
        var value = dictionary.get(key);

        if (value instanceof Lang.String) {
            return value;
        }

        return fallback;
    }

    function parseIsoEpoch(text) {
        if (
            !(text instanceof Lang.String) ||
            text.length() < 19
        ) {
            return null;
        }

        try {
            var year = text.substring(0, 4).toNumber();
            var month = text.substring(5, 7).toNumber();
            var day = text.substring(8, 10).toNumber();
            var hour = text.substring(11, 13).toNumber();
            var minute = text.substring(14, 16).toNumber();
            var second = text.substring(17, 19).toNumber();

            var moment = Gregorian.moment({
                :year => year,
                :month => month,
                :day => day,
                :hour => hour,
                :minute => minute,
                :second => second
            });

            if (text.length() >= 25) {
                var sign = text.substring(19, 20);
                var offsetHours =
                    text.substring(20, 22).toNumber();
                var offsetMinutes =
                    text.substring(23, 25).toNumber();

                var adjustment =
                    (offsetHours * 3600) +
                    (offsetMinutes * 60);

                if (sign.equals("+")) {
                    adjustment = -adjustment;
                }

                moment = moment.add(
                    Gregorian.duration({
                        :seconds => adjustment
                    })
                );
            }

            return moment.value();

        } catch (error) {
            System.println(
                "Could not parse updated_at: " +
                text
            );
            return null;
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
            24,
            Graphics.FONT_MEDIUM,
            "SOLAR",
            Graphics.TEXT_JUSTIFY_CENTER
        );

        var y = 105;
        var rowSpacing = 56;

        drawRow(
            dc,
            y,
            "PV IN",
            formatPowerOrDash(solarData.pvWatts)
        );

        y += rowSpacing;

        drawRow(
            dc,
            y,
            "LOAD",
            formatPowerOrDash(solarData.loadWatts)
        );

        y += rowSpacing;

        drawRow(
            dc,
            y,
            "BATTERY VOLTAGE",
            formatVoltageOrDash(
                solarData.batteryVoltage
            )
        );

        y += rowSpacing;

        drawBatteryRow(dc, y);

        y += rowSpacing;

        drawRow(
            dc,
            y,
            "GRID",
            formatPowerOrDash(solarData.gridWatts)
        );

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        );

        dc.drawText(
            width / 2,
            height - 38,
            Graphics.FONT_XTINY,
            getStatusText(),
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function getStatusText() {
        if (isRefreshing) {
            return "UPDATING 1/1";
        }

        if (!hasData || lastUpdatedEpoch == null) {
            return "NO DATA";
        }

        var ageSeconds =
            Time.now().value() - lastUpdatedEpoch;

        if (ageSeconds < 0) {
            ageSeconds = 0;
        }

        if (lastRequestFailed || !sourceConnected) {
            return "OFFLINE · " +
                formatAgeMinutes(ageSeconds) +
                " AGO";
        }

        if (ageSeconds >= STALE_AFTER_SECONDS) {
            return "STALE · " +
                formatAgeMinutes(ageSeconds) +
                " AGO";
        }

        return "UPDATED " +
            ageSeconds.format("%d") +
            "s AGO";
    }

    function formatAgeMinutes(ageSeconds) {
        var minutes = ageSeconds / 60;

        if (minutes < 1) {
            minutes = 0;
        }

        return minutes.format("%d") + "m";
    }

    function drawRow(dc, y, label, value) {
        var leftMargin = 38;
        var rightMargin = dc.getWidth() - 38;

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        );

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

    function drawBatteryRow(dc, y) {
        var leftMargin = 38;
        var rightMargin = dc.getWidth() - 38;

        var valueText = "--";
        var valueColor = Graphics.COLOR_LT_GRAY;

        if (hasData) {
            if (solarData.batteryWatts > 50) {
                valueText = formatPower(
                    solarData.batteryWatts.abs()
                );
                valueColor = Graphics.COLOR_GREEN;

            } else if (solarData.batteryWatts < -50) {
                valueText = formatPower(
                    solarData.batteryWatts.abs()
                );
                valueColor = Graphics.COLOR_RED;

            } else {
                valueText = formatPower(
                    solarData.batteryWatts.abs()
                );
                valueColor = Graphics.COLOR_LT_GRAY;
            }
        }

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        );

        dc.drawText(
            leftMargin,
            y,
            Graphics.FONT_XTINY,
            "BATTERY POWER",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.setColor(
            valueColor,
            Graphics.COLOR_BLACK
        );

        dc.drawText(
            rightMargin,
            y - 3,
            Graphics.FONT_SMALL,
            valueText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function formatVoltageOrDash(volts) {
        if (!hasData) {
            return "--";
        }

        return volts.format("%.1f") + " V";
    }

    function formatPowerOrDash(watts) {
        if (!hasData) {
            return "--";
        }

        return formatPower(watts);
    }

    function formatPower(watts) {
        if (watts.abs() >= 1000) {
            return (
                watts.abs() / 1000.0
            ).format("%.2f") + " kW";
        }

        return watts.abs().format("%d") + " W";
    }

    function onHide() {
        refreshTimer.stop();
        statusTimer.stop();
        isRefreshing = false;
    }
}
