# IBOW — Iberia Ops Weather

App iOS (SwiftUI) para consultar el **METAR** de uno o varios aeropuertos por código ICAO y **leerlo grupo a grupo**:
tocas un fragmento del informe (`27015G25KT`, `FEW013`, `Q1024`…) y la app explica qué significa.

Prueba técnica para Iberia · Swift 6 · iOS 26+ · Xcode 27 · sin dependencias de terceros.

## API elegida

[NOAA Aviation Weather Center](https://aviationweather.gov/data/api/) — endpoint público, sin clave:

```
GET https://aviationweather.gov/api/data/metar?ids=LEMD,LEBL&format=json
```

Elegida por estar directamente relacionada con la operación aérea, ser gratuita y devolver datos reales y
variados (viento, visibilidad, nubes, fenómenos, categoría de vuelo). Los DTO decodifican de forma **tolerante**
(`"visib":"6+"`, `"wdir":"VRB"`, números como texto, nulos) y un campo ilegible no rompe toda la respuesta.

## Cómo ejecutarla

1. Abre `IBOW.xcodeproj` con **Xcode 27** y elige un simulador iPhone o iPad con iOS 26+.
2. ⌘R para ejecutar, ⌘U para lanzar todos los tests.
3. Sin Xcode (solo lógica): `cd Packages/IBOWKit && swift test`.

## Qué hace

- **Búsqueda**: uno o varios códigos separados por comas, con sugerencias rápidas.
- **Detalle**: tarjeta de resumen con icono del tiempo, lector interactivo del METAR, rosa de los vientos,
  visibilidad, nubes, temperatura/rocío y QNH.
- **Antigüedad del METAR**: «Observado a las 16:30 UTC · hace 12 min», que se actualiza cada minuto.
- **Favoritos**: estrella en el detalle y pestaña propia, persistidos con SwiftData.
- Pull-to-refresh, estados vacío / cargando / error con mensajes en lenguaje natural.

## Arquitectura

Clean/Hexagonal con MVVM en presentación. Un único paquete SPM local (`Packages/IBOWKit`) con **varios targets**,
de modo que **el compilador impide** las dependencias que no deben existir.

```
 IBOW (app)  ── raíz de composición: único sitio que conoce todos los tipos concretos
   ├─ FavoritesFeature ┐
   ├─ SearchFeature ─┐
   ├─ DetailFeature ─┼─► WeatherPresentation ─► DesignSystem
   │                 └─► WeatherDomain ◄── WeatherData  (HTTP · DTO · caché)
```

| Target | Responsabilidad | Depende de |
|---|---|---|
| `WeatherDomain` | Entidades, puerto `WeatherRepository`, casos de uso, tokenizador de METAR | nada |
| `WeatherData` | Cliente HTTP, DTO, repositorio remoto, caché TTL, favoritos en SwiftData (`@ModelActor`) | Domain |
| `DesignSystem` | Tokens, Manrope, componentes de cristal | nada |
| `WeatherPresentation` | Textos (incl. VoiceOver), explicador de grupos METAR, icono del tiempo | Domain, DesignSystem |
| `SearchFeature` / `DetailFeature` / `FavoritesFeature` | Pantallas (Favoritos incluye el estado compartido de la estrella) | Domain, Presentation, DesignSystem |

### Decisiones

**MVVM con `@Observable`.** La lógica con estado y concurrencia vive en view models (`SearchViewModel`,
`FavoritesViewModel`) que dependen de puertos del dominio y se prueban sin UI. Las vistas son simples:
el detalle recibe un `Metar` y los callbacks que necesita. El alcance es pequeño y MVVM nativo basta,
sin dependencias de terceros.

**Un paquete con varios targets, no un paquete por módulo.** Se obtiene el aislamiento de capas verificado por el
compilador sin el coste de mantener muchos `Package.swift`. En un proyecto mayor, cada feature podría
extraerse a su propio paquete sin cambiar sus fronteras.

**Concurrencia estricta (Swift 6).** Domain y Data son `nonisolated` y `Sendable`; los módulos de UI usan
aislamiento al main actor por defecto. Sin `@unchecked Sendable`. Las escrituras de favoritos se encadenan para que
lleguen al almacén en el orden de los toques (`rapidTogglesReachTheStoreInOrder`).

**Caché (en memoria, por consulta, 3 min).**
- `TTLCache` es un `actor` con **reloj inyectado**, así la expiración se prueba sin esperar.
- `CachedWeatherRepository` es un **decorador** del repositorio remoto: la clave es la consulta normalizada
  (códigos ordenados), de modo que `LEMD,LEBL` y `LEBL,LEMD` comparten entrada.
- Resultado válido → se devuelve sin red. Expirado → se vuelve a pedir y **se reemplaza**.
- Los fallos y las cancelaciones **no** se cachean.

**Cancelación y resultados obsoletos.**
- Cada cambio de texto cancela la `Task` anterior (tanto el *debounce* de 300 ms como la petición en vuelo).
- Además hay una **generación** por búsqueda: aunque una petición ignorase la cancelación y terminara tarde,
  su resultado se descarta si ya no es la última. Nunca se pinta un resultado antiguo.
- `CancellationError` y `URLError.cancelled` no se tratan como error visible.
- **Cómo se verifica** (`SearchViewModelTests`, con un doble de búsqueda cuyas respuestas se liberan a mano desde el
  test): `staleResponseNeverOverwritesNewerQuery` termina la búsqueda *antigua* después de la nueva y comprueba que
  la pantalla sigue mostrando la nueva; `newQueryCancelsTheInFlightTask` comprueba que la petición anterior recibe
  la cancelación; `cancellationIsNotShownAsAnError` y `debounceDelaysTheRequest` cubren el resto.

**Navegación adaptable.** `NavigationSplitView` con `List(selection:)`: una columna en iPhone y pantalla
exterior del iPhone Duo; dos columnas en la interior y en iPad. Sin código específico de dispositivo, solo clases
de tamaño.

**Diseño.** Sistema propio "Midnight Glass" ([`docs/DESIGN.md`](docs/DESIGN.md)). No se usa Liquid Glass del sistema
en las tarjetas porque el sistema de diseño define un cristal propio; la barra de pestañas sí es la del sistema.

### Accesibilidad

- Cada tarjeta y grupo del METAR tiene una etiqueta en lenguaje natural ("viento de 270 grados, 10 nudos…") y el
  código ICAO se deletrea para VoiceOver.
- La categoría de vuelo nunca se comunica solo con color: lleva texto e icono.
- Tipografía con Dynamic Type (`relativeTo:`) y diseños que se apilan en tamaños de accesibilidad.
- Contraste: los textos atenuados del diseño (blanco al 60 % y 40 %) no llegan a AA sobre las tarjetas tintadas
  y, además, la auditoría de Xcode no sabe medir texto semitransparente sobre degradados. Se sustituyen por un
  gris azulado opaco (`#CBD5E1`); un test comprueba ≥ 4,5:1 contra los fondos más claros posibles. El botón principal usa texto oscuro sobre el degradado por la misma razón.
- No se automatiza `performAccessibilityAudit()` (ver limitaciones); se verifica a mano con VoiceOver y Dynamic Type.

## Tests

- **Domain**: validación de códigos, caso de uso con repositorio *mock*, tokenizador (incluye METAR reales).
- **Data**: expiración y reemplazo de la caché con reloj inyectado, clave por consulta, errores no cacheados,
  decodificación contra un payload real capturado, mapeo de errores HTTP/red/cancelación.
- **Presentation / Search**: respuestas obsoletas descartadas, cancelación, *debounce*, estados, textos del lector,
  antigüedad del METAR.
- **Favoritos**: repositorio SwiftData en memoria y el *view model* (alternar, revertir si falla la escritura,
  orden de escrituras rápidas).
- **UI (XCTest, 2 tests)**: la pantalla de búsqueda aparece, y buscar LEMD y tocar el resultado abre el detalle.
  La app se lanza con `-ui-testing`, que sustituye la red por datos fijos para que sean rápidos y deterministas.

Framework: Swift Testing para el paquete y la lógica; XCTest solo para UI.

## CI/CD

- `.github/workflows/ci.yml`: en cada push/PR, `swift test` del paquete y `xcodebuild test` de la app en
  simulador; sube el `.xcresult` como artefacto.
- `.github/workflows/release.yml.disabled`: esqueleto de entrega a TestFlight, desactivado a propósito (necesita
  secretos del repositorio; nunca se versionan). Alternativa: Xcode Cloud por *tag*.

## Limitaciones y siguientes pasos

- **Auditoría de accesibilidad automatizada**: se probó `performAccessibilityAudit()` en UI tests, pero se descartó
  por ahora (no sabe medir contraste sobre texto semitransparente); la accesibilidad se ha verificado con los tests
  de contraste y revisando VoiceOver y Dynamic Type a mano.
- Caché en disco (SwiftData) como segundo nivel detrás de la de memoria.
- Peticiones simultáneas idénticas: cada una va a la red (no hay *request coalescing*); no compensa en este alcance.
- TAF (previsión) y comparación de dos aeropuertos, descartados para acotar la entrega.
- Pestañas «Recientes» y «Ajustes» (unidades de viento/presión/temperatura) descartadas por ahora: el HIG pide pocas
  pestañas y ninguna a medio hacer.
- Indicar en la UI si el dato viene de caché.
- Soporte de iPhone Duo verificado con tamaños de clase; pendiente de probar en el simulador con el pliegue.
- La API no devuelve pistas, por lo que no se calcula viento cruzado/de cara.

## Favoritos (SwiftData)

El dominio define el puerto `FavoritesRepository`; `SwiftDataFavoritesRepository` (`@ModelActor`) lo implementa con su
propio `ModelContext` fuera del hilo principal. El `@Model` es interno y no `Sendable`: solo cruzan `ICAOCode`.
`FavoritesViewModel` es la única fuente de verdad (estrella del detalle y pestaña Favoritos): alterna de forma optimista
y revierte si falla la escritura. Si el almacén no puede abrirse, la app usa un repositorio en memoria (`InMemoryFavoritesRepository`) en vez de cerrarse.
