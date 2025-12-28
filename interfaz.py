import matplotlib
# Configuración del backend para ventanas emergentes
try:
    matplotlib.use('Qt5Agg') 
except:
    try:
        matplotlib.use('TkAgg')
    except:
        pass

import serial
import serial.tools.list_ports
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from collections import deque
import threading
import time
import sys
import numpy as np

class RealTimePlotter:
    def __init__(self, port, baudrate=9600):
        try:
            self.ser = serial.Serial(port, baudrate, timeout=1)
            print(f"✅ Conectado exitosamente a {port}")
            self.ser.reset_input_buffer()
        except serial.SerialException as e:
            print(f"❌ No se pudo abrir el puerto: {e}")
            sys.exit(1)

        self.running = True
        
        # --- CONFIGURACIÓN DE LA VENTANA ---
        self.window_seconds = 5.0
        self.fs = 400.0
        self.max_len = int(self.window_seconds * self.fs)
        
        # --- EJE X (TIEMPO ESTÁTICO) ---
        self.x_data = np.linspace(0, self.window_seconds, self.max_len)
        
        # --- EJE Y (VOLTAJE) ---
        # Se usarán los valores invertidos
        self.y_data = deque([0.0] * self.max_len, maxlen=self.max_len)
        
        # Crear figura
        self.fig = plt.figure(figsize=(12, 7))
        
        # Área del gráfico (Ajustado para llenar más espacio ya que no hay botones)
        # [izquierda, abajo, ancho, alto]
        self.ax = plt.axes([0.1, 0.1, 0.8, 0.85]) 
        
        # Estilo tipo "Electrocardiograma"
        self.fig.patch.set_facecolor('black')
        self.ax.set_facecolor('black')
        self.line, = self.ax.plot([], [], color='#00FF00', linewidth=1.5)
        
        # Configuración fija de los ejes
        self.ax.set_ylim(-0.1, 1.1)
        self.ax.set_xlim(0, self.window_seconds)
        
        # Decoración
        self.ax.set_title(f'Monitor XADC - {port} (SEÑAL INVERTIDA)', 
                          color='white', fontsize=14, fontweight='bold')
        self.ax.set_ylabel('Voltaje Invertido (V)', color='white', fontsize=12)
        self.ax.set_xlabel('Tiempo (segundos)', color='white', fontsize=12)
        
        # Rejilla
        self.ax.grid(True, color='green', linestyle='--', alpha=0.3)
        self.ax.tick_params(axis='x', colors='white')
        self.ax.tick_params(axis='y', colors='white')
        
        for spine in self.ax.spines.values():
            spine.set_color('green')

        # Hilo de lectura
        self.thread = threading.Thread(target=self.read_serial_data)
        self.thread.daemon = True
        self.thread.start()

    def read_serial_data(self):
        print("🔌 Iniciando lectura...")
        while self.running:
            try:
                if not self.ser or not self.ser.is_open:
                    break

                if self.ser.in_waiting >= 2:
                    data = self.ser.read(2)
                    if len(data) == 2:
                        value = (data[0] << 8) | data[1]
                        
                        # Conversión
                        adc_12bit = value >> 4
                        voltage_original = (adc_12bit / 4095.0) * 1.0
                        
                        # ===================================================
                        # ✨ MODIFICACIÓN: INVERSIÓN DE LA SEÑAL (Eje Y)
                        # V_invertido = 1.0 - V_original
                        # Esto logra el efecto de "Polaridad Invertida"
                        # ===================================================
                        voltage = 1.0 - voltage_original
                        
                        # Agregar al buffer
                        self.y_data.append(voltage)
                        
                    else:
                        time.sleep(0.001)

                else:
                    time.sleep(0.001)

            except Exception as e:
                print(f"Error en lectura: {e}")
                break

    def update_plot(self, frame):
        if self.running:
            self.line.set_data(self.x_data, self.y_data)
        return self.line,

    def start(self):
        print("📊 Abriendo monitor...")
        
        ani = FuncAnimation(
            self.fig, 
            self.update_plot, 
            interval=40,
            blit=True,
            cache_frame_data=False
        )
        
        plt.show(block=True) 
        self.close()

    def close(self):
        self.running = False
        time.sleep(0.5)
        if self.ser and self.ser.is_open:
            try:
                self.ser.close()
                print("\n🔌 Puerto serial cerrado.")
            except:
                pass

if __name__ == "__main__":
    ports = serial.tools.list_ports.comports()
    if not ports:
        print("❌ No se encontraron puertos COM.")
    else:
        print("📡 Puertos disponibles:")
        for i, port in enumerate(ports):
            print(f"[{i}] {port.device}")
        
        try:
            idx = int(input("\nSelecciona el número del puerto: "))
            selected_port = ports[idx].device
            plotter = RealTimePlotter(selected_port, baudrate=9600)
            plotter.start()
            
        except (ValueError, IndexError):
            print("❌ Selección inválida.")
        except KeyboardInterrupt:
            print("\n👋 Programa interrumpido por el usuario.")