FROM gradle:8.9-jdk17 AS build

# Set environment variables
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV PATH "${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/emulator"

# Install required dependencies
RUN apt-get update && apt-get install -y \
    unzip \
    wget \
    git \
    libgl1-mesa-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install Android Command Line Tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O tools.zip && \
    unzip tools.zip -d latest && \
    rm tools.zip

# Accept licenses and install SDK packages
RUN yes | sdkmanager --licenses
RUN sdkmanager --update
RUN sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0" "emulator" "cmdline-tools;latest"

# Set working directory and copy project files
WORKDIR /workspace
COPY . .

# Build the project
RUN ./gradlew clean build

CMD ["./gradlew", "assembleDebug"]
