using Toybox.WatchUi;

class SolarAssistantDelegate
    extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function openTodayPage() {
        WatchUi.pushView(
            new SolarTodayView(),
            new SolarTodayDelegate(),
            WatchUi.SLIDE_LEFT
        );
    }

    function onSelect() {
        openTodayPage();
        return true;
    }

    function onNextPage() {
        openTodayPage();
        return true;
    }
}


class SolarTodayDelegate
    extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function closeTodayPage() {
        WatchUi.popView(
            WatchUi.SLIDE_RIGHT
        );
    }

    function onSelect() {
        closeTodayPage();
        return true;
    }

    function onPreviousPage() {
        closeTodayPage();
        return true;
    }

    function onBack() {
        closeTodayPage();
        return true;
    }
}