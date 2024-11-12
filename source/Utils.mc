using Toybox.Time.Gregorian;
import Toybox.Lang;

class Utils {
    hidden var _displayProfile = null;
    hidden var _theme = null;

    public function isSleepTime() {
        var isSleepTime = false;

        return isSleepTime;
    }

    public function getTime() as Lang.Dictionary {
        // return an array [hours, minutes, seconds, meridian]
        // var clockTime = System.getClockTime();
        var clockTime = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var hours = clockTime.hour;
        var minutes = clockTime.min;
        var seconds = clockTime.sec;
        var meridian = "AM";

        if (hours >= 12) {
            meridian = "PM";
        }

        if (System.getDeviceSettings().is24Hour == false) {
            if (hours > 12) {
                hours = hours - 12;
            }
        }

        return {
            :hours => hours,
            :minutes => minutes,
            :seconds => seconds,
            :meridian => meridian
        };

        // return [hours, minutes, seconds, meridian];
    }

    public function getDate() as Lang.Dictionary {
        var date = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);
        var dowStr = Lang.format("$1$", [date.day_of_week]).toUpper();
        var monthStr = Lang.format("$1$", [date.month]).toUpper();
        var dayStr = Lang.format("$1$", [date.day]);

        return {
            :dow => dowStr,
            :month => monthStr,
            :day => dayStr
        };
    }

    public function getDigitResourceId(part, pos, theme) {
        return Lang.format("$1$_$2$_$3$", [part, pos, theme]);
    }

    public function formatStepCount(stepsCount, stepsGoal) {
        if (stepsCount == null) {
            return "";
        }
        if (stepsGoal == null) {
            stepsGoal = 0;
        }

        var stepPercent = 0;
        var stepsAndGoal = stepsCount.format("%d");
        if (stepsGoal > 0) {
            stepPercent = ((stepsCount * 100) /stepsGoal);
            if (stepPercent > 100) {
                stepPercent = 100;
            }
            if (stepPercent >= 1) {
                stepsAndGoal = Lang.format("$1$/$2$%", [stepsAndGoal, stepPercent]);
            }
        }

        return [stepsAndGoal, stepPercent == 100];
    }

    public function getStepCount() {
        // returns array [stepCount, goal]
        return [ActivityMonitor.getInfo().steps, ActivityMonitor.getInfo().stepGoal];
    }

    function getHeartRate() {
        var currentHeartRate = Activity.getActivityInfo().currentHeartRate;
        if (null != currentHeartRate) {
            return currentHeartRate.format("%d");
        }

        return "--";
    }

    public function getPercentage(value, goalValue) {
        if (goalValue == 0) {
            return 1.0;
        }
        if (value >= goalValue) {
            return 1.0;
        }

        return value.toDouble()/goalValue.toDouble();
    }
}