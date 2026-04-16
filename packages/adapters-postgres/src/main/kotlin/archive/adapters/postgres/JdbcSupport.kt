package archive.adapters.postgres

import java.sql.Connection
import java.sql.DriverManager

class JdbcConnectionFactory(
    private val jdbcUrl: String,
    private val username: String?,
    private val password: String?,
) {
    fun open(): Connection =
        if (username.isNullOrBlank()) {
            DriverManager.getConnection(jdbcUrl)
        } else {
            DriverManager.getConnection(jdbcUrl, username, password)
        }
}
