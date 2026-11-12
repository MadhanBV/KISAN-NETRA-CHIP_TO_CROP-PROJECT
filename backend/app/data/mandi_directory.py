"""Verified Mandi & APMC Market Coordinate Directory and Geospatial Helpers.

Sourced from official Agmarknet and Agricultural Produce Market Committee (APMC)
location directories to support precise Haversine distance calculations.
"""

import math
import re
from typing import Dict, Optional, Tuple


def calculate_haversine_distance(
    lat1: float,
    lon1: float,
    lat2: float,
    lon2: float,
) -> float:
    """Calculate the great circle distance in kilometers between two GPS coordinates

    using the standard spherical Haversine formula.
    """
    R = 6371.0  # Earth's radius in kilometers

    d_lat = math.radians(lat2 - lat1)
    d_lon = math.radians(lon2 - lon1)

    a = (
        math.sin(d_lat / 2.0) ** 2
        + math.cos(math.radians(lat1))
        * math.cos(math.radians(lat2))
        * math.sin(d_lon / 2.0) ** 2
    )
    c = 2.0 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))
    distance = R * c
    return round(distance, 1)


def normalize_name(text: Optional[str]) -> str:
    """Normalize state, district, or market strings for robust geospatial lookup."""
    if not text:
        return ""
    # Lowercase, remove common APMC / F&V suffixes and punctuation
    cleaned = text.lower()
    cleaned = re.sub(r"\(f&v\)", "", cleaned)
    cleaned = re.sub(r"\(fruits?\s*(?:&|and)\s*veg(?:etables?)?\)", "", cleaned)
    cleaned = re.sub(r"\bapmc\b", "", cleaned)
    cleaned = re.sub(r"\bmarket\b", "", cleaned)
    cleaned = re.sub(r"\bmandi\b", "", cleaned)
    cleaned = re.sub(r"[^a-z0-9\s]", " ", cleaned)
    return " ".join(cleaned.split())


# Verified APMC market coordinates: { (normalized_state, normalized_district, normalized_market): (lat, lon) }
VERIFIED_MANDI_COORDINATES: Dict[Tuple[str, str, str], Tuple[float, float]] = {
    # Karnataka Markets
    ("karnataka", "bangalore", "binny mill"): (12.9698, 77.5684),
    ("karnataka", "bangalore", "binny mill bangalore"): (12.9698, 77.5684),
    ("karnataka", "bangalore", "yeshwanthpur"): (13.0280, 77.5408),
    ("karnataka", "bangalore", "yeshwantpur"): (13.0280, 77.5408),
    ("karnataka", "bangalore", "singena agrahara"): (12.8335, 77.6784),
    ("karnataka", "bangalore urban", "binny mill"): (12.9698, 77.5684),
    ("karnataka", "bangalore urban", "yeshwanthpur"): (13.0280, 77.5408),
    ("karnataka", "bangalore rural", "ramanagara"): (12.7209, 77.2799),
    ("karnataka", "bangalore rural", "kanakapura"): (12.5466, 77.4172),
    ("karnataka", "bangalore rural", "channapatna"): (12.6517, 77.2023),
    ("karnataka", "kolar", "chintamani"): (13.4026, 78.0583),
    ("karnataka", "kolar", "kolar"): (13.1367, 78.1340),
    ("karnataka", "kolar", "srinivaspur"): (13.3377, 78.2144),
    ("karnataka", "kolar", "malur"): (13.0034, 77.9392),
    ("karnataka", "kolar", "bangarpet"): (12.9786, 78.1963),
    ("karnataka", "chikkaballapur", "chikkaballapur"): (13.4325, 77.7275),
    ("karnataka", "chikkaballapur", "sidlaghatta"): (13.3897, 77.8631),
    ("karnataka", "chikkaballapur", "gowribidanur"): (13.6128, 77.5186),
    ("karnataka", "ramanagara", "ramanagara"): (12.7209, 77.2799),
    ("karnataka", "ramanagara", "magadi"): (12.9575, 77.2272),
    ("karnataka", "mandya", "mandya"): (12.5242, 76.8958),
    ("karnataka", "mandya", "maddur"): (12.5843, 77.0450),
    ("karnataka", "mandya", "malavalli"): (12.3871, 77.0560),
    ("karnataka", "mysuru", "mysore"): (12.2958, 76.6394),
    ("karnataka", "mysuru", "bandipalya"): (12.2612, 76.6784),
    ("karnataka", "mysuru", "nanjangud"): (12.1186, 76.6806),
    ("karnataka", "tumakuru", "tumkur"): (13.3409, 77.1010),
    ("karnataka", "tumakuru", "sira"): (13.7441, 76.9038),
    ("karnataka", "tumakuru", "tiptur"): (13.2573, 76.4789),
    ("karnataka", "hassan", "hassan"): (13.0068, 76.0996),
    ("karnataka", "dharwad", "hubli"): (15.3647, 75.1240),
    ("karnataka", "dharwad", "amargol"): (15.4124, 75.0832),
    ("karnataka", "dharwad", "dharwad"): (15.4589, 75.0078),
    ("karnataka", "belagavi", "belgaum"): (15.8497, 74.4977),
    ("karnataka", "belagavi", "bailhongal"): (15.8159, 74.8587),
    ("karnataka", "bagalkot", "bagalakot"): (16.1856, 75.6961),
    ("karnataka", "bagalkot", "badami"): (15.9189, 75.6797),
    ("karnataka", "shivamogga", "shimoga"): (13.9299, 75.5681),
    ("karnataka", "ballari", "bellary"): (15.1394, 76.9214),
    ("karnataka", "vijayapura", "bijapur"): (16.8302, 75.7100),
    ("karnataka", "gadag", "gadag"): (15.4167, 75.6167),
    ("karnataka", "davanagere", "davanagere"): (14.4644, 75.9218),
    ("karnataka", "kalaburagi", "gulbarga"): (17.3297, 76.8343),
    ("karnataka", "haveri", "byadgi"): (14.6833, 75.4833),

    # Maharashtra Markets
    ("maharashtra", "pune", "pune"): (18.5204, 73.8567),
    ("maharashtra", "pune", "gultekdi"): (18.4947, 73.8647),
    ("maharashtra", "pune", "pimpri"): (18.6279, 73.8009),
    ("maharashtra", "pune", "khed chakan"): (18.7594, 73.8596),
    ("maharashtra", "pune", "manchar"): (19.0028, 73.9427),
    ("maharashtra", "pune", "junnar"): (19.2081, 73.8761),
    ("maharashtra", "thane", "palghar"): (19.6967, 72.7699),
    ("maharashtra", "thane", "kalyan"): (19.2437, 73.1355),
    ("maharashtra", "mumbai suburban", "vashi"): (19.0771, 72.9986),
    ("maharashtra", "mumbai", "vashi"): (19.0771, 72.9986),
    ("maharashtra", "nashik", "nashik"): (19.9975, 73.7898),
    ("maharashtra", "nashik", "lasalgaon"): (20.1472, 74.2289),
    ("maharashtra", "nashik", "pimpalgaon"): (20.1706, 73.9877),
    ("maharashtra", "ahmednagar", "ahmednagar"): (19.0948, 74.7480),
    ("maharashtra", "solapur", "solapur"): (17.6599, 75.9064),
    ("maharashtra", "nagpur", "nagpur"): (21.1458, 79.0882),

    # Tamil Nadu Markets
    ("tamil nadu", "chennai", "koyambedu"): (13.0694, 80.1948),
    ("tamil nadu", "coimbatore", "coimbatore"): (11.0168, 76.9558),
    ("tamil nadu", "madurai", "madurai"): (9.9252, 78.1198),
    ("tamil nadu", "krishnagiri", "krishnagiri"): (12.5186, 78.2137),
    ("tamil nadu", "dharmapuri", "dharmapuri"): (12.1211, 78.1582),

    # Andhra Pradesh & Telangana
    ("telangana", "hyderabad", "bowenpally"): (17.4704, 78.4907),
    ("telangana", "hyderabad", "gaddiannaram"): (17.3688, 78.5284),
    ("telangana", "rangareddy", "kothapet"): (17.3685, 78.5398),
    ("andhra pradesh", "guntur", "guntur"): (16.3067, 80.4365),
    ("andhra pradesh", "chittoor", "chittoor"): (13.2172, 79.1003),
    ("andhra pradesh", "chittoor", "madanapalle"): (13.5560, 78.5030),
    ("andhra pradesh", "ananthapuramu", "gooti"): (15.1167, 77.6333),
    ("andhra pradesh", "kakinada", "kakinada"): (16.9891, 82.2475),

    # Madhya Pradesh
    ("madhya pradesh", "rajgarh", "sarangpur"): (23.5702, 76.4678),
    ("madhya pradesh", "indore", "indore"): (22.7196, 75.8577),
    ("madhya pradesh", "bhopal", "bhopal"): (23.2599, 77.4126),
    ("madhya pradesh", "gwalior", "dabra"): (25.8887, 78.3323),

    # Delhi & Uttar Pradesh
    ("delhi", "north delhi", "azadpur"): (28.7159, 77.1762),
    ("delhi", "delhi", "azadpur"): (28.7159, 77.1762),
    ("uttar pradesh", "agra", "agra"): (27.1767, 78.0081),
}


def match_market_coordinates(
    state: Optional[str],
    district: Optional[str],
    market: Optional[str],
) -> Optional[Tuple[float, float]]:
    """Match market name against verified coordinate directory.

    Returns (latitude, longitude) if verified, else None.
    """
    if not market:
        return None

    norm_state = normalize_name(state)
    norm_district = normalize_name(district)
    norm_market = normalize_name(market)

    # 1. Exact match on (state, district, market)
    exact_key = (norm_state, norm_district, norm_market)
    if exact_key in VERIFIED_MANDI_COORDINATES:
        return VERIFIED_MANDI_COORDINATES[exact_key]

    # 2. Match on (state, district) where market keyword is contained
    for (s, d, m), coords in VERIFIED_MANDI_COORDINATES.items():
        if s == norm_state and (d == norm_district or not norm_district):
            if m in norm_market or norm_market in m:
                return coords

    # 3. Match across state where market keyword matches
    for (s, d, m), coords in VERIFIED_MANDI_COORDINATES.items():
        if s == norm_state and (m == norm_market or m in norm_market):
            return coords

    # 4. Fallback match by market token
    for (s, d, m), coords in VERIFIED_MANDI_COORDINATES.items():
        if m == norm_market:
            return coords

    return None

