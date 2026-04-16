package archive.app

import archive.adapters.api.GenericIntakeMapper
import archive.adapters.api.ErrorResponse
import archive.adapters.api.parseGenericMultipartIntake
import archive.adapters.compat.alfresco.AlfrescoCompatibilityMapper
import archive.adapters.compat.alfresco.parseAlfrescoMultipartIntake
import archive.adapters.postgres.JdbcConnectionFactory
import archive.adapters.postgres.PostgresDocumentIngestViewRepository
import archive.adapters.postgres.PostgresEventStore
import archive.adapters.postgres.PostgresSchemaInitializer
import archive.application.intake.command.RegisterDocumentIntakeHandler
import archive.application.intake.query.GetDocumentIngestQueryHandler
import io.ktor.http.HttpStatusCode
import io.ktor.serialization.kotlinx.json.json
import io.ktor.server.application.Application
import io.ktor.server.application.call
import io.ktor.server.application.install
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty
import io.ktor.server.plugins.calllogging.CallLogging
import io.ktor.server.plugins.contentnegotiation.ContentNegotiation
import io.ktor.server.plugins.statuspages.StatusPages
import io.ktor.server.response.respond
import io.ktor.server.routing.get
import io.ktor.server.routing.post
import io.ktor.server.routing.routing

fun main() {
    embeddedServer(Netty, port = 8080, module = Application::archiveModule).start(wait = true)
}

private data class PersistenceAdapters(
    val eventStore: archive.ports.eventstore.EventStore,
    val repository: archive.ports.readmodel.DocumentIngestViewRepository,
)

private fun readSetting(name: String): String? =
    System.getenv(name)?.takeIf { it.isNotBlank() }
        ?: System.getProperty(name)?.takeIf { it.isNotBlank() }

private fun createPersistenceAdapters(): PersistenceAdapters {
    val jdbcUrl = readSetting("ARCHIVE_JDBC_URL")
    if (jdbcUrl == null) {
        return PersistenceAdapters(
            eventStore = InMemoryEventStore(),
            repository = InMemoryDocumentIngestViewRepository(),
        )
    }

    val connectionFactory = JdbcConnectionFactory(
        jdbcUrl = jdbcUrl,
        username = readSetting("ARCHIVE_JDBC_USER"),
        password = readSetting("ARCHIVE_JDBC_PASSWORD"),
    )
    PostgresSchemaInitializer(connectionFactory).initialize()

    return PersistenceAdapters(
        eventStore = PostgresEventStore(connectionFactory),
        repository = PostgresDocumentIngestViewRepository(connectionFactory),
    )
}

fun Application.archiveModule() {
    val persistence = createPersistenceAdapters()
    val registerDocumentIntakeHandler = RegisterDocumentIntakeHandler(
        checksumService = Sha256ChecksumService(),
        eventStore = persistence.eventStore,
        repository = persistence.repository,
    )
    val getDocumentIngestQueryHandler = GetDocumentIngestQueryHandler(
        eventStore = persistence.eventStore,
        repository = persistence.repository,
    )

    install(CallLogging)
    install(ContentNegotiation) {
        json()
    }
    install(StatusPages) {
        exception<IllegalArgumentException> { call, cause ->
            call.respond(HttpStatusCode.BadRequest, ErrorResponse(cause.message ?: "invalid request"))
        }
    }

    routing {
        post("/api/v1/documents/intake") {
            val request = parseGenericMultipartIntake(call)
            val view = registerDocumentIntakeHandler.handle(GenericIntakeMapper.toCommand(request))
            call.respond(HttpStatusCode.Created, GenericIntakeMapper.toResponse(view))
        }

        post("/alfresco/api/-default-/public/alfresco/versions/1/nodes/-root-/children") {
            val request = parseAlfrescoMultipartIntake(call)
            val genericRequest = AlfrescoCompatibilityMapper.toGenericRequest(request)
            val view = registerDocumentIntakeHandler.handle(GenericIntakeMapper.toCommand(genericRequest))
            call.respond(HttpStatusCode.Created, AlfrescoCompatibilityMapper.toCompatibilityResponse(view))
        }

        get("/api/v1/documents/{id}/ingest") {
            val documentId = requireNotNull(call.parameters["id"]) { "document id is required" }
            val view = getDocumentIngestQueryHandler.handle(GenericIntakeMapper.toQuery(documentId))
            if (view == null) {
                call.respond(HttpStatusCode.NotFound)
            } else {
                call.respond(GenericIntakeMapper.toResponse(view))
            }
        }
    }
}
