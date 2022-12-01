# docker-flutter-builder-android

Docker image to build Flutter Android application

## .gitlab-ci.yml
```
image: babasattva/flutter-builder-android:3.3.5

stages:
  - build

build:android:
  only:
    - merge_request
  stage: build
  before_script:
    - cd app
  script:
    - flutter pub get
    - flutter packages pub run build_runner build --delete-conflicting-outputs
    - flutter build apk --no-tree-shake-icons
  artifacts:
    paths:
      - app/build/app/outputs/apk/release/app-release.apk
```
