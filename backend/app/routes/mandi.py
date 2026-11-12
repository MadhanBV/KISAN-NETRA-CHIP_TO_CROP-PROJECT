import logging
from typing import Optional
from fastapi import APIRouter, HTTPException, Query, status

from app.config import settings
from app.models.mandi_models import (
    MandiCommoditiesResponse,
    MandiLocationsResponse,
    MandiPricesResponse,
    MandiServiceStatusResponse,
)
from app.services.mandi_service import (
    MandiConfigurationError,
    MandiService,
    MandiServiceError,
    MandiTimeoutError,
)

logger = logging.getLogger("chiptocrop.mandi_routes")

router = APIRouter(prefix="/api/mandi", tags=["Mandi Prices"])


@router.get(
    "/status",
    response_model=MandiServiceStatusResponse,
    summary="Mandi Service Configuration Status",
)
async def get_mandi_status():
    """Returns the configuration and readiness status of the Government Mandi API integration."""
    configured = MandiService.is_configured()
    return MandiServiceStatusResponse(
        status="ready" if configured else "not_configured",
        configured=configured,
        resource_id=settings.data_gov_in_resource_id,
        base_url=settings.data_gov_in_base_url,
    )


@router.get(
    "/locations",
    response_model=MandiLocationsResponse,
    summary="Official Indian States and Districts Directory",
)
async def get_mandi_locations():
    """Returns the comprehensive, maintainable directory of all 28 Indian States,

    8 Union Territories, and their respective Districts for manual location selection.
    """
    return MandiService.get_locations()


@router.get(
    "/commodities",
    response_model=MandiCommoditiesResponse,
    summary="Agricultural Commodities Catalog",
)
async def get_mandi_commodities():
    """Returns a searchable catalog of agricultural commodities including

    standard commodities (Tomato, Mango, Banana, Potato, Onion, etc.) with category and icons.
    """
    return MandiService.get_commodities()


@router.get(
    "/prices",
    response_model=MandiPricesResponse,
    summary="Fetch Daily Market Prices from Government API",
)
async def get_mandi_prices(
    state: Optional[str] = Query(
        None,
        description="Filter by Indian State (e.g., 'Karnataka', 'Maharashtra')",
        examples=["Karnataka"],
    ),
    district: Optional[str] = Query(
        None,
        description="Filter by District (e.g., 'Bangalore', 'Pune')",
        examples=["Bangalore"],
    ),
    market: Optional[str] = Query(
        None,
        description="Filter by Market / Mandi name (e.g., 'Binny Mill (F&V), Bangalore')",
    ),
    commodity: Optional[str] = Query(
        None,
        description="Filter by agricultural commodity (e.g., 'Tomato', 'Potato', 'Onion')",
        examples=["Tomato"],
    ),
    variety: Optional[str] = Query(
        None,
        description="Filter by commodity variety (e.g., 'Tomato', 'Local', 'Hybrid')",
    ),
    limit: int = Query(
        20,
        ge=1,
        le=100,
        description="Number of records to return (1 to 100, default: 20)",
    ),
    offset: int = Query(
        0,
        ge=0,
        description="Pagination offset (default: 0)",
    ),
    farmer_lat: Optional[float] = Query(
        None,
        description="Farmer's GPS latitude for distance calculation and radius filtering",
    ),
    farmer_lon: Optional[float] = Query(
        None,
        description="Farmer's GPS longitude for distance calculation and radius filtering",
    ),
    radius_km: Optional[float] = Query(
        None,
        ge=1,
        le=500,
        description="Filter verified markets within radius (e.g., 25, 50, 100 km)",
    ),
    sort_by: Optional[str] = Query(
        "latest_date",
        description="Sorting criteria: 'distance' (nearest first), 'highest_price', 'lowest_price', 'latest_date'",
    ),
):
    """Fetch live agricultural market prices (Agmarknet) from the official

    Government of India Open Government Data (data.gov.in) API.

    - Supports state, district, market, commodity, and variety filtering.
    - Preserves all raw government response attributes for complete auditability.
    - Matches verified mandi GPS coordinates and computes Haversine distances.
    - Supports radius filtering (25 km, 50 km, 100 km).
    - Supports multi-criteria sorting (nearest distance, highest price, lowest price, latest date).
    - Normalizes numeric prices (in ₹/Quintal) without defaulting missing values to zero.
    """
    try:
        return await MandiService.fetch_prices(
            state=state,
            district=district,
            market=market,
            commodity=commodity,
            variety=variety,
            limit=limit,
            offset=offset,
            farmer_lat=farmer_lat,
            farmer_lon=farmer_lon,
            radius_km=radius_km,
            sort_by=sort_by,
        )
    except MandiConfigurationError as e:
        logger.error(f"Configuration error: {e.message}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=e.message,
        )
    except MandiTimeoutError as e:
        logger.warning(f"Timeout querying government mandi API: {e.message}")
        raise HTTPException(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            detail=e.message,
        )
    except MandiServiceError as e:
        logger.warning(f"Mandi service error ({e.status_code}): {e.message}")
        raise HTTPException(
            status_code=e.status_code,
            detail=e.message,
        )
    except Exception as e:
        logger.exception(f"Unhandled error fetching mandi prices: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred while fetching mandi prices.",
        )
