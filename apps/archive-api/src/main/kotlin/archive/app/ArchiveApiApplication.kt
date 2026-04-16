package archive.app

import archive.adapters.api.GenericIntakeMapper
import archive.adapters.api.parseGenericMultipartIntake
import archive.adapters.compat.alfresco.AlfrescoCompatibilityMapper
import archive.adapters.compat.alfresco.parseAlfrescoMultipartIntake
import archive.application.intake.service.DocumentIntakeService
import io.ktor.http.HttpStatusCode
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.application.Application
import io.ktor.server.application.call
import io.ktor.server.application.install
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty
import io.ktor.server.plugins.calllogging.CallLogging
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation
import io.ktor.server.response.respond
import io.ktor.server.routing.get
import io.ktor.server.routing.post
import io.ktor.server.routing.routing

fun main() {
    embeddedServer(Netty, port = 8080, module = Application::archiveModule).start(wait = true)
}

fun Application.archiveModule() {
    val service = DocumentIntakeService(
        checksumService = Sha256ChecksumService(),
        eventStore = InMemoryEventStore(),
        repository = InMemoryDocumentIngestViewRepository(),
    )

    install(CallLogging)
    install(ContentNegotiation) {
        json()
    }

    routing {
        post("/api/v1/documents/intake") {
            val request = parseGenericMultipartIntake(call)
            val view = service.register(GenericIntakeMapper.toCommand(request))
            call.respond(HttpStatusCode.Created, GenericIntakeMapper.toResponse(view))
        }

        post("/alfresco/api/-default-/public/alfresco/versions/1/nodes/-root-/children") {
            val request = parseAlfrescoMultipartIntake(call)
            val genericRequest = AlfrescoCompatibilityMapper.toGenericRequest(request)
            val view = service.register(GenericIntakeMapper.toCommand(genericRequest))
            call.respond(HttpStatusCode.Created, AlfrescoCompatibilityMapper.toCompatibilityResponse(view))
        }

        get("/api/v1/documents/{id}/ingest") {
            val documentId = requireNotNull(call.parameters["id"]) { "document id is required" }
            val view = service.get(documentId)
            if (view == null) {
                call.respond(HttpStatusCode.NotFound)
            } else {
                call.respond(GenericIntakeMapper.toResponse(view))
            }
        }
    }
}
