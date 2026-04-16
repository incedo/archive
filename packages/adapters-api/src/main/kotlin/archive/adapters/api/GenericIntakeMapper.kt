package archive.adapters.api

import archive.application.intake.command.RegisterDocumentIntakeRequest
import archive.application.intake.query.GetDocumentIngestQuery
import archive.ports.readmodel.DocumentIngestView

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

    fun toResponse(view: DocumentIngestView): GenericDocumentIntakeResponse =
        GenericDocumentIntakeResponse(
            documentId = view.documentId,
            status = view.status.name,
            checksumAlgorithm = view.checksum.algorithm,
            checksumValue = view.checksum.value,
            fileName = view.fileName,
            contentType = view.contentType,
            documentTypeHint = view.documentTypeHint,
            metadata = view.metadata,
        )
}
