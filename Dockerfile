FROM eclipse-temurin:21-jdk-jammy AS build

WORKDIR /workspace

COPY gradlew gradlew.bat settings.gradle.kts build.gradle.kts gradle.properties ./
COPY gradle ./gradle
COPY packages ./packages
COPY apps ./apps

RUN ./gradlew --no-daemon :apps:archive-api:installDist

FROM eclipse-temurin:21-jre-jammy AS runtime

ENV ARCHIVE_PORT=8080
WORKDIR /app

RUN useradd --create-home --shell /usr/sbin/nologin --uid 10001 archive

COPY --from=build /workspace/apps/archive-api/build/install/archive-api /app

USER archive
EXPOSE 8080

ENTRYPOINT ["/app/bin/archive-api"]

