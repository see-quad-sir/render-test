# STAGE 1: Build the application using Gradle
# Using a -focal image which is glibc based
FROM gradle:8.14.3-jdk21 AS build

WORKDIR /app

# Copy only the necessary build files and wrapper to leverage Docker cache
COPY build.gradle settings.gradle gradlew /app/
COPY gradle /app/gradle

# Make the Gradle wrapper executable
RUN chmod +x ./gradlew

# Download dependencies. This layer is cached as long as build.gradle doesn't change.
RUN ./gradlew dependencies

# Copy the source code
COPY src /app/src

# Build the application. The output JAR will be in build/libs/
RUN ./gradlew bootJar

# STAGE 2: Create the final, smaller image
# Using a JRE image for running the application, not a full JDK
# Using a -focal (glibc) image for better compatibility than Alpine (musl)
FROM eclipse-temurin:21-jre-alpine AS final

# Create a non-root user and group for security
RUN addgroup --system spring && adduser --system --ingroup spring spring
USER spring

WORKDIR /app

# Copy the built JAR from the build stage
# Using the specific JAR name is more robust than a wildcard
COPY --from=build /app/build/libs/render-test-0.0.1-SNAPSHOT.jar app.jar

# Expose the port the application will run on (for documentation)
EXPOSE 8080

# Command to run the application
# The application itself must be configured to listen on the PORT env var from Render.
CMD ["java", "-jar", "app.jar"]
