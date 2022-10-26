FROM openjdk:11

# Required for Android sdkmanager
COPY jaxb_libs /jaxb_libs/

ENV ANDROID_COMPILE_SDK=33
ENV ANDROID_BUILD_TOOLS=33.0.0

#
ENV ANDROID_SDK_TOOLS=https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
ENV FLUTTER=https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.3.5-stable.tar.xz

# Download Android SDK
RUN wget --quiet --output-document=android-sdk-tools.zip ${ANDROID_SDK_TOOLS} \
    && unzip android-sdk-tools.zip -d /opt/android-sdk-linux/ \
    && mkdir /root/.android && touch /root/.android/repositories.cfg \
    && sed -ie 's%^CLASSPATH=.*%\0:/jaxb_libs/istack-commons-runtime-3.0.7.jar:/jaxb_libs/FastInfoset-1.2.15.jar:/jaxb_libs/javax.activation-api-1.2.0.jar:/jaxb_libs/jaxb-api-2.3.1.jar:/jaxb_libs/jaxb-runtime-2.3.1.jar:/jaxb_libs/txw2-2.3.1.jar:/jaxb_libs/stax-ex-1.8.jar%' /opt/android-sdk-linux/tools/bin/sdkmanager /opt/android-sdk-linux/tools/bin/avdmanager \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "platform-tools" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "cmdline-tools;latest" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;android;m2repository" \
    && echo "y" | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;google;m2repository" \
    && yes | /opt/android-sdk-linux/tools/bin/sdkmanager --licenses || echo "Failed" \
    && rm android-sdk-tools.zip

# make SDK tools available for CI
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV PATH=$PATH:/opt/android-sdk-linux/platform-tools/


# Download Flutter SDK
RUN wget --quiet --output-document=flutter.tar.xz ${FLUTTER} \
    && tar xf flutter.tar.xz -C /opt \
    && /opt/flutter/bin/flutter config --no-analytics \
    && /opt/flutter/bin/flutter precache \
    && yes "y" | /opt/flutter/bin/flutter doctor --android-licenses \
    && /opt/flutter/bin/flutter doctor \
    && /opt/flutter/bin/flutter update-packages \
    && rm flutter.tar.xz

# make Flutter available for CI
ENV PATH=$PATH:/opt/flutter/bin
