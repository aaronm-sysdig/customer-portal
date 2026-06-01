# customer-portal

Internal customer administration portal for Acme Financial Services. Service
desk and back-office staff use it to look up customer records and check account
status without going direct to the database.

It is a small Struts 2 web application packaged as a WAR and deployed on Tomcat.
There is no public route to it; access is via the internal network only.

## What it does

- Sign-in page (`index.jsp`) as the entry point.
- `customers.action` reads the customer table and renders the admin dashboard
  (`customers.jsp`) with the most recent records and a summary panel.
- Data comes from the `customers` table in the shared Postgres instance. The
  portal is read-only against that table today.

## Layout

```
pom.xml                                     Maven build, WAR packaging
Dockerfile                                  two-stage build (Maven -> Tomcat)
src/main/java/com/acme/CustomerAction.java  customer lookup action
src/main/resources/struts.xml               action mappings
src/main/webapp/index.jsp                   sign-in page
src/main/webapp/customers.jsp               admin dashboard
src/main/webapp/WEB-INF/web.xml             servlet filter + welcome file
```

## Build

Requires JDK 8 and Maven 3.6+.

```sh
mvn package
```

The WAR lands at `target/customer-portal.war`. Drop it into a Tomcat 8.5
`webapps/` directory as `ROOT.war` if you want to run it against a local Tomcat
rather than in a container.

## Container image

The `Dockerfile` builds the WAR in a Maven stage and copies it into a Tomcat
runtime stage, so nothing but the WAR crosses between them. The runtime image
also carries `postgresql-client`, which the on-call runbook uses for
connectivity checks from inside the pod.

```sh
docker build -t customer-portal:local .
docker run --rm -p 8080:8080 \
  -e PGHOST=postgres.internal \
  -e PGDATABASE=customers \
  -e PGUSER=portal \
  -e DB_PASSWORD="$DB_PASSWORD" \
  customer-portal:local
```

Then open http://localhost:8080/.

## Configuration

All database configuration is read from the environment at request time (see
`env()` in `CustomerAction.java`). Nothing is read from a properties file.

| Variable      | Default     | Notes                                      |
| ------------- | ----------- | ------------------------------------------ |
| `PGHOST`      | `postgres`  | Postgres hostname. Port is fixed at 5432.  |
| `PGDATABASE`  | `customers` | Database name.                             |
| `PGUSER`      | `portal`    | Role the portal connects as.               |
| `DB_PASSWORD` | empty       | Password for `PGUSER`. Supplied per env.   |

The defaults are the in-cluster service names, so a deployment normally only
needs to set `DB_PASSWORD`. If a connection cannot be established the dashboard
renders the driver's error text in place of the customer list, which is
deliberate - it makes misconfigured environments obvious on first load.

## Running against a local Postgres

```sh
docker run --rm -d --name portal-db \
  -e POSTGRES_USER=portal \
  -e POSTGRES_PASSWORD=portal \
  -e POSTGRES_DB=customers \
  -p 5432:5432 postgres:14
```

Create the table and a couple of rows:

```sql
CREATE TABLE customers (
  id    SERIAL PRIMARY KEY,
  name  TEXT NOT NULL,
  email TEXT NOT NULL
);
INSERT INTO customers (name, email) VALUES
  ('Alice Hopper', 'alice.hopper@example.com'),
  ('Bilal Rashid', 'bilal.rashid@example.com');
```

Then run the container with `PGHOST=host.docker.internal` and
`DB_PASSWORD=portal`.

## Notes for maintainers

- The action holds no state between requests; each call opens a connection,
  reads at most five rows, and closes it. Add a pool before increasing that
  limit.
- `struts.devMode` is off in `struts.xml`. Turn it on locally if you need the
  full stack traces, but do not commit it enabled.
- The dashboard's summary tiles are static markup. They are placeholders until
  the reporting endpoint exists.
