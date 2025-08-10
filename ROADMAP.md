# Roadmap del Prototipo (Vertical Slice)

Objetivo: un prototipo jugable en Android que demuestre el loop central: colocar atractores, spawnear luciérnagas, recolectarlas manualmente, convertir Polvo Lumínico en Monedas y mostrar una UI básica con guardado.

Duración estimada: 4 sprints (1-2 semanas cada uno).

## Sprint 1 — Núcleo de criaturas y mundo
- Escena principal y límites del mapa (área circular/rectangular con centro).
- Sistema de spawn en bordes con tasa ligada al número de atractores totales.
- Movimiento errático (ruido/perlin o steering) + visión y targeting hacia atractores.
- Las luciérnagas ignoran atractores llenos (no los eligen como objetivo).
- Despawn al salir por el extremo opuesto al centro.
- Detección de toque/tap sobre luciérnagas (sin economía aún).

Criterios de aceptación
- Con N atractores, la población media y el rate de spawn responden a N.
- Las luciérnagas deambulan, "ven" atractores dentro de su radio y se acercan.
- Las luciérnagas no eligen como objetivo atractores que están llenos.
- Despawn correcto al abandonar el área jugable.

## Sprint 2 — Colocación y economía básica
- Colocación de 1-2 objetos atractores (Flor Simple, Farol Pequeño) con costo.
- Capacidad por objeto para acumular luciérnagas capturables.
	- Regla de capacidad/overflow: cada objeto acumula hasta N luciérnagas. Si se supera la capacidad, las nuevas luciérnagas no se contabilizan (quedan sin asignarse al objeto) hasta que se vacíe por recolección/traslado/venta.
- Recolección manual -> Polvo Lumínico.
- Intercambio básico: Polvo -> Monedas Mágicas (tasa fija inicial).
- Balance inicial: costos, tasas de spawn, capacidades.

Criterios de aceptación
- UI mínima para colocar objetos y ver costos/saldo.
- Recolección incrementa Polvo; conversión a Monedas funciona y persiste en sesión.
- Capacidad por objeto respetada: cuando el objeto está lleno, no aumenta el conteo aunque lleguen más luciérnagas; al vaciar (recolectar/trasladar), vuelve a aceptar hasta su N.
 - Registro al llegar: al alcanzar un atractor, la luciérnaga sólo se contabiliza si `can_accept()`/`add_one()` lo permite; si está lleno, no incrementa.

## Sprint 3 — UI/UX, feedback y guardado
- HUD: contadores de Polvo y Monedas, botón de conversión, menú de colocación.
- Efectos: partículas al recolectar, SFX sutiles, animaciones básicas.
- Guardado/carga (autoload SaveLoad): economía, objetos colocados, opciones.
- Opciones: volumen, calidad VFX, vibración.
- Mini tutorial contextual.

Criterios de aceptación
- Cerrar y reabrir conserva progreso y colocaciones.
- 30 FPS+ en Android gama media, sin fugas de memoria notorias.

## Sprint 4 — Build Android y QA
- Configurar export para Android (keystore de debug y release, permisos mínimos).
- Ajustes de input táctil, DPI/viewport, orientación.
- Perfilado: reducción de draw calls, colisiones y temporizadores.
- Lista de pruebas exploratorias + smoke tests.

Criterios de aceptación
- APK/AAB instalable; sesión de 10 min sin crashes; batería/termal razonables.

---

## Backlog (post-prototipo)
- Automatizaciones (recolección, traslado, venta) con requisitos de desbloqueo.
- Sistema de ranking por jerarquías y reinicios periódicos con recompensas.
- Nuevas áreas y especies, biomas y objetos especiales.
- Gotas de Rocío y upgrades especiales.
- Arte final, música dinámica, localización.

## Riesgos y mitigaciones
- Rendimiento en móviles: usar Particles GPU cuando sea posible, pooling de nodos.
- Complejidad IA: empezar simple (ruido + steering básico) y iterar.
- Balance economía: telemetría mínima y curvas editables en `resources/`.
