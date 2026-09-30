package com.moffatbaymarina.marinawebsite.util;

import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * The marina's contact details and hours - the one place the site keeps
 * them. Change a value here and every page, script and servlet message
 * that shows it changes with it.
 *
 * <p>Java code uses the constants directly. Pages read the same values
 * through the {@code marina} application attribute that
 * {@link MarinaInfoListener} sets at startup, e.g.
 * {@code <c:out value="${marina.phone}"/>}. Scripts read the phone number
 * from the header's {@code data-marina-phone} attribute.
 *
 * <p>The values match {@code documentation/definitions_decisions.md}, which
 * stays the team's reference; keep the two in step.
 *
 * @author Breutzmann, R. (Blue Team)
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Robert Breutzmann
 * @implNote Written with the assistance of Claude.
 */
public final class MarinaInfo {

    public static final String STREET = "1400 Harbor Loop Road";

    public static final String CITY_STATE_ZIP = "Joviedsa Island, WA 98250";

    public static final String PHONE = "(360) 555-0142";

    /** The {@code tel:} link, built from {@link #PHONE} so the two can't disagree. */
    public static final String PHONE_LINK = "tel:+1" + PHONE.replaceAll("\\D", "");

    public static final String EMAIL = "office@moffatbaymarina.com";

    public static final String VHF = "Channel 16";

    /** Office hours in display order: days on the left, hours on the right. */
    public static final Map<String, String> OFFICE_HOURS = officeHours();

    public static final String FUEL_DOCK_HOURS = "7:00 am – dusk, daily";

    private MarinaInfo() {
    }

    private static Map<String, String> officeHours() {
        Map<String, String> hours = new LinkedHashMap<>();
        hours.put("Mon – Fri", "6:00 am – 7:00 pm");
        hours.put("Saturday", "6:00 am – 7:00 pm");
        hours.put("Sunday", "7:00 am – 5:00 pm");
        return Collections.unmodifiableMap(hours);
    }

    /**
     * Every value above, keyed by the name a page uses after
     * {@code marina.} - {@code ${marina.phoneLink}},
     * {@code ${marina.officeHours}} and so on.
     */
    public static Map<String, Object> forPages() {
        return Map.of(
                "street", STREET,
                "cityStateZip", CITY_STATE_ZIP,
                "phone", PHONE,
                "phoneLink", PHONE_LINK,
                "email", EMAIL,
                "vhf", VHF,
                "officeHours", OFFICE_HOURS,
                "fuelDockHours", FUEL_DOCK_HOURS);
    }
}
