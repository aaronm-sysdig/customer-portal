# Build stage: compile the WAR. Needs network access for the Maven repo.
FROM maven:3.6.3-amazoncorretto-8 AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

# Runtime stage: Tomcat 8.5 on JRE 8, matching the servlet 3.1 / JSP 2.3 levels
# the app is compiled against.
FROM tomcat:8.5.99-jre8-temurin
LABEL org.opencontainers.image.source="https://github.com/aaronm-sysdig/customer-portal"
LABEL org.opencontainers.image.title="customer-portal"
LABEL org.opencontainers.image.description="Internal customer administration portal for Acme Financial Services"
# psql is baked in so the on-call runbook's connectivity checks work inside the
# pod without installing anything at runtime.
# libbrotli1 is listed so apt upgrades it past the base image's 1.0.9-2build6
# (CVE-2026-111497, fixed in 1.0.9-2ubuntu0.1).
RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client libbrotli1 \
    && rm -rf /var/lib/apt/lists/*
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /src/target/customer-portal.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
