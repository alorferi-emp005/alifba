FROM gradle:8.9-jdk17 AS build

# Set environment variables
ENV ANDROID_SDK_ROOT=/opt/android-sdk

# Ensure JAVA_HOME is set to the correct location (check java installation)
RUN echo "Checking Java version..." && java -version
RUN echo "JAVA_HOME: $JAVA_HOME"

# Install Java explicitly if needed
RUN apt-get update && apt-get install -y openjdk-17-jdk

# Set JAVA_HOME to the correct location after installation
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$JAVA_HOME/bin

# Ensure Gradle uses the correct Java version
ENV GRADLE_OPTS="-Dorg.gradle.java.home=$JAVA_HOME"

# Install dependencies
RUN apt-get install -y wget unzip libgl1-mesa-dev

# Install Android SDK Command Line Tools
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    cd $ANDROID_SDK_ROOT/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip -d temp && \
    mv temp/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm -rf cmdline-tools.zip temp

# Verify if sdkmanager works by printing its version
RUN sdkmanager --version

# Accept licenses and install required SDK packages
RUN yes | sdkmanager --licenses
RUN sdkmanager --update
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"

# Set the working directory
WORKDIR /workspace

# Copy everything into the Docker image
COPY . .

# Ensure correct Gradle version is used
RUN gradle --version

# Build the app
RUN ./gradlew clean build

# Default command
CMD ["./gradlew", "assembleDebug"]
