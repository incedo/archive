package archive.adapters.postgres

import archive.domain.intake.model.Checksum
import archive.domain.intake.model.DocumentMetadata
import archive.domain.intake.model.IngestStatus
import archive.ports.readmodel.DocumentIngestView
import archive.ports.readmodel.DocumentIngestViewRepository

class PostgresDocumentIngestViewRepository(
    private val connectionFactory: JdbcConnectionFactory,
) : DocumentIngestViewRepository {
    override fun save(view: DocumentIngestView) {
        connectionFactory.open().use { connection ->
            connection.autoCommit = false
            try {
                val updated = connection.prepareStatement(
                    """
                    update document_ingest_views
                    set status = ?,
                        checksum_algorithm = ?,
                        checksum_value = ?,
                        file_name = ?,
                        content_type = ?,
                        document_type_hint = ?,
                        source_system = ?,
                        business_key = ?
                    where document_id = ?
                    """.trimIndent()
                ).use { statement ->
                    statement.setString(1, view.status.name)
                    statement.setString(2, view.checksum.algorithm)
                    statement.setString(3, view.checksum.value)
                    statement.setString(4, view.fileName)
                    statement.setString(5, view.contentType)
                    statement.setString(6, view.documentTypeHint)
                    statement.setString(7, view.metadata.sourceSystem)
                    statement.setString(8, view.metadata.businessKey)
                    statement.setString(9, view.documentId)
                    statement.executeUpdate()
                }

                if (updated == 0) {
                    connection.prepareStatement(
                        """
                        insert into document_ingest_views (
                            document_id,
                            status,
                            checksum_algorithm,
                            checksum_value,
                            file_name,
                            content_type,
                            document_type_hint,
                            source_system,
                            business_key
                        ) values (?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """.trimIndent()
                    ).use { statement ->
                        statement.setString(1, view.documentId)
                        statement.setString(2, view.status.name)
                        statement.setString(3, view.checksum.algorithm)
                        statement.setString(4, view.checksum.value)
                        statement.setString(5, view.fileName)
                        statement.setString(6, view.contentType)
                        statement.setString(7, view.documentTypeHint)
                        statement.setString(8, view.metadata.sourceSystem)
                        statement.setString(9, view.metadata.businessKey)
                        statement.executeUpdate()
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

    override fun findById(documentId: String): DocumentIngestView? =
        connectionFactory.open().use { connection ->
            connection.prepareStatement(
                """
                select document_id,
                       status,
                       checksum_algorithm,
                       checksum_value,
                       file_name,
                       content_type,
                       document_type_hint,
                       source_system,
                       business_key
                from document_ingest_views
                where document_id = ?
                """.trimIndent()
            ).use { statement ->
                statement.setString(1, documentId)
                statement.executeQuery().use { rs ->
                    if (!rs.next()) return null

                    DocumentIngestView(
                        documentId = rs.getString("document_id"),
                        status = IngestStatus.valueOf(rs.getString("status")),
                        checksum = Checksum(
                            algorithm = rs.getString("checksum_algorithm"),
                            value = rs.getString("checksum_value"),
                        ),
                        fileName = rs.getString("file_name"),
                        contentType = rs.getString("content_type"),
                        documentTypeHint = rs.getString("document_type_hint"),
                        metadata = DocumentMetadata(
                            sourceSystem = rs.getString("source_system"),
                            businessKey = rs.getString("business_key"),
                        ),
                    )
                }
            }
        }
}
