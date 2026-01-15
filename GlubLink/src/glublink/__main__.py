import sys
from PyQt6.QtWidgets import QApplication, QMainWindow, QLabel
from PyQt6.QtCore import Qt

def main():
    app = QApplication(sys.argv)
    
    window = QMainWindow()
    window.setWindowTitle("GlubLink v0.1 - ЗАПУЩЕНО!")
    window.setMinimumSize(800, 600)
    
    label = QLabel(" GLUBLINK РАБОТАЕТ!\n\n"
                   "Poetry: \n"
                   "PyQt6: \n"
                   "Окно: \n\n"
                   "Теперь можно начинать разработку!\n"
                   "1. Разработать core/database.py\n"
                   "2. Создать ui/main_window.py\n"
                   "3. Добавить сканер файлов")
    label.setAlignment(Qt.AlignmentFlag.AlignCenter)
    label.setStyleSheet("""
        font-size: 20px;
        font-weight: bold;
        color: #00ffaa;
        background: #0a0a1a;
        padding: 50px;
        border-radius: 20px;
        border: 3px solid #00aaff;
    """)
    
    window.setCentralWidget(label)
    window.setStyleSheet("QMainWindow { background: #121225; }")
    window.show()
    
    sys.exit(app.exec())

if __name__ == "__main__":
    main()
