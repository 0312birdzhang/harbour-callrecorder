/*
    Call Recorder for SailfishOS
    Copyright (C) 2014-2015 Dmitriy Purgin <dpurgin@gmail.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    property bool selected: getSelected()
    readonly property bool highlight: highlighted || selected

    showMenuOnPressAndHold: false

    _backgroundColor: Theme.rgba(Theme.highlightBackgroundColor,
                                 highlight && !menuOpen?
                                     Theme.highlightBackgroundOpacity:
                                     0)

    Row {
        id: container

        width: parent.width
        height: Theme.itemSizeMedium

        Item {
            id: leftSpacer

            width: Theme.paddingLarge
            height: parent.height
        }

        Column {
            width: parent.width - leftSpacer.width - rightSpacer.width
            height: parent.height

            Row {
                width: parent.width
                spacing: Theme.paddingSmall

                Label {
                    text: model.primaryName

                    color: highlight? Theme.highlightColor: Theme.primaryColor
                }

                Label {
                    text: model.secondaryName

                    color: highlight? Theme.secondaryHighlightColor: Theme.secondaryColor

                    wrapMode: Text.NoWrap
                    truncationMode: TruncationMode.Fade
                }
            }

            Label {
                id: phoneNumbersLabel

                text: getPhoneNumbers()

                width: parent.width

                font.pixelSize: Theme.fontSizeExtraSmall

                color: highlight? Theme.secondaryHighlightColor: Theme.secondaryColor

                wrapMode: Text.NoWrap
                truncationMode: TruncationMode.Fade
            }
        }

        Item {
            id: rightSpacer

            width: Theme.paddingLarge
            height: parent.height
        }
    }

    menu: ContactPickerDelegateMenu {
        phoneNumbers: model.phoneNumbers
    }    

    states: [
        State {
            name: "selected"
            when: selected

            PropertyChanges {
                target: phoneNumbersLabel
                text: getPhoneNumbers()
            }
        },

        State {
            name: "unselected"
            when: !selected

            PropertyChanges {
                target: phoneNumbersLabel
                text: getPhoneNumbers()
            }
        }

    ]

    onClicked: {
        if (model.phoneNumbers.length > 1)
            showMenu()
        else if (model.phoneNumbers.length === 1)
        {
            var phoneNumber = model.phoneNumbers[0];

            if (isSelected(phoneNumber))
                removeFromSelection(phoneNumber);
            else
                addToSelection(phoneNumber);
        }
    }

    Connections {
        target: contactPickerDialog

        onSelectionChanged: updateSelected()
    }

    function getPhoneNumbers()
    {
        var repr = '';

        for (var i = 0; i < model.phoneNumbers.length; i++)
        {
            if (repr.length > 0)
                repr += ', '

            var phoneNumber = model.phoneNumbers[i];

            if (isSelected(phoneNumber))
                repr += Theme.highlightText(phoneNumber,
                                            phoneNumber,
                                            Theme.highlightColor);
            else
                repr += phoneNumber;
        }

        return repr;
    }

    function getSelected()
    {
        var doSelect = false;

        for (var i = 0; i < model.phoneNumbers.length && !doSelect; i++)
        {
            if (isSelected(model.phoneNumbers[i]))
                doSelect = true;
        }

        return doSelect;
    }

    function updateSelected()
    {
        var doSelect = getSelected();

        if (selected !== doSelect)
            selected = doSelect;
    }
}
