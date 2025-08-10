# Firefly Sanctuary (Santuario de Luciérnagas)

Juego idle/gestión relajante para móviles hecho con Godot. Construye un jardín mágico, atrae especies de luciérnagas, recolecta Polvo Lumínico, automatiza procesos y progresa en rankings.

Estado: preproducción (prototipo en desarrollo)

## Características clave
- Atraer luciérnagas con objetos (flores, faroles, estanques).
- Recolección manual tocando luciérnagas.
- Automatizaciones progresivas (recolección, traslado, venta).
- Economía: Polvo Lumínico, Monedas Mágicas, Gotas de Rocío.
- Rankings con jerarquías y reinicios periódicos con recompensas.
- Progresión por áreas sin reinicio de partida.
- Estilo visual 2D suave y música ambiental relajante.

## Diseño (resumen del GDD)
- Las luciérnagas spawnean en el borde del mapa y deambulan con ruido; si se alejan hacia el exterior opuesto al centro, se destruyen.
- La cantidad total de spawns depende de los objetos atractores colocados.
- Cada luciérnaga tiene un radio de visión; al detectar un atractor se dirige con movimiento errático hacia él.
- Cada objeto acumula un máximo de luciérnagas para captura posterior.
	- Regla de capacidad: cada objeto acumula hasta N; si se supera, las nuevas no se contabilizan hasta vaciar el objeto.
	- Comportamiento IA: las luciérnagas no se interesan por atractores que están llenos.
- Automatizaciones caras y con requisitos de desbloqueo (p.ej., 3 especies, 5 objetos, etc.).

## Estructura del proyecto
```
assets/           # Arte, audio, fuentes, shaders
scenes/           # Escenas Godot (main, gameplay, UI, etc.)
scripts/          # GDScript: sistemas, entidades, UI, autoloads
resources/        # Recursos .tres/.res y datos balance
addons/           # Plugins de Godot
localization/     # Archivos de localización
builds/           # Exportaciones por plataforma (android/ios)
docs/             # Documentación (GDD, técnica)
tests/            # Pruebas (unitarias/integración)
tools/            # Herramientas de desarrollo
```

## Requisitos
- Godot 4.x (Editor y Export Templates para Android/iOS).
- VS Code (opcional) con tarea “Run Godot Project”.

## Cómo ejecutar
- En Godot: abrir `project.godot` y pulsar Play.
- Desde terminal: `godot --path . --debug`.
- En VS Code: Terminal > Run Task > "Run Godot Project".

## Lineamientos de código (GDScript)
- Nombres de clases en PascalCase; archivos en snake_case.
- Señales en PASTEL_CASE; nodos exportados con @export.
- Sistemas y lógica de juego en `scripts/systems`; datos en `resources/`.
- Usar Autoloads para singletons (p.ej., GameState, Economy, SaveLoad).

## Roadmap del prototipo
Ver `ROADMAP.md` para sprints, entregables y criterios de aceptación.

## Licencia
Pendiente de definir.

## Créditos
Idea y GDD: Equipo del proyecto. Desarrollo: por definir.
