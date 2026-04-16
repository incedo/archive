package archive.adapters.api

import archive.application.intake.command.RegisterDocumentIntakeRequest
import archive.application.intake.query.GetDocumentIngestQuery
import archive.application.intake.result.DocumentIngestResult

object GenericIntakeMapper {
    fun toCommand(request: GenericMultipartIntakePayload): RegisterDocumentIntakeRequest =
        RegisterDocumentIntakeRequest(
            fileName = request.fileName,
            contentType = request.contentType,
            content = request.content,
            documentTypeHint = request.documentTypeHint,
            metadata = request.metadata,
        )

    fun toQuery(documentId: String): GetDocumentIngestQuery =
        GetDocumentIngestQuery(documentId = documentId)

    fun toResponse(result: DocumentIngestResult): GenericDocumentIntakeResponse =
        GenericDocumentIntakeResponse(
            documentId = result.documentId,
            status = result.status.name,
            checksumAlgorithm = result.checksum.algorithm,
            checksumValue = result.checksum.value,
            fileName = result.fileName,
            contentType = result.contentType,
            documentTypeHint = result.documentTypeHint,
            metadata = result.metadata,
        )
}
