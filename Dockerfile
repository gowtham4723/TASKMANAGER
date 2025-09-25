# Base image with JDK 17
FROM openjdk:17-jdk-slim

# Build-time argument
ARG APP_HOME=/usr/src/app

# Set environment variables
ENV JAVA_OPTS="-Xms512m -Xmx1024m" \
    SPRING_PROFILES_ACTIVE=prod

# Set working directory
WORKDIR ${APP_HOME}

# Copy extra configs if any (optional)
ADD config/ ./config/

# Copy the JAR artifact
COPY target/taskmanager-0.0.1-SNAPSHOT.jar app.jar

# Create non-root user and switch to it
RUN useradd -m appuser
USER appuser

# Expose application port
EXPOSE 8080

# Default command
CMD ["java", "-jar", "app.jar"]

# Entrypoint
ENTRYPOINT ["java", "-jar", "app.jar"]
