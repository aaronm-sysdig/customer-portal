package com.acme;

import com.opensymphony.xwork2.ActionSupport;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class CustomerAction extends ActionSupport {

    /** Which panel to render: null/anything for the dashboard, "customers" for the record list. */
    private String view;

    private List<String> customers = new ArrayList<>();
    private final List<Row> rows = new ArrayList<>();

    /** One customer record as shown in the Customers view. */
    public static class Row {
        private final int id;
        private final String name;
        private final String email;
        private final String card;

        Row(int id, String name, String email, String card) {
            this.id = id;
            this.name = name;
            this.email = email;
            this.card = card;
        }

        public int getId() { return id; }
        public String getName() { return name; }
        public String getEmail() { return email; }

        /**
         * Last four digits only. Card numbers are never rendered in full in the
         * portal; the view shows a masked value built from this.
         */
        public String getCardLast4() {
            if (card == null || card.length() < 4) {
                return "----";
            }
            return card.substring(card.length() - 4);
        }
    }

    @Override
    public String execute() {
        String host = env("PGHOST", "postgres");
        String db = env("PGDATABASE", "customers");
        String user = env("PGUSER", "portal");
        String pass = env("DB_PASSWORD", "");
        String url = "jdbc:postgresql://" + host + ":5432/" + db;
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException ignored) {}
        try (Connection c = DriverManager.getConnection(url, user, pass);
             Statement s = c.createStatement();
             ResultSet rs = s.executeQuery("SELECT id, name, email, card FROM customers ORDER BY id")) {
            while (rs.next()) {
                rows.add(new Row(rs.getInt(1), rs.getString(2), rs.getString(3), rs.getString(4)));
                customers.add(rs.getString(2) + " <" + rs.getString(3) + ">");
            }
        } catch (Exception e) {
            customers.add("DB error: " + e.getMessage());
        }
        return SUCCESS;
    }

    private static String env(String key, String dflt) {
        String v = System.getenv(key);
        return v != null ? v : dflt;
    }

    public void setView(String view) { this.view = view; }
    public String getView() { return view; }

    public List<String> getCustomers() { return customers; }
    public List<Row> getRows() { return rows; }

    /** True when the Customers view was requested. */
    public boolean isCustomerView() { return "customers".equals(view); }
}
