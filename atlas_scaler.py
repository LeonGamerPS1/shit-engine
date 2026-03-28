import xml.etree.ElementTree as ET
from PIL import Image
import tkinter as tk
from tkinter import filedialog, simpledialog, messagebox
import os

def scale_atlas():
    # 1. Hauptfenster verstecken
    root = tk.Tk()
    root.withdraw()

    # 2. Multiplikator abfragen (z.B. 0.5 für die Hälfte, 2.0 für doppelt)
    mult = simpledialog.askfloat("Skalierung", "Gib den Multiplikator ein (z.B. 0.5 oder 2.0):", minvalue=0.01, maxvalue=10.0)
    if not mult:
        return

    # 3. Dateien auswählen
    image_path = filedialog.askopenfilename(title="Wähle das PNG-Bild aus", filetypes=[("PNG Bilder", "*.png")])
    if not image_path: return

    xml_path = filedialog.askopenfilename(title="Wähle die passende XML-Datei aus", filetypes=[("XML Dateien", "*.xml")])
    if not xml_path: return

    try:
        # --- BILD SKALIEREN ---
        with Image.open(image_path) as img:
            new_size = (int(round(img.width * mult)), int(round(img.height * mult)))
            # LANCZOS für Fotos/Grafiken, NEAREST für Pixel-Art
            scaled_img = img.resize(new_size, Image.Resampling.LANCZOS)
            
            img_dir, img_name = os.path.split(image_path)
            new_img_path = os.path.join(img_dir, "scaled_" + img_name)
            scaled_img.save(new_img_path)

        # --- XML SKALIEREN ---
        tree = ET.parse(xml_path)
        xml_root = tree.getroot()

        attribs = ['x', 'y', 'width', 'height', 'frameX', 'frameY', 'frameWidth', 'frameHeight']

        for subtexture in xml_root.findall('SubTexture'):
            for attr in attribs:
                if attr in subtexture.attrib:
                    val = float(subtexture.attrib[attr])
                    subtexture.attrib[attr] = str(int(round(val * mult)))

        xml_dir, xml_name = os.path.split(xml_path)
        new_xml_path = os.path.join(xml_dir, "scaled_" + xml_name)
        tree.write(new_xml_path, encoding='UTF-8', xml_declaration=True)

        messagebox.showinfo("Erfolg", f"Dateien wurden erstellt:\n{new_img_path}\n{new_xml_path}")

    except Exception as e:
        messagebox.showerror("Fehler", f"Da lief was schief:\n{e}")

if __name__ == "__main__":
    scale_atlas()
