import re

def clean_question(text: str) -> str:
    text = re.sub(r"[^\w\s]", "", text)
    return " ".join(text.lower().split())

