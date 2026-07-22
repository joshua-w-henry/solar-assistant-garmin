using Toybox.Application.Storage;
using Toybox.Complications;
using Toybox.System;
using Toybox.Time;

(:background)
module SolarComplications {

    const LOAD_INDEX = 0;
    const PV_INDEX = 1;
    const PV_TODAY_INDEX = 2;
    const BATTERY_VOLTAGE_INDEX = 3;

    const STALE_AFTER_SECONDS = 10 * 60;

    function publishValues(
        loadWatts,
        pvWatts,
        pvTodayKwh,
        batteryVoltage
    ) {
        publish(
            LOAD_INDEX,
            formatPower(loadWatts),
            "LOAD"
        );

        publish(
            PV_INDEX,
            formatPower(pvWatts),
            "PV"
        );

        publish(
            PV_TODAY_INDEX,
            formatEnergy(pvTodayKwh),
            "TODAY"
        );

        publish(
            BATTERY_VOLTAGE_INDEX,
            formatVoltage(batteryVoltage),
            "BAT"
        );
    }

    function publishFromStorage() {
        var updatedEpoch =
            Storage.getValue("updatedEpoch");

        var sourceConnected =
            Storage.getValue("sourceConnected");

        if (
            updatedEpoch == null ||
            sourceConnected == false
        ) {
            publishUnavailable();
            return;
        }

        var ageSeconds =
            Time.now().value() - updatedEpoch;

        if (
            ageSeconds < 0 ||
            ageSeconds > STALE_AFTER_SECONDS
        ) {
            publishUnavailable();
            return;
        }

        var loadWatts =
            Storage.getValue("loadWatts");

        var pvWatts =
            Storage.getValue("pvWatts");

        var pvTodayKwh =
            Storage.getValue("todaySolarKwh");

        var batteryVoltage =
            Storage.getValue("batteryVoltage");

        if (
            loadWatts == null ||
            pvWatts == null ||
            pvTodayKwh == null ||
            batteryVoltage == null
        ) {
            publishUnavailable();
            return;
        }

        publishValues(
            loadWatts,
            pvWatts,
            pvTodayKwh,
            batteryVoltage
        );
    }

    function publishUnavailable() {
        publish(LOAD_INDEX, null, "LOAD");
        publish(PV_INDEX, null, "PV");
        publish(PV_TODAY_INDEX, null, "TODAY");
        publish(BATTERY_VOLTAGE_INDEX, null, "BAT");
    }

    function publish(index, value, shortLabel) {
        try {
            Complications.updateComplication(
                index,
                {
                    :value => value,
                    :shortLabel => shortLabel,
                    :units => null
                }
            );
        } catch (e) {
            System.println(
                "Complication update failed for index " +
                index + ": " + e.getErrorMessage()
            );
        }
    }

    function formatPower(watts) {
        if (watts == null) {
            return null;
        }

        if (watts.abs() >= 1000) {
            return (
                watts.abs() / 1000.0
            ).format("%.1f") + "kW";
        }

        return watts.abs().format("%d") + "W";
    }

    function formatEnergy(kwh) {
        if (kwh == null) {
            return null;
        }

        return kwh.format("%.1f") + "kWh";
    }

    function formatVoltage(volts) {
        if (volts == null) {
            return null;
        }

        return volts.format("%.1f") + "V";
    }
}
