plugins {
    kotlin("jvm")
}

dependencies {
    implementation(project(":packages:domain"))
    implementation(project(":packages:ports"))
}
