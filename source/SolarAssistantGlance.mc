using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Application.Storage;

(:glance)
class SolarAssistantGlanceView
    extends WatchUi.GlanceView {

    function initialize() {
        GlanceView.initialize();
    }

    function onLayout(dc) {
    }

    function onUpdate(dc) {
        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        );

        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var font = Graphics.FONT_XTINY;
        var fontHeight = dc.getFontHeight(font);

        var topY = 1;
        var middleY = (height - fontHeight) / 2;
        var bottomY = height - fontHeight - 1;

        var updatedEpoch =
            Storage.getValue("updatedEpoch");

        var hasData = updatedEpoch != null;

        var pvWatts = readStoredNumber(
            "pvWatts"
        );

        var loadWatts = readStoredNumber(
            "loadWatts"
        );

        var batteryWatts = readStoredNumber(
            "batteryWatts"
        );

        var todaySolarKwh =
            Storage.getValue("todaySolarKwh");

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        );

        dc.drawText(
            8,
            topY,
            font,
            "SOLAR",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.drawText(
            width - 8,
            topY,
            font,
            "PV " +
                formatPowerOrDash(
                    pvWatts,
                    hasData
                ),
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        dc.drawText(
            8,
            middleY,
            font,
            "LOAD " +
                formatPowerOrDash(
                    loadWatts,
                    hasData
                ),
            Graphics.TEXT_JUSTIFY_LEFT
        );

        var batteryText = "BAT --";
        var batteryColor = Graphics.COLOR_LT_GRAY;

        if (hasData) {
            batteryText =
                "BAT " +
                formatPowerCompact(
                    batteryWatts.abs()
                );

            if (batteryWatts > 50) {
                batteryColor = Graphics.COLOR_GREEN;
            } else if (batteryWatts < -50) {
                batteryColor = Graphics.COLOR_RED;
            }
        }

        dc.setColor(
            batteryColor,
            Graphics.COLOR_BLACK
        );

        dc.drawText(
            width - 8,
            middleY,
            font,
            batteryText,
            Graphics.TEXT_JUSTIFY_RIGHT
        );

        dc.setColor(
            Graphics.COLOR_WHITE,
            Graphics.COLOR_BLACK
        );

        dc.drawText(
            8,
            bottomY,
            font,
            "PV TODAY",
            Graphics.TEXT_JUSTIFY_LEFT
        );

        dc.drawText(
            width - 8,
            bottomY,
            font,
            formatEnergyCompact(todaySolarKwh),
            Graphics.TEXT_JUSTIFY_RIGHT
        );
    }

    function readStoredNumber(key) {
        var value = Storage.getValue(key);

        if (value == null) {
            return 0.0;
        }

        return value;
    }

    function formatPowerOrDash(watts, hasData) {
        if (!hasData) {
            return "--";
        }

        return formatPowerCompact(watts);
    }

    function formatPowerCompact(watts) {
        if (watts.abs() >= 1000) {
            return (
                watts.abs() / 1000.0
            ).format("%.1f") + "kW";
        }

        return watts.abs().format("%d") + "W";
    }

    function formatEnergyCompact(value) {
        if (value == null) {
            return "--";
        }

        return value.format("%.1f") + "kWh";
    }
}
