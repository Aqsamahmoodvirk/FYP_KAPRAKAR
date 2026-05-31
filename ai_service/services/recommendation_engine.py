import json

with open("data/trends.json", "r", encoding="utf-8") as file:
    fashion_data = json.load(file)


def get_recommendations(occasion, season, fabric, color):

    results = []

    for item in fashion_data:

        if (
            item["occasion"].lower() == occasion.lower()
            and item["season"].lower() == season.lower()
            and item["fabric"].lower() == fabric.lower()
            and color.lower() in [c.lower() for c in item["colors"]]
        ):

            results.append(item)

    return results