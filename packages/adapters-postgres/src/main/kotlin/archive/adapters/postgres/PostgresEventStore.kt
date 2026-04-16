package archive.adapters.postgres

import archive.domain.intake.event.DomainEvent
import archive.ports.eventstore.EventStore
import java.sql.Statement

class PostgresEventStore(
    private val connectionFactory: JdbcConnectionFactory,
    private val codec: DomainEventJsonCodec = DomainEventJsonCodec(),
) : EventStore {
    override fun append(events: List<DomainEvent>) {
        if (events.isEmpty()) return

        connectionFactory.open().use { connection ->
            connection.autoCommit = false
            try {
                events.forEach { event ->
                    val eventId = connection.prepareStatement(
                        """
                        insert into archive_events (event_type, aggregate_id, payload_json)
                        values (?, ?, ?)
                        """.trimIndent(),
                        Statement.RETURN_GENERATED_KEYS,
                    ).use { statement ->
                        statement.setString(1, codec.eventType(event))
                        statement.setString(2, codec.aggregateId(event))
                        statement.setString(3, codec.encode(event))
                        statement.executeUpdate()
                        statement.generatedKeys.use { keys ->
                            check(keys.next()) { "archive_events insert did not return a generated key" }
                            keys.getLong(1)
                        }
                    }

                    connection.prepareStatement(
                        """
                        insert into archive_event_tags (event_id, tag)
                        values (?, ?)
                        """.trimIndent()
                    ).use { statement ->
                        event.tags.forEach { tag ->
                            statement.setLong(1, eventId)
                            statement.setString(2, tag)
                            statement.addBatch()
                        }
                        statement.executeBatch()
                    }
                }
                connection.commit()
            } catch (ex: Exception) {
                connection.rollback()
                throw ex
            } finally {
                connection.autoCommit = true
            }
        }
    }
}
