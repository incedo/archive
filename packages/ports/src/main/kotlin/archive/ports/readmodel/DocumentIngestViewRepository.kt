package archive.ports.readmodel

interface DocumentIngestViewRepository {
    fun save(view: DocumentIngestView)
    fun findById(documentId: String): DocumentIngestView?
}
