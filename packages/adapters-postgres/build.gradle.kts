plugins {
    kotlin("jvm")
    kotlin("plugin.serialization")
}

dependencies {
    implementation(project(":packages:domain"))
    implementation(project(":packages:ports"))
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.9.0")

    runtimeOnly("org.postgresql:postgresql:42.7.7")

    testImplementation(kotlin("test"))
    testImplementation("com.h2database:h2:2.3.232")
}
