# Simulador de Robot 2D con Control PS5

![Godot](https://img.shields.io/badge/Godot-4.x-478CBF?logo=godot-engine)
![License](https://img.shields.io/badge/License-MIT-green)
![GitHub](https://img.shields.io/badge/Version-1.0.0-blue)

Un simulador realista de robot 2D controlado con mando de PS5, desarrollado en Godot Engine 4.x. Incluye física de vehículos avanzada, sistema de cámaras múltiples y mecanismos de seguridad profesional.

## 🎮 Características Principales

### 🚗 Física de Vehículo Avanzada
- **Modelo de bicicleta** para giros realistas
- **Sistema de marchas** con 3 velocidades
- **Aceleración progresiva** con curva de respuesta
- **Física en reversa** independiente
- **Deslizamiento y arrastre** configurable

### 📷 Sistema de Cámara
- **Modo 1**: Cámara fija sin rotación
- **Modo 2**: Cámara de seguimiento con rotación
- **Desplazamiento dinámico** al acelerar/frenar
- **Transiciones suaves** entre modos

### 🗺️ Minimapa en Tiempo Real
- **Sincronización precisa** con el mundo principal
- **Escalado automático** entre mundos
- **Seguimiento continuo** de posición y rotación

### ⚙️ Sistema de Marchas
| Marcha | Velocidad Máx | Aceleración | Sensibilidad Giro |
|--------|---------------|-------------|-------------------|
| 1 | 23% | 60% | 200% |
| 2 | 32% | 100% | 160% |
| 3 | 45% | 140% | 120% |

### 🔒 Mecanismo de Seguridad
- **Deadman Switch** requiere botón presionado
- **Frenado automático** al soltar
- **Regreso a marcha 1** por seguridad
- **Indicador visual** de estado

## 🕹️ Controles PS5

| Acción | Control | Descripción |
|--------|---------|-------------|
| **Acelerar** | L1+R2 | Aceleración progresiva (analógica) |
| **Reversa** | L1+L2 | Marcha atrás progresiva (analógica) |
| **Dirección** | Left Stick | Control de dirección (analógico) |
| **Subir marcha** | △ | Cambio ascendente de marchas |
| **Bajar marcha** | X | Cambio descendente de marchas |
| **Deadman** | L1 | Botón de seguridad (mantener presionado) |
| **Cambiar cámara** | R3 | Alternar entre modos de cámara |

## 🚀 Instalación y Uso

### Prerrequisitos
- **Godot Engine 4.x** o superior
- **Mando PS5** conectado vía Bluetooth o USB
- **Windows 10/11, macOS, o Linux**

### Pasos de Instalación
1. **Clona el repositorio:**
```bash
git clone https://github.com/tu-usuario/robot-simulator-2d.git
Abre el proyecto en Godot:

Inicia Godot Engine

Click "Import"

Selecciona la carpeta del proyecto

Abre project.godot

Configura inputs (opcional):

Ve a Project Settings > Input Map

Verifica que las acciones estén mapeadas correctamente

Ejecuta el proyecto:

Abre la escena scenes/robot.tscn

Presiona F5 o click en "Play"

📁 Estructura del Proyecto
text
robot-simulator-2d/
├── scenes/                 # Escenas de Godot
│   ├── robot.tscn         # Escena principal del robot
│   ├── obstacle.tscn      # Prefab de obstáculos
│   └── world.tscn         # Escenario principal
├── scripts/               # Scripts GDScript
│   ├── robot.gd          # Controlador principal del robot
│   └── obstacle.gd       # Comportamiento de obstáculos
├── assets/               # Recursos multimedia
│   ├── textures/         # Sprites y texturas
│   ├── sounds/           # Efectos de sonido
│   └── icons/            # Iconos de UI
├── docs/                 # Documentación
│   └── manual-tecnico.md # Documentación técnica completa
├── README.md             # Este archivo
└── .gitignore           # Archivos ignorados por Git
🔧 Configuración Técnica
Parámetros del Robot
gdscript
# Física básica
wheel_base_px = 120.0      # Distancia entre ejes
max_steer_deg = 35.0       # Ángulo máximo de giro
max_speed = 900.0          # Velocidad máxima (píxeles/segundo)

# Aceleración
accel_rate = 800.0         # Tasa de aceleración
decel_rate = 800.0         # Tasa de frenado
coast_drag = 100.0         # Resistencia al movimiento libre

# Respuesta de controles
throttle_response = 1.8    # Curva de respuesta del acelerador
steer_speed_deg = 200.0    # Velocidad de respuesta del giro
Sistema de Cámara
gdscript
# Modos de cámara
camera_mode = 1            # 1 = Fija, 2 = Seguimiento

# Desplazamiento
forward_offset = 100       # Movimiento al acelerar
reverse_offset = -50       # Movimiento al retroceder
camera_smooth = 5.0        # Suavidad del movimiento
🎯 Uso del Sistema
Inicio Rápido
Conecta tu mando PS5

Abre el proyecto en Godot

Ejecuta la escena principal

Mantén presionado X (Deadman) para habilitar movimiento

Usa R2/L2 para acelerar/retroceder

Left Stick para dirección

R1/L1 para cambiar marchas

Consejos de Manejo
Marcha 1: Ideal para maniobras precisas

Marcha 2: Balance entre velocidad y control

Marcha 3: Máxima velocidad en rectas

Suelta Deadman: Frenado de emergencia automático

🐛 Solución de Problemas
Problemas Comunes
❌ Robot no se mueve:

Verifica que el Deadman (X) esté presionado

Comprueba conexión del mando PS5

Revisa mapeo de controles en Input Map

❌ Cámara no sigue al robot:

Verifica que Camera2D sea hijo del robot

Presiona △ para cambiar modos de cámara

Revisa que no haya errores en consola

❌ Controles no responden:

Verifica conexión Bluetooth/USB

Reinicia Godot Engine

Prueba el mando en otra aplicación

Debugging
Habilita mensajes de consola para diagnosticar:

Cambios de marcha

Estado del Deadman Switch

Inputs de controles

Errores de física

🤝 Contribuciones
¡Las contribuciones son bienvenidas!

Fork el proyecto

Crea una rama para tu feature (git checkout -b feature/AmazingFeature)

Commit tus cambios (git commit -m 'Add some AmazingFeature')

Push a la rama (git push origin feature/AmazingFeature)

Abre un Pull Request

📝 Reportar Bugs
Si encuentras un bug, por favor:

Revisa los issues existentes

Crea un nuevo issue con:

Descripción detallada

Pasos para reproducir

Capturas de pantalla (si aplica)

Especificaciones de tu sistema

📄 Licencia
Este proyecto está bajo la Licencia MIT - ver el archivo LICENSE para detalles.

👨‍💻 Desarrollo
Creado por: [Tu Nombre]
Versión: 1.0.0
Godot Version: 4.x
Última actualización: 2024

🔗 Enlaces Útiles
Documentación de Godot

Guías de GDScript

Foro de la Comunidad

¿Preguntas? ¡No dudes en abrir un issue o contactar al desarrollador!

⭐ Si te gusta este proyecto, dale una estrella en GitHub!



# Asset creation software files
*.blend
*.psd
*.ai
*.sketch
