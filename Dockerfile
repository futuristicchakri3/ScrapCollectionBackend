# ==============================================================================
# SCRAP COLLECTION PLATFORM — RENDER DOCKERFILE (JAVA 21)
# ==============================================================================

# Stage 1: Build the Spring Boot application using Maven and Java 21
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app

# Cache dependencies first
COPY pom.xml .
RUN mvn dependency:go-offline -B || true

# Copy source code and build production package
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Minimal Java 21 runtime
FROM eclipse-temurin:21-jre
WORKDIR /app

# Create uploads directory for local file attachments if needed
RUN mkdir -p /app/uploads

# Copy the compiled JAR artifact from builder
COPY --from=build /app/target/*.jar app.jar

# Render standard port (Render injects  at runtime, defaults to 10000)
EXPOSE 10000

# Run Spring Boot honoring Render's dynamic  environment variable
ENTRYPOINT [ sh, -c, java -Dserver .port= -jar app.jar]
