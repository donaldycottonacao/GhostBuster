"""Trilingual AI Escape Script Generation Service."""

from __future__ import annotations

import re
from typing import List, Tuple
from app.schemas import ScriptGenerateRequest, ScriptGenerateResponse


class ScriptService:
    """Intelligent generator for contextual escape call dialogue in EN, TL, and CEB."""

    # Categorized situational dialogue templates across three languages
    _TEMPLATES = {
        "en": {
            "party": (
                "Hey! Are you still at that party? We have a massive plumbing pipe burst at the apartment, and water is leaking through the ceiling. You need to come home right now!",
                [
                    "Hey, sorry to interrupt your night, but your pet just threw up everywhere and seems really sick. Can you head back immediately?",
                    "Hello! My car just broke down two blocks away and the battery is completely dead. Could you please come give me a hand?",
                ],
            ),
            "meeting": (
                "Hi, I am calling from client support. The production database is throwing critical latency alerts and the server node is crashing. We need your review right away.",
                [
                    "Excuse me, dispatch called to let us know the office alarm was triggered in the server room. Can you step out and check the dashboard?",
                    "Hey, urgent call from logistics. There is a delivery truck blocked at the gate and they need your signature within 15 minutes.",
                ],
            ),
            "date": (
                "Hey! I know you are busy, but our roommate locked themselves out of the house in the rain without their keys. Can you bring the spare keys home ASAP?",
                [
                    "Hi! Mom called and said she is feeling dizzy and needs someone to drive her to the clinic. Please call her back as soon as you step outside.",
                    "Hey, my flight just arrived two hours earlier than scheduled! Any chance you can come pick me up from the terminal?",
                ],
            ),
            "generic": (
                "Hey, can you call me back immediately? Something urgent just came up that requires your attention right now.",
                [
                    "Hey! I really need a reason for you to step outside right now. Call me as soon as you get this.",
                    "Hi, please step out and pick up this call. There is something critical we need to discuss privately.",
                ],
            ),
        },
        "tl": {
            "party": (
                "Uy! Nandoon ka pa ba sa party? Pumutok 'yung tubo sa kusina at bumabaha na rito sa bahay! Kailangan mo nang umuwi agad!",
                [
                    "Uy, pasensya na sa abala pero sumuka 'yung aso/pusa natin at parang nanghihina. Puwede ka bang umuwi na ngayon din?",
                    "Pre/Sis, tumirik 'yung kotse ko sa may kanto. Wala akong dalang jumper cable, puwede mo ba akong saklolohan saglit?",
                ],
            ),
            "meeting": (
                "Magandang araw po, tumatawag po ako mula sa opisina. May emergency issue po sa deployment at nagka-crash ang main server natin. Kailangan po kayo agad.",
                [
                    "Pasensya na sa istorbo, tumawag ang dispatch. May delivery na kailangan ng personal signature ninyo bago umalis ang courier.",
                    "Sir/Ma'am, may urgent follow-up po si client tungkol sa kontrata. Kailangan daw po kayong makausap bago mag-alas singko.",
                ],
            ),
            "date": (
                "Uy! Nandiyan ka pa ba? Tumawag si Mama, bigla raw tumaas ang presyon niya at kailangan ng magdadala sa klinika. Tawagan mo siya agad!",
                [
                    "Uy, naiwan ko 'yung susi sa loob ng bahay at umuulan dito sa labas! Puwede mo ba akong buksan saglit bago ako mabasa nang husto?",
                    "Hello! Maaga pala natapos 'yung meeting ko at malapit ako sa lugar mo. Uwi na tayo, may emergency kailangan asikasuhin.",
                ],
            ),
            "generic": (
                "Uy, puwede mo ba akong tawagan? Kailangan ko ng dahilan para makalabas dito.",
                [
                    "Uy, tumawag ka agad paglabas mo. May importanteng balita na kailangan mong malaman agad.",
                    "Hello! Lumabas ka muna saglit, kailangan kitang makausap nang pribado tungkol sa nangyari kanina.",
                ],
            ),
        },
        "ceb": {
            "party": (
                "Uy! Naa pa ka sa party? Nibuto ang tubo sa tubig sa balay, nagbaha na diri! Kinahanglan mouli ka dayon karon!",
                [
                    "Uy, pasensya sa distorbo pero nagsuka atong binuhi nga iro/iring unya luya kaayo. Makapauli ba ka karon dayon?",
                    "Bai, na-aberya akong motor duol sa inyo. Mahimo bang matabangan ko nimo diri kadiyot?",
                ],
            ),
            "meeting": (
                "Maayong adlaw, nanawag ko gikan sa opisina. Naay dakong problema sa atong sistema ug nag-crash ang database. Kinahanglan ka namo dayon.",
                [
                    "Pasensya sa samok, nanawag ang dispatch kay naay delivery nga kinahanglan og pirma nimo sa dili pa molakaw.",
                    "Sir/Ma'am, naay dinaliang tawag ang kliyente bahin sa proyekto. Kinahanglan ka ma-istorya sa labing daling panahon.",
                ],
            ),
            "date": (
                "Uy! Nanawag si Mama, kalit lang nitaas iyang presyon unya kinahanglan dad-on sa klinika. Tawagi siya dayon inig gawas nimo!",
                [
                    "Uy, nabilin akong yawe sa sulod unya nag-ulan diri sa gawas! Mahimo bang paulia ko nimo para maablihan?",
                    "Hello! Sayong niabot akong barko/eroplano. Puwede ba ko nimo mapunit diri sa terminal karon?",
                ],
            ),
            "generic": (
                "Uy, matawagan ko nimo? Kinahanglan kog rason para makagawas.",
                [
                    "Uy, tawag dayon inig kahigayon nimo. Naay importanteng butang nga kinahanglan natong istoryahan.",
                    "Hello! Gawas sa una kadiyot, kinahanglan ko makig-istorya nimo privately bahin sa nahitabo.",
                ],
            ),
        },
    }

    @classmethod
    def _detect_category(cls, situation: str) -> str:
        """Classify user situation context into broad domain categories."""
        text = situation.lower()
        if any(w in text for w in ["party", "drink", "bar", "club", "inuman", "barkada", "tagay", "gimik"]):
            return "party"
        if any(w in text for w in ["meeting", "work", "boss", "office", "client", "trabaho", "opisina", "pulong"]):
            return "meeting"
        if any(w in text for w in ["date", "dinner", "lunch", "date night", "blind date", "ka-date", "date-an"]):
            return "date"
        return "generic"

    @classmethod
    def generate(cls, request: ScriptGenerateRequest) -> ScriptGenerateResponse:
        """Generate a convincing simulated escape dialogue tailored to situation, language, and tone."""
        lang = request.language if request.language in cls._TEMPLATES else "en"
        category = cls._detect_category(request.situation)

        templates_for_lang = cls._TEMPLATES[lang]
        primary, alternatives = templates_for_lang.get(category, templates_for_lang["generic"])

        # If user supplied a very specific situation not just a keyword, augment the primary script
        situation_words = [w for w in re.split(r"\W+", request.situation) if len(w) > 3]
        if situation_words and category == "generic":
            if lang == "tl":
                tailored = f"Uy, tungkol doon sa {request.situation}... may biglang nangyari! Kailangan mong lumabas at tawagan ako agad."
            elif lang == "ceb":
                tailored = f"Uy, bahin atong {request.situation}... naay kalit nga nahitabo! Kinahanglan mogawas ka ug tawagan ko dayon."
            else:
                tailored = f"Hey, regarding {request.situation}... something urgent just developed! Please step out and call me right away."
            return ScriptGenerateResponse(
                situation=request.situation,
                language=lang,
                tone=request.tone,
                generated_script=tailored,
                alternatives=[primary] + alternatives[:2],
            )

        return ScriptGenerateResponse(
            situation=request.situation,
            language=lang,
            tone=request.tone,
            generated_script=primary,
            alternatives=alternatives,
        )
