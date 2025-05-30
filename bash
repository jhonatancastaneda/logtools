Decoradores reutilizables de logging y rendimiento para Python


mkdir logtools && cd logtools
python -m venv venv
source venv\Scripts\activate  # En Windows: venv\Scripts\activate venv/bin/activate

mkdir logtools
touch logtools/__init__.py logtools/core.py

# logtools.py
import time
import functools
import logging
from colorama import Fore, Style, init as colorama_init

# Inicializa colores (Windows-friendly)
colorama_init(autoreset=True)

# Logging a archivo
logging.basicConfig(
    filename='logtools.log',
    filemode='a',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Configuración global para habilitar o deshabilitar logging
ENABLE_LOGGING = True

# Colores por nivel
LEVEL_COLORS = {
    "INFO": Fore.CYAN,
    "DEBUG": Fore.GREEN,
    "WARNING": Fore.YELLOW,
    "ERROR": Fore.RED
}

def loggear(nombre_logger=None, nivel="INFO"):
    def decorador(func):
        @functools.wraps(func)
        def envoltura(*args, **kwargs):
            if ENABLE_LOGGING:
                nombre = nombre_logger or func.__name__
                color = LEVEL_COLORS.get(nivel.upper(), "")
                mensaje_inicio = f"{color}📥 [{nivel}] Llamando a: {nombre}"
                mensaje_final  = f"{color}📤 [{nivel}] Finalizó: {nombre}"
                print(mensaje_inicio)
                logging.log(getattr(logging, nivel.upper(), logging.INFO), f"Inicio de: {nombre}")
            resultado = func(*args, **kwargs)
            if ENABLE_LOGGING:
                print(mensaje_final)
                logging.log(getattr(logging, nivel.upper(), logging.INFO), f"Fin de: {nombre}")
            return resultado
        return envoltura
    return decorador

def medir_tiempo_si_supera(umbral=0.0, nivel="DEBUG"):
    def decorador(func):
        @functools.wraps(func)
        def envoltura(*args, **kwargs):
            if not ENABLE_LOGGING:
                return func(*args, **kwargs)
            inicio = time.time()
            resultado = func(*args, **kwargs)
            duracion = time.time() - inicio
            if duracion > umbral:
                color = LEVEL_COLORS.get(nivel.upper(), "")
                mensaje = f"{color}⏱ [{nivel}] {func.__name__} tardó {duracion:.4f}s (umbral: {umbral}s)"
                print(mensaje)
                logging.log(getattr(logging, nivel.upper(), logging.INFO), mensaje.strip())
            return resultado
        return envoltura
    return decorador

    # main.py
from logtools import loggear, medir_tiempo_si_supera, ENABLE_LOGGING

@loggear("🔍 Procesamiento de datos", nivel="INFO")
@medir_tiempo_si_supera(1.0, nivel="WARNING")
def procesar():
    import time
    time.sleep(1.5)
    print("Procesamiento completo.")

@loggear(nivel="DEBUG")
@medir_tiempo_si_supera(0.5)
def tarea_rapida():
    import time
    time.sleep(0.3)
    print("Tarea rápida hecha.")

procesar()
tarea_rapida()

# Puedes desactivar todos los logs con:
# ENABLE_LOGGING = False


touch README.md LICENSE setup.py pyproject.toml .gitignore


pip install pytest

mkdir tests
touch tests/test_logtools.py

from logtools import loggear

def test_loggear_output(capsys):
    @loggear("test_func", nivel="INFO")
    def test_func():
        print("doing work")
    test_func()
    output = capsys.readouterr().out
    assert "Llamando a" in output
    assert "doing work" in output
    assert "Finalizó" in output

