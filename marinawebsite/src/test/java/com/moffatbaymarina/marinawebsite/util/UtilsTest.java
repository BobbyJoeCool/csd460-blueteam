package com.moffatbaymarina.marinawebsite.util;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.Year;

import org.junit.Test;

/**
 * Tests for the shared helpers in {@link Utils}. Run with {@code mvn test}.
 *
 * <p>Several of these pin down behaviour the servlets relied on before the
 * helpers were shared, so moving a servlet onto Utils can't quietly change
 * what it accepts.
 *
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Shared (all four)
 */
public class UtilsTest {

    // ------------------------------------------------------------ form input

    @Test
    public void cleanTrimsAndNeverReturnsNull() {
        assertEquals("", Utils.clean(null));
        assertEquals("", Utils.clean("   "));
        assertEquals("Elena", Utils.clean("  Elena \t"));
    }

    @Test
    public void orEmptyKeepsSpaces() {
        assertEquals("", Utils.orEmpty(null));
        assertEquals("  pass word  ", Utils.orEmpty("  pass word  "));
    }

    @Test
    public void isBlankAndEmptyToNull() {
        assertTrue(Utils.isBlank(null));
        assertTrue(Utils.isBlank(""));
        assertTrue(Utils.isBlank(" \t "));
        assertFalse(Utils.isBlank("x"));

        assertNull(Utils.emptyToNull(null));
        assertNull(Utils.emptyToNull("  "));
        assertEquals("Apt 2", Utils.emptyToNull("Apt 2"));
    }

    @Test
    public void parseIntReturnsNullInsteadOfThrowing() {
        assertEquals(Integer.valueOf(42), Utils.parseInt("42"));
        assertEquals(Integer.valueOf(42), Utils.parseInt(" 42 "));
        assertEquals(Integer.valueOf(-3), Utils.parseInt("-3"));
        assertNull(Utils.parseInt(null));
        assertNull(Utils.parseInt(""));
        assertNull(Utils.parseInt("abc"));
        assertNull(Utils.parseInt("4.5"));
        assertNull(Utils.parseInt("99999999999"));
    }

    @Test
    public void parseIntInRangeRejectsOutOfRange() {
        assertEquals(Integer.valueOf(1), Utils.parseIntInRange("1", 1, 12));
        assertEquals(Integer.valueOf(12), Utils.parseIntInRange("12", 1, 12));
        assertNull(Utils.parseIntInRange("0", 1, 12));
        assertNull(Utils.parseIntInRange("13", 1, 12));
        assertNull(Utils.parseIntInRange("-1", 1, 12));
        assertNull(Utils.parseIntInRange("abc", 1, 12));
        assertNull(Utils.parseIntInRange("", 1, 12));
    }

    @Test
    public void parseDecimal() {
        assertEquals(new BigDecimal("32.5"), Utils.parseDecimal("32.5"));
        assertEquals(new BigDecimal("32.5"), Utils.parseDecimal(" 32.5 "));
        assertNull(Utils.parseDecimal("thirty"));
        assertNull(Utils.parseDecimal(""));
        assertNull(Utils.parseDecimal(null));
    }

    @Test
    public void parseDateAcceptsOnlyRealIsoDates() {
        assertEquals(LocalDate.of(2026, 6, 1), Utils.parseDate("2026-06-01"));
        assertNull(Utils.parseDate("2026-02-30"));
        assertNull(Utils.parseDate("06/01/2026"));
        assertNull(Utils.parseDate(""));
        assertNull(Utils.parseDate(null));
    }

    // ------------------------------------------------------------ boat rules

    @Test
    public void boatDimensionLimits() {
        assertTrue(Utils.isValidBoatDimension(new BigDecimal("0.1")));
        assertTrue(Utils.isValidBoatDimension(new BigDecimal("999.9")));
        assertFalse(Utils.isValidBoatDimension(new BigDecimal("1000")));
        assertFalse(Utils.isValidBoatDimension(new BigDecimal("9999.9")));
        assertFalse(Utils.isValidBoatDimension(BigDecimal.ZERO));
        assertFalse(Utils.isValidBoatDimension(new BigDecimal("-5")));
        assertFalse(Utils.isValidBoatDimension(null));
    }

    @Test
    public void boatYearLimits() {
        int thisYear = Year.now().getValue();
        assertTrue(Utils.isValidBoatYear(1800));
        assertTrue(Utils.isValidBoatYear(thisYear));
        assertFalse(Utils.isValidBoatYear(1799));
        assertFalse(Utils.isValidBoatYear(thisYear + 1));
        assertFalse(Utils.isValidBoatYear(null));
    }

    @Test
    public void hinPattern() {
        assertTrue(Utils.isValidHin("BPL123456789"));
        assertFalse(Utils.isValidHin("BP1123456789"));
        assertFalse(Utils.isValidHin("BPL12345678"));
        assertFalse(Utils.isValidHin(null));
    }

    @Test
    public void usRegNumberAcceptsSpaceOrHyphen() {
        assertTrue(Utils.isValidRegNumber("WN1234AB", "US"));
        assertTrue(Utils.isValidRegNumber("WN1234 AB", "US"));
        assertTrue(Utils.isValidRegNumber("WN 1234 AB", "US"));
        // The case Registration used to reject while the browser accepted it.
        assertTrue(Utils.isValidRegNumber("WN-1234-AB", "US"));
        assertTrue(Utils.isValidRegNumber("WN-1234567-CD", "US"));
        assertFalse(Utils.isValidRegNumber("WN123AB", "US"));
        assertFalse(Utils.isValidRegNumber("W1234AB", "US"));
        assertFalse(Utils.isValidRegNumber("WN--1234AB", "US"));
    }

    @Test
    public void canadianRegNumber() {
        assertTrue(Utils.isValidRegNumber("C1234AB", "CA"));
        assertTrue(Utils.isValidRegNumber("C1234 AB", "CA"));
        assertTrue(Utils.isValidRegNumber("C12345678-AB", "CA"));
        assertFalse(Utils.isValidRegNumber("WN1234AB", "CA"));
        assertFalse(Utils.isValidRegNumber("C123AB", "CA"));
    }

    @Test
    public void otherCountryRegNumberHasNoFormat() {
        assertTrue(Utils.isValidRegNumber("anything at all", "OTHER"));
        assertFalse(Utils.isValidRegNumber(null, "OTHER"));
    }

    @Test
    public void slipSizeForMatchesTheOldServletCopies() {
        assertEquals(26, Utils.slipSizeFor(new BigDecimal("1")));
        assertEquals(26, Utils.slipSizeFor(new BigDecimal("26")));
        assertEquals(40, Utils.slipSizeFor(new BigDecimal("26.1")));
        assertEquals(40, Utils.slipSizeFor(new BigDecimal("40.0")));
        assertEquals(50, Utils.slipSizeFor(new BigDecimal("40.5")));
        assertEquals(50, Utils.slipSizeFor(new BigDecimal("50")));
        assertEquals(0, Utils.slipSizeFor(new BigDecimal("50.1")));
        assertEquals(0, Utils.slipSizeFor(null));
    }

    @Test
    public void isSlipSize() {
        assertTrue(Utils.isSlipSize(26));
        assertTrue(Utils.isSlipSize(40));
        assertTrue(Utils.isSlipSize(50));
        assertFalse(Utils.isSlipSize(30));
        assertFalse(Utils.isSlipSize(0));
        assertFalse(Utils.isSlipSize(null));
    }

    // ------------------------------------------------------- money and dates

    @Test
    public void toCentsRoundsHalfUp() {
        assertEquals(48500, Utils.toCents(new BigDecimal("485")));
        assertEquals(48500, Utils.toCents(new BigDecimal("485.00")));
        assertEquals(1235, Utils.toCents(new BigDecimal("12.345")));
        assertEquals(1234, Utils.toCents(new BigDecimal("12.344")));
    }

    @Test
    public void formatDisplayDate() {
        assertEquals("Jun 1, 2026", Utils.formatDisplayDate(LocalDate.of(2026, 6, 1)));
        assertEquals("Sep 15, 2026", Utils.formatDisplayDate(LocalDate.of(2026, 9, 15)));
        assertEquals("", Utils.formatDisplayDate(null));
    }

    // ------------------------------------------------- requests and responses

    @Test
    public void safeRedirectTargetKeepsSitePaths() {
        assertEquals("/reservations", Utils.safeRedirectTarget("/reservations", "/"));
        assertEquals("/reservationSummary?confirmation=MB-00001",
                Utils.safeRedirectTarget("/reservationSummary?confirmation=MB-00001", "/"));
    }

    @Test
    public void safeRedirectTargetRejectsOtherSites() {
        assertEquals("/", Utils.safeRedirectTarget(null, "/"));
        assertEquals("/", Utils.safeRedirectTarget("", "/"));
        assertEquals("/", Utils.safeRedirectTarget("https://evil.example", "/"));
        assertEquals("/", Utils.safeRedirectTarget("//evil.example", "/"));
        assertEquals("/", Utils.safeRedirectTarget("/\\evil.example", "/"));
        assertEquals("/", Utils.safeRedirectTarget("evil.example", "/"));
        assertEquals("/", Utils.safeRedirectTarget("/go?to=https://evil.example", "/"));
    }

    @Test
    public void isDuplicateKey() {
        assertTrue(Utils.isDuplicateKey(new SQLException("dup", "23000", 1062)));
        assertTrue(Utils.isDuplicateKey(new SQLException("fk", "23000", 1452)));
        assertFalse(Utils.isDuplicateKey(new SQLException("gone", "08S01", 0)));
    }

    @Test
    public void jsonEscape() {
        assertEquals("", Utils.jsonEscape(null));
        assertEquals("plain", Utils.jsonEscape("plain"));
        assertEquals("say \\\"hi\\\"", Utils.jsonEscape("say \"hi\""));
        assertEquals("a\\\\b", Utils.jsonEscape("a\\b"));
        assertEquals("line1\\nline2\\r\\t", Utils.jsonEscape("line1\nline2\r\t"));
        assertEquals("bell\\u0007", Utils.jsonEscape("bell"));
    }

    // --------------------------------------------------- termination notices

    @Test
    public void terminationDateNeedsThirtyDaysAndAtMostAYear() {
        LocalDate today = LocalDate.of(2026, 9, 24);
        assertFalse(Utils.isValidTerminationDate(null, today));
        assertFalse(Utils.isValidTerminationDate(today.plusDays(29), today));
        assertTrue(Utils.isValidTerminationDate(today.plusDays(30), today));
        assertTrue(Utils.isValidTerminationDate(today.plusDays(365), today));
        assertFalse(Utils.isValidTerminationDate(today.plusDays(366), today));
    }

    @Test
    public void noticeCanBeWithdrawnUpToTheCutoffBeforeTheLastDay() {
        LocalDate today = LocalDate.of(2026, 9, 24);
        int cutoff = Utils.NOTICE_WITHDRAWAL_CUTOFF_DAYS;
        assertTrue(Utils.isNoticeWithdrawable(today.plusDays(cutoff + 1), today));
        assertTrue(Utils.isNoticeWithdrawable(today.plusDays(cutoff), today));
        assertFalse(Utils.isNoticeWithdrawable(today.plusDays(cutoff - 1), today));
        assertTrue("no last day recorded", Utils.isNoticeWithdrawable(null, today));
    }

    @Test
    public void withdrawalDeadlineAndDatabaseBoundaryAgree() {
        LocalDate today = LocalDate.of(2026, 9, 24);
        LocalDate lastDay = Utils.earliestWithdrawableLastDay(today);
        assertEquals(today, Utils.lastDayToWithdraw(lastDay));
    }
}
