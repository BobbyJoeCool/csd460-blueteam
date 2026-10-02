package com.moffatbaymarina.marinawebsite.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

import com.moffatbaymarina.marinawebsite.dao.AccountDataDAO;
import com.moffatbaymarina.marinawebsite.util.CustomerSession;
import com.moffatbaymarina.marinawebsite.util.DBConnection;
import com.moffatbaymarina.marinawebsite.util.Utils;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * "Download my data" on Your Account (issue #337): sends the signed-in
 * customer a JSON file of everything the site holds about them - their
 * details, boats, reservations and notices, wait list entries and
 * contact-form messages. The Privacy Policy describes this file, so keep
 * the two in step.
 *
 * <p>A GET, since it changes nothing. Another site can make a browser
 * request this address, but it can't read the answer, so no CSRF token is
 * needed. Under /editProfile/*, so NoStoreFilter stops the browser keeping
 * a copy.
 *
 * <p>JSON because it's readable in any text editor and by other software,
 * which is what a data-portability request asks for.
 *
 * @author Miguel Fernandez
 * Blue Team - Robert Breutzmann, Miguel Fernandez, Carolina Rodriguez, Sara White
 * Primary Author/Owner - Miguel Fernandez
 */
@WebServlet("/editProfile/data")
public class AccountDataServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    private final AccountDataDAO accountDataDAO = new AccountDataDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Integer customerId = Utils.signedInCustomerId(request);
        if (customerId == null) {
            CustomerSession.sendToSignIn(request, response, "/editProfile");
            return;
        }

        StringBuilder json = new StringBuilder();
        try (Connection conn = DBConnection.getConnection()) {
            List<Map<String, Object>> account = accountDataDAO.account(conn, customerId);

            json.append("{\n");
            field(json, "exportedOn", LocalDate.now().toString()).append(",\n");
            field(json, "from", "Moffat Bay Marina").append(",\n");
            json.append("  \"account\": ");
            object(json, account.isEmpty() ? Map.of() : account.get(0), "  ");
            json.append(",\n");
            section(json, "boats", accountDataDAO.boats(conn, customerId)).append(",\n");
            section(json, "reservations", accountDataDAO.reservations(conn, customerId)).append(",\n");
            section(json, "waitList", accountDataDAO.waitList(conn, customerId)).append(",\n");
            section(json, "contactMessages", accountDataDAO.contactMessages(conn, customerId)).append("\n");
            json.append("}\n");
        } catch (SQLException e) {
            throw new ServletException("Account data export failed.", e);
        }

        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json");
        response.setHeader("Content-Disposition",
                "attachment; filename=\"moffat-bay-marina-my-data.json\"");

        PrintWriter out = response.getWriter();
        out.write(json.toString());
    }

    /** {@code  "name": "value"} at the top level. */
    private static StringBuilder field(StringBuilder json, String name, String value) {
        return json.append("  \"").append(name).append("\": \"")
                   .append(Utils.jsonEscape(value)).append('"');
    }

    /** {@code  "name": [ {...}, {...} ]} at the top level. */
    private static StringBuilder section(StringBuilder json, String name, List<Map<String, Object>> rows) {
        json.append("  \"").append(name).append("\": [");
        for (int i = 0; i < rows.size(); i++) {
            json.append(i == 0 ? "\n    " : ",\n    ");
            object(json, rows.get(i), "    ");
        }
        return json.append(rows.isEmpty() ? "]" : "\n  ]");
    }

    /** One row as a JSON object, a field per line. */
    private static void object(StringBuilder json, Map<String, Object> row, String indent) {
        if (row.isEmpty()) {
            json.append("{}");
            return;
        }
        json.append("{");
        boolean first = true;
        for (Map.Entry<String, Object> entry : row.entrySet()) {
            json.append(first ? "\n" : ",\n").append(indent).append("  \"")
                .append(Utils.jsonEscape(entry.getKey())).append("\": ");
            value(json, entry.getValue());
            first = false;
        }
        json.append('\n').append(indent).append('}');
    }

    /**
     * Numbers and true/false as themselves, missing values as null, and
     * everything else as a string. Dates come out as 2026-10-02 and times as
     * 2026-10-02T14:30, whichever type the driver hands back.
     */
    private static void value(StringBuilder json, Object value) {
        if (value == null) {
            json.append("null");
        } else if (value instanceof Number || value instanceof Boolean) {
            json.append(value);
        } else {
            String text;
            if (value instanceof java.sql.Date date) {
                text = date.toLocalDate().toString();
            } else if (value instanceof Timestamp time) {
                text = time.toLocalDateTime().toString();
            } else {
                text = value.toString();
            }
            json.append('"').append(Utils.jsonEscape(text)).append('"');
        }
    }
}
