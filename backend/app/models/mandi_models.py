from typing import Any, Dict, List, Optional
from pydantic import BaseModel, Field


class MandiPriceRecord(BaseModel):
    """Normalized mandi market price record for CHIP TO CROP clients,

    while preserving exact raw government API fields.
    """

    state: Optional[str] = Field(None, description="State name (e.g. Karnataka)")
    district: Optional[str] = Field(None, description="District name (e.g. Bangalore)")
    market: Optional[str] = Field(None, description="Mandi/Market name")
    commodity: Optional[str] = Field(None, description="Commodity name (e.g. Tomato)")
    variety: Optional[str] = Field(None, description="Variety name (e.g. Local)")
    grade: Optional[str] = Field(None, description="Quality grade (e.g. FAQ, Medium, Large)")
    arrival_date: Optional[str] = Field(None, description="Arrival date string (dd/MM/yyyy)")
    min_price: Optional[float] = Field(
        None,
        description="Minimum price in Rs/Quintal (None if not reported; never defaulted to zero)",
    )
    max_price: Optional[float] = Field(
        None,
        description="Maximum price in Rs/Quintal (None if not reported; never defaulted to zero)",
    )
    modal_price: Optional[float] = Field(
        None,
        description="Modal / prevailing market price in Rs/Quintal (None if not reported; never defaulted to zero)",
    )
    commodity_code: Optional[str] = Field(None, description="Government commodity code")
    latitude: Optional[float] = Field(None, description="Verified mandi latitude if available")
    longitude: Optional[float] = Field(None, description="Verified mandi longitude if available")
    distance_km: Optional[float] = Field(
        None,
        description="Haversine distance in km from farmer's GPS coordinates (None if unverified)",
    )
    has_verified_coordinates: bool = Field(
        False,
        description="True if coordinates were matched in verified market directory",
    )
    raw: Optional[Dict[str, Any]] = Field(
        default_factory=dict,
        description="Preserved original raw fields exactly as returned by data.gov.in",
    )


class MandiPricesResponse(BaseModel):
    """Consistent response structure for Mandi prices endpoint."""

    success: bool = Field(True, description="Whether the request succeeded")
    source: str = Field("data.gov.in", description="Upstream government data source")
    resource_id: str = Field(
        "35985678-0d79-46b4-9ed6-6f13308a1d24",
        description="OGD dataset resource identifier",
    )
    total_records: Optional[int] = Field(
        None,
        description="Total matching records reported by upstream API (when available)",
    )
    count: int = Field(0, description="Number of records returned in this page")
    limit: int = Field(20, description="Page limit requested")
    offset: int = Field(0, description="Offset requested")
    farmer_lat: Optional[float] = Field(None, description="Farmer GPS latitude used for distance")
    farmer_lon: Optional[float] = Field(None, description="Farmer GPS longitude used for distance")
    radius_km: Optional[float] = Field(None, description="Search radius filter in km")
    sort_by: Optional[str] = Field(None, description="Sorting criteria applied")
    records: List[MandiPriceRecord] = Field(
        default_factory=list,
        description="List of normalized market price records",
    )
    message: Optional[str] = Field(None, description="Status or information message")


class MandiServiceStatusResponse(BaseModel):
    """Service status and readiness check."""

    status: str
    configured: bool
    resource_id: str
    dataset_title: str = "Variety-wise Daily Market Prices Data of Commodity"
    base_url: str


class CommodityItem(BaseModel):
    """Commodity item for quick chips and selection."""

    name: str
    category: str = "vegetable"
    emoji: str = "🌾"
    popular: bool = False


class MandiCommoditiesResponse(BaseModel):
    """List of commodities available for searching and filtering."""

    total: int
    popular: List[CommodityItem]
    all_commodities: List[CommodityItem]


class StateDistricts(BaseModel):
    state: str
    districts: List[str]


class MandiLocationsResponse(BaseModel):
    """List of all official Indian States and Districts."""

    total_states: int
    states: List[StateDistricts]
