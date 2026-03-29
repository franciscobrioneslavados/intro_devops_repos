# Simulador de Redes VPC en AWS (Python & Streamlit)

¡Bienvenido/a! Esta es una herramienta interactiva y visual construida 100% en Python utilizando **Streamlit** y **Plotly**. Está orientada a facilitar la matemática, la planificación y la arquitectura de subredes para despliegues de VPCs (especialmente mediante Terraform).

---

## Requisitos Previos

Asegúrate de tener instalado en tu computadora:

- [Python 3.8 o superior](https://www.python.org/downloads/)
- El gestor de paquetes de Python `pip` instalado.

---

## Guía de Instalación Rápida

Es una mejor práctica de Ingeniería de Software aislar las librerías utilizando un Entorno Virtual (`venv`) para no ensuciar tu sistema operativo. Sigue estas instrucciones abriendo tu terminal dentro de esta misma carpeta (`python_vpc_calc/`):

### 1. Crear el Entorno Virtual

Genera la carpeta del entorno aislado (esto se hace solo la primera vez):

```bash
rm -rf venv
python3 -m venv venv
```

### 2. Activar el Entorno Virtual

El comando para encender tu entorno varía ligeramente según qué Sistema Operativo estés utilizando:

- **MacOS / Linux:**
  ```bash
  source venv/bin/activate
  ```
- **Windows (Símbolo del sistema / CMD):**
  ```cmd
  venv\Scripts\activate.bat
  ```
- **Windows (PowerShell):**
  ```powershell
  venv\Scripts\Activate.ps1
  ```
  _(Sabrás que está activado cuando veas la palabra `(venv)` al inicio de la línea de tu terminal)._

### 3. Instalar Dependencias

Una vez activado el entorno, procede a instalar todas las librerías oficiales listadas en nuestro archivo `requirements.txt`:

```bash
pip install -r requirements.txt
```

---

## Cómo ejecutar la aplicación (Dashboard)

¡Ya está todo listo para la acción! Para levantar tu propia aplicación web de servidor local, solo ejecuta:

```bash
streamlit run calculadora.py
./venv/bin/streamlit run calculadora.py

```

Al hacerlo, Streamlit levantará el panel mágico interactivo y automáticamente abrirá una pestaña en tu navegador web por defecto apuntando a la dirección local (generalmente `http://localhost:8501`).

_Para **apagar** el servidor y salir de la aplicación, solo vuelve a tu terminal y presiona la combinación `Ctrl + C`._
