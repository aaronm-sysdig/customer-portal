<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<!DOCTYPE html>
<html>
<head>
  <title>Acme Financial - Dashboard</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f0f2f5; color: #1a1a2e; }

    .topbar { background: #1a1a2e; color: #fff; padding: 0 32px; height: 56px; display: flex; align-items: center; justify-content: space-between; }
    .logo { display: flex; align-items: center; gap: 12px; font-size: 17px; font-weight: 700; }
    .logo-icon { width: 30px; height: 30px; background: #e63946; border-radius: 6px; display: flex; align-items: center; justify-content: center; font-size: 15px; font-weight: 900; color: #fff; }
    .topbar-right { font-size: 13px; color: #aab4c8; }
    .topbar-right strong { color: #fff; }

    .sidebar { position: fixed; top: 56px; left: 0; width: 220px; height: calc(100vh - 56px); background: #fff; border-right: 1px solid #e2e8f0; padding: 20px 0; overflow-y: auto; }
    .nav-section { padding: 4px 20px 6px; font-size: 10px; font-weight: 700; letter-spacing: 1px; text-transform: uppercase; color: #94a3b8; margin-top: 12px; }
    .nav-item { display: flex; align-items: center; gap: 10px; padding: 9px 20px; font-size: 14px; color: #475569; border-left: 3px solid transparent; cursor: default; }
    .nav-item.active { background: #eff6ff; color: #2563eb; border-left-color: #2563eb; font-weight: 600; }
    .nav-item:not(.active):hover { background: #f8fafc; }
    a.nav-item { text-decoration: none; color: #475569; cursor: pointer; }
    a.nav-item.active { color: #2563eb; }
    table.records { width: 100%; border-collapse: collapse; font-size: 13px; }
    table.records th { text-align: left; padding: 10px 20px; background: #f8fafc; color: #64748b; font-size: 11px; text-transform: uppercase; letter-spacing: .04em; border-bottom: 1px solid #e2e8f0; }
    table.records td { padding: 12px 20px; border-bottom: 1px solid #f1f5f9; color: #1e293b; }
    table.records tr:last-child td { border-bottom: none; }
    .mono { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; }
    .masked { color: #64748b; letter-spacing: .08em; }
    .note { padding: 12px 20px; font-size: 12px; color: #64748b; background: #f8fafc; border-top: 1px solid #f1f5f9; }
    .nav-icon { width: 16px; text-align: center; font-size: 13px; opacity: 0.7; }

    .main { margin-left: 220px; padding: 36px 40px; }
    .page-header { margin-bottom: 28px; }
    .page-header h1 { font-size: 22px; font-weight: 700; }
    .page-header p { font-size: 13px; color: #64748b; margin-top: 4px; }

    .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 28px; }
    .stat { background: #fff; border-radius: 10px; padding: 18px 20px; border: 1px solid #e2e8f0; }
    .stat-label { font-size: 11px; font-weight: 700; text-transform: uppercase; letter-spacing: 0.5px; color: #94a3b8; }
    .stat-value { font-size: 26px; font-weight: 700; color: #1a1a2e; margin-top: 4px; }
    .stat-delta { font-size: 12px; color: #22c55e; margin-top: 2px; }
    .stat-delta.down { color: #ef4444; }

    .row { display: grid; grid-template-columns: 2fr 1fr; gap: 16px; }
    .card { background: #fff; border-radius: 10px; border: 1px solid #e2e8f0; overflow: hidden; }
    .card-header { padding: 16px 20px; border-bottom: 1px solid #f1f5f9; display: flex; align-items: center; justify-content: space-between; }
    .card-header h2 { font-size: 14px; font-weight: 600; }
    .badge { display: inline-block; padding: 2px 8px; border-radius: 99px; font-size: 11px; font-weight: 600; }
    .badge-green { background: #dcfce7; color: #16a34a; }
    .badge-blue { background: #dbeafe; color: #2563eb; }
    .badge-red { background: #fee2e2; color: #dc2626; }

    .activity-item { padding: 12px 20px; border-bottom: 1px solid #f8fafc; display: flex; align-items: center; justify-content: space-between; font-size: 13px; }
    .activity-item:last-child { border-bottom: none; }
    .activity-name { font-weight: 600; color: #1a1a2e; }
    .activity-detail { color: #64748b; font-size: 12px; margin-top: 1px; }
    .activity-time { font-size: 11px; color: #94a3b8; }

    .alert-item { padding: 10px 20px; border-bottom: 1px solid #f8fafc; display: flex; align-items: center; gap: 10px; font-size: 13px; color: #374151; }
    .alert-item:last-child { border-bottom: none; }
    .alert-dot { width: 8px; height: 8px; border-radius: 50%; background: #22c55e; flex-shrink: 0; }

    .redacted { color: #94a3b8; font-style: italic; font-size: 12px; }
  </style>
</head>
<body>

<div class="topbar">
  <div class="logo">
    <div class="logo-icon">A</div>
    Acme Financial Services
  </div>
  <div class="topbar-right">
    <strong>admin</strong> &nbsp;&bull;&nbsp; Customer Portal &nbsp;&bull;&nbsp; Internal Use Only
  </div>
</div>

<div class="sidebar">
  <div class="nav-section">Main</div>
  <a class="nav-item<s:if test="!customerView"> active</s:if>" href="customers.action"><span class="nav-icon">&#9632;</span> Dashboard</a>
  <a class="nav-item<s:if test="customerView"> active</s:if>" href="customers.action?view=customers"><span class="nav-icon">&#9632;</span> Customers</a>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> Accounts</div>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> Transactions</div>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> Cards</div>

  <div class="nav-section">Reports</div>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> Monthly Summary</div>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> Audit Log</div>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> Compliance</div>

  <div class="nav-section">Admin</div>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> User Management</div>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> Settings</div>
  <div class="nav-item"><span class="nav-icon">&#9632;</span> <a href="index.jsp" style="color:inherit;text-decoration:none;">Sign Out</a></div>
</div>

<div class="main">
<s:if test="customerView">
  <div class="page-header">
    <h1>Customers</h1>
    <p><s:property value="rows.size"/> records &mdash; retrieved <%= new java.util.Date() %></p>
  </div>

  <div class="card">
    <div class="card-header">
      <h2>Customer Records</h2>
      <span class="badge badge-green">PCI scope</span>
    </div>
    <table class="records">
      <thead>
        <tr><th>ID</th><th>Name</th><th>Email</th><th>Payment card</th><th>Status</th></tr>
      </thead>
      <tbody>
      <s:iterator value="rows" var="r">
        <tr>
          <td class="mono"><s:property value="#r.id"/></td>
          <td><s:property value="#r.name"/></td>
          <td><s:property value="#r.email"/></td>
          <td class="mono masked">&bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; &bull;&bull;&bull;&bull; <s:property value="#r.cardLast4"/></td>
          <td><span class="badge badge-green">Verified</span></td>
        </tr>
      </s:iterator>
      </tbody>
    </table>
    <div class="note">
      Card numbers are masked in this view. Unmasking requires elevated approval and is recorded in the audit log.
    </div>
  </div>
</s:if>
<s:else>
  <div class="page-header">
    <h1>Dashboard</h1>
    <p>Customer overview &mdash; Last updated: <%= new java.util.Date() %></p>
  </div>

  <div class="stats">
    <div class="stat">
      <div class="stat-label">Total Customers</div>
      <div class="stat-value">8</div>
      <div class="stat-delta">+2 this month</div>
    </div>
    <div class="stat">
      <div class="stat-label">Active Cards</div>
      <div class="stat-value">8</div>
      <div class="stat-delta">All verified</div>
    </div>
    <div class="stat">
      <div class="stat-label">Open Cases</div>
      <div class="stat-value">3</div>
      <div class="stat-delta down">2 pending review</div>
    </div>
    <div class="stat">
      <div class="stat-label">System Status</div>
      <div class="stat-value" style="font-size:18px;padding-top:6px;"><span class="badge badge-green">Operational</span></div>
    </div>
  </div>

  <div class="row">
    <div class="card">
      <div class="card-header">
        <h2>Recent Customer Activity</h2>
        <span class="badge badge-blue">Live</span>
      </div>
      <div class="activity-item">
        <div>
          <div class="activity-name">Alice Hopper</div>
          <div class="activity-detail">Card updated &mdash; <span class="redacted">details restricted</span></div>
        </div>
        <div class="activity-time">2 min ago</div>
      </div>
      <div class="activity-item">
        <div>
          <div class="activity-name">Bilal Rashid</div>
          <div class="activity-detail">Account review completed</div>
        </div>
        <div class="activity-time">18 min ago</div>
      </div>
      <div class="activity-item">
        <div>
          <div class="activity-name">Carmen Diaz</div>
          <div class="activity-detail">KYC documents submitted</div>
        </div>
        <div class="activity-time">1 hr ago</div>
      </div>
      <div class="activity-item">
        <div>
          <div class="activity-name">Deepak Nair</div>
          <div class="activity-detail">New account opened</div>
        </div>
        <div class="activity-time">3 hr ago</div>
      </div>
      <div class="activity-item">
        <div>
          <div class="activity-name">Evelyn Stone</div>
          <div class="activity-detail">Address change request</div>
        </div>
        <div class="activity-time">Yesterday</div>
      </div>
    </div>

    <div class="card">
      <div class="card-header">
        <h2>System Alerts</h2>
        <span class="badge badge-green">All clear</span>
      </div>
      <div class="alert-item"><div class="alert-dot"></div> Database: Connected</div>
      <div class="alert-item"><div class="alert-dot"></div> Auth service: Online</div>
      <div class="alert-item"><div class="alert-dot"></div> Backup: Completed 02:00</div>
      <div class="alert-item"><div class="alert-dot"></div> Encryption: Active</div>
      <div class="alert-item"><div class="alert-dot"></div> Audit logging: Enabled</div>
    </div>
  </div>
</s:else>
</div>

</body>
</html>
