import json
import re

# Load your raw JSON file
with open('assets/hymns-full.json', 'r', encoding='utf-8') as f:
    hymns = json.load(f)

for hymn in hymns:
    lyrics = hymn.get('lyrics', '')
    
    # 1. Replace hidden non-breaking spaces (\xa0) with normal spaces
    lyrics = lyrics.replace('\xa0', ' ')
    
    # 2. Strip leading header lines (e.g., OLUYIMBA 1: ...)
    lyrics = re.sub(r'^(?:OLUYIMBA|HYMN|SONG LYRICS|LYRICS).*\n+', '', lyrics, flags=re.IGNORECASE)
    
    # 3. Strip trailing web junk / "Song Lyrics" phrases
    lyrics = re.sub(r'(?:Song Lyrics|Hymn Lyrics|www\.\S+|http\S+)', '', lyrics, flags=re.IGNORECASE)
    
    # 4. Clean up spaces and extra empty lines
    lines = [line.strip() for line in lyrics.splitlines()]
    clean_text = '\n'.join(lines)
    clean_text = re.sub(r'\n{3,}', '\n\n', clean_text).strip()
    
    hymn['lyrics'] = clean_text

# Save the cleaned data back
with open('assets/hymns-full.json', 'w', encoding='utf-8') as f:
    json.dump(hymns, f, ensure_ascii=False, indent=2)

print("All hymns cleaned successfully!")