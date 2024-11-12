import Toybox.Application;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class DPTextComplication {
    hidden var _x = 0;
    hidden var _y = 0;
    hidden var _font = null;
    hidden var _text = null;
    hidden var _textJustification = null;
    hidden var _color = null;

    function initialize(x as Number, y as Number, font, color, text as String, textJustification) {
        self._x = x;
        self._y = y;
        self._font = font;
        self._color = color;
        self._text = text;
        self._textJustification = textJustification;
    }

    function draw(dc as Dc) {
        dc.drawText(self._x, self._y, self._font, self._text, self._textJustification);
    }
}

class Coord {
    public var x = 0;
    public var y = 0;

    function initialize(_x as Number, _y as Number) {
        self.x = _x;
        self.y = _y;
    }
}

class DPPocketsView extends WatchUi.WatchFace {
    hidden var _hHourOffset = 20;
    hidden var _vPadding = 5;
    hidden var _hPadding = 5;

    hidden var _dcw = 0;
    hidden var _dch = 0;
    hidden var _utils = null;
    hidden var _fgColor = Graphics.COLOR_WHITE;
    hidden var _accentColor = Graphics.COLOR_BLUE;

    // fonts
    hidden var _fontXXL = null;
    hidden var _fontXL = null;
    hidden var _fontL = null;
    hidden var _fontM = null;
    hidden var _fontS = null;
    hidden var _wwFont = null;
    // hidden var _fontXS = null;
    hidden var _fontXXLHeight = 0;
    hidden var _fontXLHeight = 0;
    hidden var _fontLHeight = 0;
    hidden var _fontMHeight = 0;
    hidden var _fontSHeight = 0;
    // hidden var _fontXSHeight = 0;

    // icons
    hidden var _stepsIcon = null;
    hidden var _heartRateIcon = null;
    hidden var _batteryIcon = null;
    hidden var _caloriesIcon = null;
    hidden var _activeMinutesIcon = null;

    hidden var _hourx;
    hidden var _minutex;

    hidden var _dc = null;

    // data row coordinates
    hidden var _dataRowHeight = null;
    hidden var _dataRow1Coord = null;
    hidden var _dataRow2Coord = null;
    hidden var _dataRow3Coord = null;
    hidden var _dataRow4Coord = null;
    hidden var _dataRow5Coord = null;
    hidden var _dataRow6Coord = null;
    hidden var _dataRow7Coord = null;

    // glyph coordinates
    hidden var _glyphCoord = null;

    // dividers coordinates
    hidden var _divVerticalTopCoord = null;
    hidden var _divVerticalBottomCoord = null;
    hidden var _divHorizontalMedianCoord = null;

    // battery
    hidden var _batteryWidth = 26;
    hidden var _batteryHeight = 14;
    hidden var _batteryLevelHeight = 0;
    hidden var _batteryLevelMaxWidth = 0;
    hidden var _batteryCoord = null;
    hidden var _batteryLevelCoord = null;

    hidden var _displaySeconds = true;

    function initialize() {
        WatchFace.initialize();

        self._utils = new Utils();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));

        self._dcw = dc.getWidth();
        self._dch = dc.getHeight();

        // load fonts
        self._fontXXL = WatchUi.loadResource(Rez.Fonts.HenkSinger_90px);
        self._fontXXLHeight = dc.getFontHeight(self._fontXXL);
        self._fontXL = WatchUi.loadResource(Rez.Fonts.HenkSinger_80px);
        self._fontXLHeight = dc.getFontHeight(self._fontXL);
        self._fontL = WatchUi.loadResource(Rez.Fonts.HenkSinger_24px);
        self._fontLHeight = dc.getFontHeight(self._fontL);
        self._fontM = WatchUi.loadResource(Rez.Fonts.HenkSinger_22px);
        self._fontMHeight = dc.getFontHeight(self._fontM);
        self._fontS = WatchUi.loadResource(Rez.Fonts.HenkSinger_20px);
        self._fontSHeight = dc.getFontHeight(self._fontS);
        self._wwFont = WatchUi.loadResource(Rez.Fonts.WildWestIcons_42px);

        // load complications icons
        self._stepsIcon = WatchUi.loadResource(Rez.Drawables.steps_blue) as BitmapResource;
        self._heartRateIcon = WatchUi.loadResource(Rez.Drawables.heart_0) as BitmapResource;
        self._caloriesIcon = WatchUi.loadResource(Rez.Drawables.calories_blue) as BitmapResource;
        self._activeMinutesIcon = WatchUi.loadResource(Rez.Drawables.active_blue) as BitmapResource;

        // hour start pos
        self._hourx = self._dcw * 0.5 + self._hHourOffset;

        // minutes start pos
        self._minutex = self._dcw * 0.5 - self._hHourOffset;

        // dividers coordinates
        self._divVerticalTopCoord = new Coord(self._hourx + self._hPadding, self._dch * 0.5);
        self._divVerticalBottomCoord = new Coord(self._minutex - self._hPadding, self._dch * 0.5);
        self._divHorizontalMedianCoord = new Coord(0, self._dch * 0.5);

        // compute data rows start coordinates
        self._dataRowHeight = 20 + self._vPadding;
        self._dataRow1Coord = new Coord(2, 2);
        self._dataRow2Coord = new Coord(self._divVerticalTopCoord.x + self._hPadding, self._dataRow1Coord.y + self._dataRowHeight);
        self._dataRow3Coord = new Coord(2, self._divHorizontalMedianCoord.y + self._vPadding);
        self._dataRow4Coord = new Coord(10, self._dataRow3Coord.y + self._dataRowHeight);
        self._dataRow5Coord = new Coord(25, self._dataRow4Coord.y + self._dataRowHeight);
        self._dataRow6Coord = new Coord(25, self._dataRow5Coord.y + self._dataRowHeight);
        self._dataRow7Coord = new Coord(self._divVerticalBottomCoord.x + self._hPadding, self._dataRow6Coord.y + self._dataRowHeight);
        
        // battery
        self._batteryCoord = new Coord(self._divVerticalTopCoord.x - self._hPadding - self._batteryWidth - 3, self._dataRow1Coord.y);
        self._batteryLevelCoord = new Coord(self._batteryCoord.x + 2, self._batteryCoord.y + 2);
        self._batteryLevelHeight = _batteryHeight - 4;
        self._batteryLevelMaxWidth = _batteryWidth - 4;
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // // Get the current time and format it correctly
        // var timeFormat = "$1$:$2$";
        // var clockTime = System.getClockTime();
        // var hours = clockTime.hour;
        // if (!System.getDeviceSettings().is24Hour) {
        //     if (hours > 12) {
        //         hours = hours - 12;
        //     }
        // } else {
        //     if (Application.Properties.getValue("UseMilitaryFormat")) {
        //         timeFormat = "$1$$2$";
        //         hours = hours.format("%02d");
        //     }
        // }
        // var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);

        // // Update the view
        // var view = View.findDrawableById("TimeLabel") as Text;
        // view.setColor(Application.Properties.getValue("ForegroundColor") as Number);
        // view.setText(timeString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        self._fgColor = 0xFFFFFF; // Properties.getValue("ForegroundColor");
        var currentTime = self._utils.getTime();
        _showHour(currentTime, dc);
        _showMinutes(currentTime, dc);
        _showDate(dc);
        if (Application.Properties.getValue("ShowSeconds") && self._displaySeconds) { _showSeconds(currentTime, self._fgColor, dc); }
        _showMeridian(currentTime, dc);

        _showDividers(dc);

        _showData(dc, self._dataRow3Coord, self._stepsIcon, Lang.format("$1$", [ActivityMonitor.getInfo().steps.format("%d")]));
        _showData(dc, self._dataRow4Coord, self._caloriesIcon, ActivityMonitor.getInfo().calories.format("%d"));
        _showData(dc, self._dataRow5Coord, self._activeMinutesIcon, ActivityMonitor.getInfo().activeMinutesWeek.total.format("%d"));
        _showData(dc, self._dataRow7Coord, self._heartRateIcon, self._utils.getHeartRate());
        _showBattery(dc);
        _showGlyph(dc);
    }

    function _showHour(currentTime as Dictionary, dc as Dc) as Void {
        var hours = currentTime[:hours];
        if (Properties.getValue("UseMilitaryFormat") || System.getDeviceSettings().is24Hour) {
            hours = hours.format("%02d");
        }
        var hourString = Lang.format("$1$", [hours]);

        // dc.setColor(Properties.getValue("HourFgColor") as Number, Graphics.COLOR_TRANSPARENT);
        dc.setColor(self._fgColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(self._hourx, self._dch * 0.5 - self._fontXLHeight, self._fontXL, hourString, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function _showMinutes(currentTime as Dictionary, dc as Dc) as Void {
        var minuteStr = Lang.format("$1$", [currentTime[:minutes].format("%02d")]);
        // var minuteStr = "44";
        dc.setColor(self._fgColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(self._minutex, self._dch * 0.5 + self._vPadding, self._fontXL, minuteStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _showSeconds(currentTime as Dictionary, color, dc as Dc) as Void {
        var secStr = Lang.format("$1$", [currentTime[:seconds].format("%02d")]);
        // var minStr = Lang.format("$1$", [currentTime[:minutes].format("%02d")]);
        var secPadding = 2;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(self._dcw * 0.5 - self._hHourOffset + dc.getTextWidthInPixels("44", self._fontXL) + secPadding, self._dch * 0.5 + self._vPadding, self._fontS, secStr, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _showMeridian(currentTime as Dictionary, dc as Dc) as Void {
        if (System.getDeviceSettings().is24Hour == false) {
            dc.setColor(self._fgColor, Graphics.COLOR_TRANSPARENT);
            dc.drawText(0, self._dch * 0.5 - self._vPadding * 1.5 - self._fontMHeight, self._fontM, currentTime[:meridian], Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function _showDividers(dc as Dc) {
        // horizontal middle divider
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(self._divHorizontalMedianCoord.x, self._divHorizontalMedianCoord.y, self._dcw, self._dch * 0.5);

        // vertical upper divider
        dc.drawLine(self._divVerticalTopCoord.x, self._divVerticalTopCoord.y, self._hourx + self._hPadding, 0);

        // vertical bottom divider
        dc.drawLine(self._divVerticalBottomCoord.x, self._divVerticalBottomCoord.y, self._minutex - self._hPadding, self._dch);

        // // show data rows
        // dc.drawLine(0, self._dataRow1Coord.y , self._dcw, self._dataRow1Coord.y);
        // dc.drawLine(0, self._dataRow2Coord.y , self._dcw, self._dataRow2Coord.y);
        // dc.drawLine(0, self._dataRow3Coord.y , self._dcw, self._dataRow3Coord.y);
        // dc.drawLine(0, self._dataRow4Coord.y , self._dcw, self._dataRow4Coord.y);
        // dc.drawLine(0, self._dataRow5Coord.y , self._dcw, self._dataRow5Coord.y);
        // dc.drawLine(0, self._dataRow6Coord.y , self._dcw, self._dataRow6Coord.y);
        // dc.drawLine(0, self._dataRow7Coord.y , self._dcw, self._dataRow7Coord.y);
    }

    function _showData(dc as Dc, coord as Coord, icon as BitmapResource, text as String) as Void {
        dc.drawBitmap(coord.x, coord.y, icon);
        var posText = new Coord(coord.x + icon.getWidth() + self._hPadding, coord.y);
        dc.setColor(self._fgColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(posText.x, posText.y, self._fontS, text, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _showBattery(dc as Dc) as Void {
        var batValue = System.getSystemStats().battery;

        // draw battery
        dc.setColor(self._accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawRectangle(self._batteryCoord.x, self._batteryCoord.y, self._batteryWidth, self._batteryHeight);
        dc.fillRectangle(self._batteryCoord.x + self._batteryWidth, self._batteryCoord.y + self._batteryHeight * 0.25, 3, self._batteryHeight * 0.5);

        // draw battery level
        var batLevelWidth = batValue * self._batteryLevelMaxWidth * 0.01;

        if (batValue <= 10) {
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        } else {
            dc.setColor(self._fgColor, Graphics.COLOR_TRANSPARENT);
        }
        dc.fillRectangle(self._batteryLevelCoord.x, self._batteryLevelCoord.y, batLevelWidth, self._batteryLevelHeight);

        // draw battery marks at 25% increments
        dc.setColor(self._accentColor, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(self._batteryCoord.x + self._batteryWidth * 0.25, self._batteryCoord.y, self._batteryCoord.x + self._batteryWidth * 0.25, self._batteryCoord.y + self._batteryHeight-1);
        dc.drawLine(self._batteryCoord.x + self._batteryWidth * 0.5, self._batteryCoord.y, self._batteryCoord.x + self._batteryWidth * 0.5, self._batteryCoord.y + self._batteryHeight-1);
        dc.drawLine(self._batteryCoord.x + self._batteryWidth * 0.75, self._batteryCoord.y, self._batteryCoord.x + self._batteryWidth * 0.75, self._batteryCoord.y + self._batteryHeight-1);
    }

    function _showDate(dc as Dc) as Void {
        var currentDate = self._utils.getDate() as Dictionary;
        var posMonAndDay = new Coord(self._hourx + self._hPadding * 2, self._dch * 0.5 - self._vPadding * 2 - self._fontLHeight);
        dc.setColor(self._fgColor, Graphics.COLOR_TRANSPARENT);
        var monAndDayStr = Lang.format("$1$ $2$", [currentDate[:month], currentDate[:day]]);
        // var monAndDayStr = "DEC 24";
        dc.drawText(posMonAndDay.x, posMonAndDay.y, self._fontM, monAndDayStr, Graphics.TEXT_JUSTIFY_LEFT);

        var posDow = new Coord(posMonAndDay.x, posMonAndDay.y - self._hPadding - self._fontLHeight);
        dc.drawText(posDow.x, posDow.y, self._fontL, currentDate[:dow], Graphics.TEXT_JUSTIFY_LEFT);
    }

    function _showGlyph(dc as Dc) as Void {
        dc.setColor(self._fgColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(self._dataRow2Coord.x, self._dataRow2Coord.y, self._wwFont, "l", Graphics.TEXT_JUSTIFY_LEFT);
    }

    function onPartialUpdate(dc as Graphics.Dc) as Void {
        if (Application.Properties.getValue("ShowSeconds") && self._displaySeconds) {
            var secPadding = 2;
            var clipX = self._dcw * 0.5 - self._hHourOffset + dc.getTextWidthInPixels("44", self._fontXL) + secPadding;
            var clipY = self._dch * 0.5 + self._vPadding;
            dc.setClip(clipX, clipY, self._dcw - clipX, self._fontSHeight);
            dc.setColor(Properties.getValue("BackgroundColor") as Number, Graphics.COLOR_TRANSPARENT);
            dc.fillRectangle(0, 0, self._dcw, self._dch); 
            dc.clearClip();
        }
        self._displaySeconds = false;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
        self._displaySeconds = true;
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
        self._displaySeconds = false;
    }

}
