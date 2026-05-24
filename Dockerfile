# Stage 1 : Compilation
FROM maven:3.9-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
RUN mvn dependency:go-offline -B
COPY . .
RUN mvn clean package -DskipTests -B

# Stage 2 : Runtime
FROM eclipse-temurin:17-jre-jammy
RUN apt-get update && apt-get install -y --no-install-recommends ghostscript curl fonts-dejavu-core && rm -rf /var/lib/apt/lists/* && fc-cache -f
RUN groupadd -r esup && useradd -r -g esup esup
USER esup
WORKDIR /app
COPY --from=builder --chown=esup:esup /build/target/esup-signature-*.war app.war
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD curl -f http://localhost:8080/actuator/health || exit 1
ENTRYPOINT ["java", "-jar", "app.war"]
