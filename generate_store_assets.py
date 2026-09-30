import os
import subprocess
from PIL import Image, ImageDraw, ImageFont, ImageFilter

def create_store_assets():
    out_dir = "/Users/user/solimus_coproprietaire/store_assets"
    os.makedirs(out_dir, exist_ok=True)
    
    # Render SVG logo to PNG using qlmanage
    svg_path = "/Users/user/solimus_coproprietaire/assets/images/solimus logo.svg"
    tmp_png = "/tmp/solimus_logo_tmp.png"
    
    # 1. GENERATE APP ICON (512 x 512)
    icon_size = 512
    icon = Image.new("RGBA", (icon_size, icon_size), (0, 0, 0, 0))
    
    # Draw rounded rectangle container with premium gradient
    bg = Image.new("RGBA", (icon_size, icon_size), (0, 0, 0, 0))
    draw_bg = ImageDraw.Draw(bg)
    
    # Gradient background from deep Navy/Bronze #2C2621 to #4A4037
    for y in range(icon_size):
        r = int(44 + (74 - 44) * (y / icon_size))
        g = int(38 + (64 - 38) * (y / icon_size))
        b = int(33 + (55 - 33) * (y / icon_size))
        draw_bg.line([(0, y), (icon_size, y)], fill=(r, g, b, 255))
        
    # Apply rounded corner mask
    mask = Image.new("L", (icon_size, icon_size), 0)
    draw_mask = ImageDraw.Draw(mask)
    draw_mask.rounded_rectangle([(0, 0), (icon_size, icon_size)], radius=96, fill=255)
    
    icon.paste(bg, (0, 0), mask)
    
    # Render SVG to high-res PNG
    subprocess.run(["qlmanage", "-t", "-s", "1024", "-o", "/tmp", svg_path], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    logo_file = "/tmp/solimus logo.svg.png"
    
    if os.path.exists(logo_file):
        logo_img = Image.open(logo_file).convert("RGBA")
        # Crop to visible content
        bbox = logo_img.getbbox()
        if bbox:
            logo_img = logo_img.crop(bbox)
        
        # Scale logo to fit nicely inside icon
        target_w = 400
        aspect = logo_img.height / logo_img.width
        target_h = int(target_w * aspect)
        logo_resized = logo_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
        
        # Center logo
        offset_x = (icon_size - target_w) // 2
        offset_y = (icon_size - target_h) // 2
        icon.paste(logo_resized, (offset_x, offset_y), logo_resized)
    
    icon_path = os.path.join(out_dir, "ic_launcher_512.png")
    icon.save(icon_path, "PNG")
    print(f"App Icon saved: {icon_path}")
    
    # 2. GENERATE FEATURE GRAPHIC / BANNER (1024 x 500)
    banner_w, banner_h = 1024, 500
    banner = Image.new("RGBA", (banner_w, banner_h), (0, 0, 0, 0))
    draw_banner = ImageDraw.Draw(banner)
    
    # Background gradient #1E1A17 to #3A322C
    for y in range(banner_h):
        r = int(30 + (58 - 30) * (y / banner_h))
        g = int(26 + (50 - 26) * (y / banner_h))
        b = int(23 + (44 - 23) * (y / banner_h))
        draw_banner.line([(0, y), (banner_w, y)], fill=(r, g, b, 255))
        
    # Decorative accent geometric lines
    draw_banner.line([(0, 480), (1024, 440)], fill=(200, 180, 140, 40), width=4)
    draw_banner.line([(0, 490), (1024, 450)], fill=(200, 180, 140, 20), width=2)
    
    # Paste logo in center of banner
    if os.path.exists(logo_file):
        logo_img = Image.open(logo_file).convert("RGBA")
        bbox = logo_img.getbbox()
        if bbox:
            logo_img = logo_img.crop(bbox)
            
        target_w = 640
        aspect = logo_img.height / logo_img.width
        target_h = int(target_w * aspect)
        logo_resized = logo_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
        
        offset_x = (banner_w - target_w) // 2
        offset_y = (banner_h - target_h) // 2 - 20
        banner.paste(logo_resized, (offset_x, offset_y), logo_resized)
        
    banner_path = os.path.join(out_dir, "feature_graphic_1024x500.png")
    banner.save(banner_path, "PNG")
    print(f"Feature Graphic saved: {banner_path}")

if __name__ == "__main__":
    create_store_assets()
