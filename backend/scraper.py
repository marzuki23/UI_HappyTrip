import os
from dotenv import load_dotenv

load_dotenv()
import time
import requests
from pymongo import MongoClient

MONGO_URI = os.getenv("MONGO_URI")
DB_NAME = os.getenv("DB_NAME")
API_DESTINATIONS = os.getenv("API_DESTINATIONS")

APIFY_TOKEN = os.getenv("APIFY_TOKEN")
API_APIFY_TOP = (
    f"https://api.apify.com/v2/datasets/U4LVJoY7FCh6CSgX3/items?token={APIFY_TOKEN}"
)

def run_scraper():
    print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Memulai proses scraping pariwisata...")
    try:
        # Koneksi ke MongoDB
        client = MongoClient(MONGO_URI)
        db = client[DB_NAME]
        
        # 1. Scraping data destinasi (Neon API -> MongoDB)
        print("Mengambil data destinasi umum dari server API...")
        res_dest = requests.get(API_DESTINATIONS, timeout=30)
        if res_dest.status_code == 200:
            dest_data = res_dest.json()
            if isinstance(dest_data, list) and len(dest_data) > 0:
                # Bersihkan dan masukkan data baru
                db.destinations.drop()
                db.destinations.insert_many(dest_data)
                print(f"Berhasil memperbarui koleksi 'destinations' dengan {len(dest_data)} data.")
            else:
                print("Peringatan: Data destinasi kosong.")
        else:
            print(f"Gagal mengambil data destinasi: HTTP {res_dest.status_code}")

        # 2. Scraping data Apify Top Destinations (Apify API -> MongoDB)
        print("Mengambil data top destinations dari Apify...")
        res_apify = requests.get(API_APIFY_TOP, timeout=30)
        if res_apify.status_code == 200:
            apify_data = res_apify.json()
            if isinstance(apify_data, list) and len(apify_data) > 0:
                # Bersihkan dan masukkan data baru
                db.top_destinations.drop()
                db.top_destinations.insert_many(apify_data)
                print(f"Berhasil memperbarui koleksi 'top_destinations' dengan {len(apify_data)} data.")
            else:
                print("Peringatan: Data top destinations Apify kosong.")
        else:
            print(f"Gagal mengambil data top destinations: HTTP {res_apify.status_code}")

        client.close()
        print(f"[{time.strftime('%Y-%m-%d %H:%M:%S')}] Proses scraping berhasil diselesaikan.")
    except Exception as e:
        print(f"Terjadi kesalahan saat scraping: {e}")

if __name__ == "__main__":
    # Jalankan langsung saat pertama kali startup
    run_scraper()
    
    # Jalankan berkala seminggu sekali (7 hari * 24 jam * 60 menit * 60 detik)
    SECONDS_IN_WEEK = 7 * 24 * 60 * 60
    print(f"\nPenjadwalan otomatis diaktifkan. Scraping diulangi setiap 7 hari.")
    print("Tekan Ctrl+C untuk menghentikan program.")
    
    try:
        while True:
            time.sleep(SECONDS_IN_WEEK)
            run_scraper()
    except KeyboardInterrupt:
        print("\nProgram scraper dihentikan.")
