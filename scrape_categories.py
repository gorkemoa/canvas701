#!/usr/bin/env python3
"""
Canvas701.com kategori görsellerini çeken script
"""

import requests
from bs4 import BeautifulSoup
import json
import time

def scrape_category_page_image(url, name):
    """Bir kategori sayfasından görsel çeker"""
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=15)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        # İlk ürün görselini bul
        product_images = soup.find_all('img', class_=lambda x: x and ('product' in x.lower() or 'item' in x.lower()))
        
        if not product_images:
            # Genel img tag'lerinde ara
            product_images = soup.find_all('img', src=lambda x: x and 'upload' in x)
        
        if product_images:
            img = product_images[0]
            img_url = img.get('src') or img.get('data-src') or img.get('data-lazy-src')
            if img_url:
                if not img_url.startswith('http'):
                    if img_url.startswith('//'):
                        img_url = 'https:' + img_url
                    elif img_url.startswith('/'):
                        img_url = 'https://www.canvas701.com' + img_url
                print(f"   ✅ {name} için görsel bulundu: {img_url}")
                return img_url
        
        return None
        
    except Exception as e:
        print(f"   ⚠️  {name} sayfası çekilemedi: {e}")
        return None

def scrape_category_images():
    """Kategori görsellerini çeker"""
    url = 'https://www.canvas701.com/kanvas-kategorileri'
    
    print(f"🌐 Sayfa getiriliyor: {url}")
    
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
        response = requests.get(url, headers=headers, timeout=30)
        response.raise_for_status()
        
        print(f"✅ Sayfa başarıyla getirildi (Status: {response.status_code})")
        
        soup = BeautifulSoup(response.content, 'html.parser')
        
        categories = []
        
        # Kategori kartlarını bul
        # Genellikle kategori görselleri img tag'lerinde veya background-image'lerde olur
        category_items = soup.find_all('a', href=lambda x: x and '/kanvas-tablolar/' in x)
        
        print(f"\n📦 {len(category_items)} kategori linki bulundu\n")
        
        seen = set()
        
        for item in category_items:
            try:
                # Kategori URL'i
                href = item.get('href', '')
                if not href or '/kanvas-tablolar/' not in href:
                    continue
                
                # Kategori slug'ını çıkar
                slug = href.split('/kanvas-tablolar/')[-1].strip('/')
                
                if not slug or slug in seen:
                    continue
                seen.add(slug)
                
                # Kategori adı
                name = item.get_text(strip=True)
                
                # Görsel ara - önce img tag'i
                img = item.find('img')
                image_url = None
                
                if img:
                    image_url = img.get('src') or img.get('data-src') or img.get('data-lazy-src')
                    if image_url and not image_url.startswith('http'):
                        if image_url.startswith('//'):
                            image_url = 'https:' + image_url
                        elif image_url.startswith('/'):
                            image_url = 'https://www.canvas701.com' + image_url
                
                # Eğer img bulunamadıysa, parent'ta background-image ara
                if not image_url:
                    parent = item.find_parent()
                    if parent:
                        style = parent.get('style', '')
                        if 'background-image' in style:
                            # url(...) içindeki değeri çıkar
                            start = style.find('url(') + 4
                            end = style.find(')', start)
                            if start > 3 and end > start:
                                image_url = style[start:end].strip('\'"')
                                if not image_url.startswith('http'):
                                    if image_url.startswith('//'):
                                        image_url = 'https:' + image_url
                                    elif image_url.startswith('/'):
                                        image_url = 'https://www.canvas701.com' + image_url
                
                category_data = {
                    'name': name,
                    'slug': slug,
                    'url': 'https://www.canvas701.com' + href if not href.startswith('http') else href,
                    'image_url': image_url
                }
                
                categories.append(category_data)
                
                print(f"✅ {name}")
                print(f"   Slug: {slug}")
                print(f"   Görsel: {image_url if image_url else '❌ Bulunamadı'}")
                print()
                
            except Exception as e:
                print(f"⚠️  Hata: {e}")
                continue
        
        # Görseli olmayan kategoriler için sayfa ziyareti yap
        print("\n🔍 Görseli bulunamayan kategoriler için kategori sayfalarına bakılıyor...\n")
        for category in categories:
            if not category['image_url']:
                print(f"📄 {category['name']} sayfası kontrol ediliyor...")
                image = scrape_category_page_image(category['url'], category['name'])
                if image:
                    category['image_url'] = image
                time.sleep(1)  # Rate limiting
        
        # JSON olarak kaydet
        output_file = 'canvas701_categories.json'
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(categories, f, ensure_ascii=False, indent=2)
        
        print(f"\n✅ {len(categories)} kategori {output_file} dosyasına kaydedildi")
        
        # Görseli olmayan kategorileri göster
        no_images = [c for c in categories if not c['image_url']]
        if no_images:
            print(f"\n⚠️  Görseli bulunamayan kategoriler ({len(no_images)}):")
            for cat in no_images:
                print(f"   - {cat['name']}")
        
        return categories
        
    except requests.RequestException as e:
        print(f"❌ HTTP Hatası: {e}")
        return []
    except Exception as e:
        print(f"❌ Beklenmeyen hata: {e}")
        return []

if __name__ == '__main__':
    print("🎨 Canvas701 Kategori Görsel Çekici\n")
    categories = scrape_category_images()
    print(f"\n✨ İşlem tamamlandı! Toplam {len(categories)} kategori çekildi.")
