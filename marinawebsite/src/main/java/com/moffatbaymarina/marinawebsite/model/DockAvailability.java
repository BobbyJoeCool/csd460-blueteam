package com.moffatbaymarina.marinawebsite.model;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * Reservation page view of one dock and available slips in each slip size
 *
 * @author White, S. 
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * 
 * This model stores one dock's identifying information and a map of how many slips are available for each slip size. Each slip-size count starts at zero; ReservationDAO will replace those values with counts from the database. 
 */
public class DockAvailability {

    private int dockId;
    private String dockNumber;
    private String dockDescription;
    private final Map<String, Integer> available = new LinkedHashMap<>();

    public DockAvailability() {
        available.put("26", 0);
        available.put("40", 0);
        available.put("50", 0);
    }
    // Getters and setters provide access to dock and slip availability
    public int getDockId() {
        return dockId;
    }

    public void setDockId(int dockId) {
        this.dockId = dockId;
    }

    public String getDockNumber() {
        return dockNumber;
    }

    public void setDockNumber(String dockNumber) {
        this.dockNumber = dockNumber;
    }

    public String getDockDescription() {
        return dockDescription;
    }

    public void setDockDescription(String dockDescription) {
        this.dockDescription = dockDescription;
    }

    public Map<String, Integer> getAvailable() {
        return available;
    }

    public void setAvailableCount(int sizeFt, int count) {
        available.put(String.valueOf(sizeFt), count);
    }
}
