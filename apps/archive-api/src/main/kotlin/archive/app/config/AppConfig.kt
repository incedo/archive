package archive.app.config

class AppConfig(
    val jdbcUrl: String? = readSetting("ARCHIVE_JDBC_URL"),
    val jdbcUser: String? = readSetting("ARCHIVE_JDBC_USER"),
    val jdbcPassword: String? = readSetting("ARCHIVE_JDBC_PASSWORD"),
    val port: Int = readSetting("ARCHIVE_PORT")?.toIntOrNull() ?: 8080,
) {
    companion object {
        private fun readSetting(name: String): String? =
            System.getenv(name)?.takeIf { it.isNotBlank() }
                ?: System.getProperty(name)?.takeIf { it.isNotBlank() }
    }
}
