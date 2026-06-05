from fastapi import FastAPI
from pydantic import BaseModel

from services.recommendation_engine import get_recommendations

app = FastAPI()


class RecommendationRequest(BaseModel):
    occasion: str
    season: str
    fabric: str
    color: str


@app.get("/")
def home():

    return {
        "message": "KapraKar AI Service Running"
    }


@app.post("/recommend")
def recommend_style(data: RecommendationRequest):

    recommendations = get_recommendations(
        data.occasion,
        data.season,
        data.fabric,
        data.color,
    )

    return recommendations

import json
import urllib.request

class StyleNoteRequest(BaseModel):
    occasion: str
    season: str
    fabric: str
    color: str

@app.post("/style-note")
def generate_style_note(data: StyleNoteRequest):
    # Using Groq API with Llama 3
    api_key = "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"
    url = "https://api.groq.com/openai/v1/chat/completions"
    
    system_prompt = (
        "You are a world-class luxury fashion stylist and haute couture expert. "
        "Write a sophisticated, highly accurate style note (2-3 sentences max) based EXCLUSIVELY on the "
        "provided occasion, season, color, and fabric. "
        "Do not invent new garments or accessories. Instead, use elite fashion terminology "
        "(e.g., silhouette, drape, hue, ensemble) to elegantly explain WHY this specific fabric and color "
        "are a masterful choice for the given season and occasion. Maintain a refined, authoritative, "
        "and chic tone, while strictly staying within the provided context."
    )
    
    user_prompt = f"Occasion: {data.occasion}, Season: {data.season}, Color: {data.color}, Fabric: {data.fabric}"

    payload = {
        "model": "llama3-8b-8192",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
        "temperature": 0.5,
        "max_tokens": 150
    }

    req = urllib.request.Request(
        url,
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        },
        method="POST"
    )

    try:
        with urllib.request.urlopen(req) as response:
            result = json.loads(response.read().decode("utf-8"))
            note = result["choices"][0]["message"]["content"].strip()
            return {"note": note}
    except Exception as e:
        return {"note": f"Error generating style note: {str(e)}"}
