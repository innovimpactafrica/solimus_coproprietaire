import os
from PIL import Image

def update_icon():
    src_path = "/Users/user/.gemini/antigravity-ide/brain/ca3a1a59-cd4f-483a-a50c-c33ada7f209b/media__1786445372640.png"
    if not os.path.exists(src_path):
        print(f"Error: {src_path} not found")
        return
        
    img = Image.open(src_path).convert("RGBA")
    
    base_res = "/Users/user/solimus_coproprietaire/android/app/src/main/res"
    sizes = {
        "mipmap-mdpi": (48, 48),
        "mipmap-hdpi": (72, 72),
        "mipmap-xhdpi": (96, 96),
        "mipmap-xxhdpi": (144, 144),
        "mipmap-xxxhdpi": (192, 192)
    }
    
    for folder, size in sizes.items():
        folder_path = os.path.join(base_res, folder)
        os.makedirs(folder_path, exist_ok=True)
        target = os.path.join(folder_path, "ic_launcher.png")
        resized = img.resize(size, Image.Resampling.LANCZOS)
        resized.save(target, "PNG")
        print(f"Updated {target} -> {size}")

if __name__ == "__main__":
    update_icon()
