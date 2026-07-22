using Toybox.Application.Storage;
using Toybox.Background;
using Toybox.Communications;
using Toybox.Lang;
using Toybox.PersistedContent;
using Toybox.System;
using Toybox.Time;

(:background)
class SolarBackgroundService
    extends System.ServiceDelegate {

    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent() {
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

        if (
            responseCode != 200 ||
            !(data instanceof Lang.Dictionary)
        ) {
            SolarComplications.publishUnavailable();
            Background.exit(null);
            return;
        }

        var live = data.get("live");
        var today = data.get("today");

        if (
            !(live instanceof Lang.Dictionary) ||
            !(today instanceof Lang.Dictionary)
        ) {
            SolarComplications.publishUnavailable();
            Background.exit(null);
            return;
        }

        var pvWatts = readNumber(
            live,
            "pv_w",
            null
        );

        var loadWatts = readNumber(
            live,
            "load_w",
            null
        );

        var batteryVoltage = readNumber(
            live,
            "battery_v",
            null
        );

        var batteryWatts = readNumber(
            live,
            "battery_w",
            null
        );

        var gridWatts = readNumber(
            live,
            "grid_w",
            null
        );

        var todaySolarKwh = readNumber(
            today,
            "pv_kwh",
            null
        );

        var sourceConnected = readBoolean(
            data,
            "mqtt_connected",
            false
        );

        if (
            pvWatts == null ||
            loadWatts == null ||
            batteryVoltage == null ||
            todaySolarKwh == null
        ) {
            SolarComplications.publishUnavailable();
            Background.exit(null);
            return;
        }

        Storage.setValue("pvWatts", pvWatts);
        Storage.setValue("loadWatts", loadWatts);
        Storage.setValue(
            "batteryVoltage",
            batteryVoltage
        );

        if (batteryWatts != null) {
            Storage.setValue(
                "batteryWatts",
                batteryWatts
            );
        }

        if (gridWatts != null) {
            Storage.setValue(
                "gridWatts",
                gridWatts
            );
        }

        Storage.setValue(
            "todaySolarKwh",
            todaySolarKwh
        );

        saveOptionalDailyValues(today);

        Storage.setValue(
            "sourceConnected",
            sourceConnected
        );

        Storage.setValue(
            "updatedEpoch",
            Time.now().value()
        );

        Storage.setValue(
            "todayPartialDay",
            readBoolean(
                data,
                "partial_day",
                true
            )
        );

        Storage.setValue(
            "todayDateLabel",
            readString(data, "date", "TODAY")
        );

        if (sourceConnected) {
            SolarComplications.publishValues(
                loadWatts,
                pvWatts,
                todaySolarKwh,
                batteryVoltage
            );
        } else {
            SolarComplications.publishUnavailable();
        }

        Background.exit(null);
    }

    function saveOptionalDailyValues(today) {
        saveIfPresent(
            "todayLoadKwh",
            readNumber(today, "load_kwh", null)
        );

        saveIfPresent(
            "todayBatteryChargedKwh",
            readNumber(
                today,
                "battery_in_kwh",
                null
            )
        );

        saveIfPresent(
            "todayBatteryDischargedKwh",
            readNumber(
                today,
                "battery_out_kwh",
                null
            )
        );

        saveIfPresent(
            "todayGridImportedKwh",
            readNumber(
                today,
                "grid_in_kwh",
                null
            )
        );

        saveIfPresent(
            "todayGridExportedKwh",
            readNumber(
                today,
                "grid_out_kwh",
                null
            )
        );
    }

    function saveIfPresent(key, value) {
        if (value != null) {
            Storage.setValue(key, value);
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
}
