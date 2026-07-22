using Toybox.Application;
using Toybox.Background;
using Toybox.System;
using Toybox.Time;
using Toybox.WatchUi;

(:background)
class SolarAssistantApp
    extends Application.AppBase {

    const BACKGROUND_INTERVAL_SECONDS = 5 * 60;

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
        registerBackgroundRefresh();
        SolarComplications.publishFromStorage();
    }

    function onStop(state) {
    }

    function registerBackgroundRefresh() {
        try {
            if (
                Background
                    .getTemporalEventRegisteredTime()
                == null
            ) {
                Background.registerForTemporalEvent(
                    new Time.Duration(
                        BACKGROUND_INTERVAL_SECONDS
                    )
                );
            }
        } catch (e) {
            System.println(
                "Could not register background refresh: " +
                e.getErrorMessage()
            );
        }
    }

    function getServiceDelegate() {
        return [new SolarBackgroundService()];
    }

    function getInitialView() {
        return [
            new SolarAssistantView(),
            new SolarAssistantDelegate()
        ];
    }

    function getGlanceView() {
        return [
            new SolarAssistantGlanceView()
        ];
    }
}

function getApp() {
    return Application.getApp();
}
