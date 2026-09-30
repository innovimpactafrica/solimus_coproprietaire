import os
from PIL import Image

def generate_launcher_icons():
    src_icon = "/Users/user/solimus_coproprietaire/store_assets/ic_launcher_512.png"
    if not os.path.exists(src_icon):
        print("Source icon not found!")
        return

    base_res = "/Users/user/solimus_coproprietaire/android/app/src/main/res"
    
    sizes = {
        "mipmap-mdpi": (48, 48),
        "mipmap-hdpi": (72, 72),
        "mipmap-xhdpi": (96, 96),
        "mipmap-xxhdpi": (144, 144),
        "mipmap-xxxhdpi": (192, 192)
    }

    img = Image.open(src_icon).convert("RGBA")

    for folder, size in sizes.items():
        folder_path = os.path.join(base_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        
        resized_img = img.resize(size, Image.Resampling.LANCZOS)
        
        target_png = os.path.join(folder_path, "ic_launcher.png")
        resized_img.save(target_png, "PNG")
        print(f"Saved {target_png} ({size[0]}x{size[1]})")

if __name__ == "__main__":
    generate_launcher_icons()
