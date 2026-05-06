# Build stage: compile the WAR. Needs network access for the Maven repo.
FROM maven:3.6.3-amazoncorretto-8 AS build
WORKDIR /src
COPY pom.xml .
COPY src ./src
RUN mvn -q -DskipTests package

# Runtime stage: Tomcat 8.5 on JRE 8, matching the servlet 3.1 / JSP 2.3 levels
# the app is compiled against.
FROM tomcat:8.5.99-jre8-temurin
# psql is baked in so the on-call runbook's connectivity checks work inside the
# pod without installing anything at runtime.
RUN apt-get update \
    && apt-get install -y --no-install-recommends postgresql-client \
    && rm -rf /var/lib/apt/lists/*
RUN rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /src/target/customer-portal.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
