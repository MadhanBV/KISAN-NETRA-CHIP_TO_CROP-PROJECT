import json
import os
import re
import sys
import time
import httpx

sys.stdout.reconfigure(encoding='utf-8')

API_KEY = os.environ.get("SARVAM_API_KEY", "").strip()
BASE_URL = "https://api.sarvam.ai/translate"

LANGUAGES = [
    ("kn-IN", "kn"),
    ("hi-IN", "hi"),
    ("ta-IN", "ta"),
    ("te-IN", "te"),
    ("ml-IN", "ml"),
    ("mr-IN", "mr"),
    ("bn-IN", "bn"),
    ("gu-IN", "gu"),
    ("pa-IN", "pa"),
    ("or-IN", "or"),
    ("as-IN", "as"),
    ("brx-IN", "brx"),
    ("doi-IN", "doi"),
    ("ks-IN", "ks"),
    ("kok-IN", "kok"),
    ("mai-IN", "mai"),
    ("mni-IN", "mni"),
    ("ne-IN", "ne"),
    ("sa-IN", "sa"),
    ("sat-IN", "sat"),
    ("sd-IN", "sd"),
    ("ur-IN", "ur"),
]

def load_en_template():
    with open("lib/l10n/app_en.arb", "r", encoding="utf-8") as f:
        return json.load(f)

def translate_batch(client, texts, target_code):
    """Translate list of texts in chunks separated by delimiter."""
    headers = {
        "api-subscription-key": API_KEY,
        "Content-Type": "application/json",
    }
    
    # We use newline delimiter
    combined = "\n".join(texts)
    payload = {
        "input": combined,
        "source_language_code": "en-IN",
        "target_language_code": target_code,
        "model": "sarvam-translate:v1",
        "mode": "formal"
    }
    
    for attempt in range(3):
        try:
            res = client.post(BASE_URL, headers=headers, json=payload, timeout=25.0)
            if res.status_code == 200:
                translated_combined = res.json().get("translated_text", "")
                translated_lines = translated_combined.split("\n")
                if len(translated_lines) == len(texts):
                    return [line.strip() for line in translated_lines]
                else:
                    # Line count mismatch, do fallback or strip blank
                    # Try splitting by newlines and match up as best as possible
                    clean_lines = [l.strip() for l in translated_lines if l.strip()]
                    if len(clean_lines) == len(texts):
                        return clean_lines
                    print(f"[{target_code}] Mismatch: expected {len(texts)} got {len(translated_lines)}")
                    return texts
            elif res.status_code == 429:
                time.sleep(2.0 * (attempt + 1))
            else:
                print(f"[{target_code}] Error {res.status_code}: {res.text}")
                time.sleep(1.0)
        except Exception as e:
            print(f"[{target_code}] Exception {e}, retry {attempt}")
            time.sleep(1.5)
            
    return texts

def main():
    if not API_KEY:
        raise RuntimeError(
            "SARVAM_API_KEY environment variable is required to generate ARB translations."
        )

    en_data = load_en_template()
    keys = [k for k in en_data.keys() if not k.startswith("@")]
    
    # Exclude appName from translation to keep CHIP TO CROP branding intact
    translatable_keys = [k for k in keys if k not in ["appName"]]
    
    print(f"Total keys to translate: {len(translatable_keys)}")
    
    client = httpx.Client()
    
    # Split into chunks of 15 strings
    chunk_size = 15
    chunks = [translatable_keys[i:i + chunk_size] for i in range(0, len(translatable_keys), chunk_size)]
    
    for sarvam_code, flutter_code in LANGUAGES:
        arb_path = f"lib/l10n/app_{flutter_code}.arb"
        print(f"Generating {arb_path} ({sarvam_code})...")
        
        target_dict = {
            "@@locale": flutter_code,
            "appName": en_data["appName"],
        }
        
        for chunk in chunks:
            raw_texts = [en_data[k] for k in chunk]
            
            # Mask placeholders like {language} or {count}
            masked_texts = []
            for t in raw_texts:
                m = t.replace("{language}", "LANGUAGE_TOKEN").replace("{count}", "COUNT_TOKEN")
                masked_texts.append(m)
                
            translated = translate_batch(client, masked_texts, sarvam_code)
            time.sleep(0.3)
            
            for k, original_t, trans_t in zip(chunk, raw_texts, translated):
                # Restore placeholders
                final_t = trans_t.replace("LANGUAGE_TOKEN", "{language}").replace("COUNT_TOKEN", "{count}")
                # Ensure placeholders didn't get corrupted
                if "{language}" in original_t and "{language}" not in final_t:
                    final_t = original_t
                if "{count}" in original_t and "{count}" not in final_t:
                    final_t = original_t
                target_dict[k] = final_t
                
        with open(arb_path, "w", encoding="utf-8") as f:
            json.dump(target_dict, f, ensure_ascii=False, indent=2)
            
        print(f"✓ Saved {arb_path} with {len(target_dict)} keys.")
        
    print("\nAll 22 ARB files generated successfully!")

if __name__ == "__main__":
    main()
