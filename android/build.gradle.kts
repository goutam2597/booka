allprojects {
    repositories {
        google()
        mavenCentral()
        // Flutter engine artifacts (for io.flutter:flutter_embedding_*)
        maven(url = uri("https://storage.googleapis.com/download.flutter.io"))
        // PhonePe maven repositories (scoped)
        maven(url = uri("https://phonepe.jfrog.io/artifactory/maven")) {
            content { includeGroup("phonepe.intentsdk.android.release") }
        }
        maven(url = uri("https://phonepe.jfrog.io/artifactory/libs-release-local")) {
            content { includeGroup("phonepe.intentsdk.android.release") }
        }
        // Optional offline fallback: local Maven directory
        maven(url = uri("${rootDir}/maven-local")) {
            content { includeGroup("phonepe.intentsdk.android.release") }
        }
        flatDir {
            dirs(file("app/libs"))
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
