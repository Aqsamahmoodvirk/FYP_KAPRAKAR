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

import asyncio

class StyleNoteRequest(BaseModel):
    occasion: str
    season: str
    fabric: str
    color: str

@app.post("/style-note")
async def generate_style_note(data: StyleNoteRequest):
    # Simulated LLM delay
    await asyncio.sleep(1.5)
    
    note = (
        f"For a stunning {data.occasion} look this {data.season}, a {data.color} {data.fabric} dress "
        "is an excellent choice. Consider pairing it with minimalistic gold jewelry and an elegant clutch "
        "to complete this sophisticated ensemble."
    )
    
    return {"note": note}