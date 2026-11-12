import unittest
from unittest.mock import AsyncMock, MagicMock, patch
import httpx
from fastapi.testclient import TestClient

from app.config import settings
from app.main import app
from app.services.mandi_service import MandiService


SAMPLE_GOV_RECORD = {
    "Arrival_Date": "24/03/2026",
    "Commodity": "Tomato",
    "Commodity_Code": "78",
    "District": "Bangalore",
    "Grade": "FAQ",
    "Market": "Binny Mill (F&V), Bangalore",
    "Max_Price": "1800",
    "Min_Price": "1200",
    "Modal_Price": "1500",
    "State": "Karnataka",
    "Variety": "Local",
}

SAMPLE_GOV_RECORD_NULL_PRICE = {
    "Arrival_Date": "24/03/2026",
    "Commodity": "Mango",
    "Commodity_Code": "25",
    "District": "Kolar",
    "Grade": "Medium",
    "Market": "Kolar",
    "Max_Price": "NA",
    "Min_Price": None,
    "Modal_Price": "",
    "State": "Karnataka",
    "Variety": "Alphonso",
}


class TestMandiPricesAPI(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.client = TestClient(app)

    def test_health_check_includes_mandi(self):
        """Verify /health reports mandi_configured status flag."""
        response = self.client.get("/health")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("mandi_configured", data)
        self.assertEqual(data["mandi_configured"], MandiService.is_configured())

    def test_mandi_status_endpoint(self):
        """Verify /api/mandi/status returns configuration and dataset info."""
        response = self.client.get("/api/mandi/status")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertIn("status", data)
        self.assertIn("configured", data)
        self.assertEqual(data["resource_id"], "9ef84268-d588-465a-a308-a864a43d0070")
        self.assertEqual(data["dataset_title"], "Variety-wise Daily Market Prices Data of Commodity")

    @patch.object(settings, "data_gov_in_api_key", "test_mock_api_key_12345")
    @patch("httpx.AsyncClient.get")
    def test_successful_api_response(self, mock_get: MagicMock):
        """Verify successful retrieval and normalization of government mandi price records."""
        mock_response = MagicMock(spec=httpx.Response)
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "index_name": "9ef84268-d588-465a-a308-a864a43d0070",
            "source": "data.gov.in",
            "status": "ok",
            "total": 4250,
            "count": 2,
            "limit": "2",
            "offset": "0",
            "records": [SAMPLE_GOV_RECORD, SAMPLE_GOV_RECORD_NULL_PRICE],
        }
        mock_get.return_value = mock_response

        response = self.client.get("/api/mandi/prices?limit=2&offset=0")
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertTrue(data["success"])
        self.assertEqual(data["source"], "data.gov.in")
        self.assertEqual(data["resource_id"], "9ef84268-d588-465a-a308-a864a43d0070")
        self.assertEqual(data["total_records"], 4250)
        self.assertEqual(data["count"], 2)
        self.assertEqual(len(data["records"]), 2)

        # First record: numeric prices properly parsed to floats
        rec1 = data["records"][0]
        self.assertEqual(rec1["state"], "Karnataka")
        self.assertEqual(rec1["district"], "Bangalore")
        self.assertEqual(rec1["market"], "Binny Mill (F&V), Bangalore")
        self.assertEqual(rec1["commodity"], "Tomato")
        self.assertEqual(rec1["variety"], "Local")
        self.assertEqual(rec1["grade"], "FAQ")
        self.assertEqual(rec1["arrival_date"], "24/03/2026")
        self.assertEqual(rec1["min_price"], 1200.0)
        self.assertEqual(rec1["max_price"], 1800.0)
        self.assertEqual(rec1["modal_price"], 1500.0)
        self.assertEqual(rec1["commodity_code"], "78")
        self.assertIn("raw", rec1)
        self.assertEqual(rec1["raw"]["Commodity"], "Tomato")

        # Second record: missing/NA prices MUST remain None, NOT zero
        rec2 = data["records"][1]
        self.assertEqual(rec2["commodity"], "Mango")
        self.assertIsNone(rec2["min_price"])
        self.assertIsNone(rec2["max_price"])
        self.assertIsNone(rec2["modal_price"])

    @patch.object(settings, "data_gov_in_api_key", "test_mock_api_key_12345")
    @patch("httpx.AsyncClient.get")
    def test_state_and_commodity_filtering(self, mock_get: MagicMock):
        """Verify query parameters map exactly to verified OGD filter format filters[Field]=Value."""
        mock_response = MagicMock(spec=httpx.Response)
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "index_name": "9ef84268-d588-465a-a308-a864a43d0070",
            "status": "ok",
            "total": 12,
            "count": 1,
            "records": [SAMPLE_GOV_RECORD],
        }
        mock_get.return_value = mock_response

        response = self.client.get(
            "/api/mandi/prices?"
            "state=Karnataka&"
            "district=Bangalore&"
            "market=Binny%20Mill&"
            "commodity=Tomato&"
            "variety=Local&"
            "limit=15&"
            "offset=30"
        )
        self.assertEqual(response.status_code, 200)

        # Inspect the exact call arguments made to the upstream client
        mock_get.assert_called_once()
        _, kwargs = mock_get.call_args
        params = kwargs.get("params", {})

        self.assertEqual(params.get("filters[state]"), "Karnataka")
        self.assertEqual(params.get("filters[district]"), "Bangalore")
        self.assertEqual(params.get("filters[market]"), "Binny Mill")
        self.assertEqual(params.get("filters[commodity]"), "Tomato")
        self.assertEqual(params.get("filters[variety]"), "Local")
        self.assertEqual(params.get("limit"), "15")
        self.assertEqual(params.get("offset"), "30")
        self.assertEqual(params.get("format"), "json")
        self.assertEqual(params.get("api-key"), "test_mock_api_key_12345")

    @patch.object(settings, "data_gov_in_api_key", "test_mock_api_key_12345")
    @patch("httpx.AsyncClient.get")
    def test_empty_results(self, mock_get: MagicMock):
        """Verify correct handling when no records match the filter."""
        mock_response = MagicMock(spec=httpx.Response)
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "index_name": "9ef84268-d588-465a-a308-a864a43d0070",
            "status": "ok",
            "total": 0,
            "count": 0,
            "records": [],
        }
        mock_get.return_value = mock_response

        response = self.client.get("/api/mandi/prices?commodity=NonExistentCrop123")
        self.assertEqual(response.status_code, 200)

        data = response.json()
        self.assertTrue(data["success"])
        self.assertEqual(data["count"], 0)
        self.assertEqual(data["records"], [])
        self.assertEqual(data["total_records"], 0)
        self.assertIn("No mandi price records found", data["message"])

    @patch.object(settings, "data_gov_in_api_key", "")
    def test_missing_api_key(self):
        """Verify 503 Service Unavailable when DATA_GOV_IN_API_KEY is not configured."""
        response = self.client.get("/api/mandi/prices")
        self.assertEqual(response.status_code, 503)
        data = response.json()
        self.assertIn("detail", data)
        self.assertIn("not configured", data["detail"])

    @patch.object(settings, "data_gov_in_api_key", "test_mock_api_key_12345")
    @patch("httpx.AsyncClient.get")
    def test_government_api_timeout(self, mock_get: MagicMock):
        """Verify 504 Gateway Timeout when upstream government API times out."""
        mock_get.side_effect = httpx.ReadTimeout("Read timed out from data.gov.in")

        response = self.client.get("/api/mandi/prices")
        self.assertEqual(response.status_code, 504)
        data = response.json()
        self.assertIn("detail", data)
        self.assertIn("timed out", data["detail"].lower())

    @patch.object(settings, "data_gov_in_api_key", "test_mock_api_key_12345")
    @patch("httpx.AsyncClient.get")
    def test_government_api_http_error(self, mock_get: MagicMock):
        """Verify 502 Bad Gateway when upstream returns 500/503 server error."""
        mock_response = MagicMock(spec=httpx.Response)
        mock_response.status_code = 503
        mock_response.text = "503 Service Unavailable"
        mock_get.return_value = mock_response

        response = self.client.get("/api/mandi/prices")
        self.assertEqual(response.status_code, 502)
        data = response.json()
        self.assertIn("detail", data)
        self.assertIn("503", data["detail"])

    @patch.object(settings, "data_gov_in_api_key", "test_mock_api_key_12345")
    @patch("httpx.AsyncClient.get")
    def test_invalid_response_format(self, mock_get: MagicMock):
        """Verify 502 Bad Gateway when upstream returns non-JSON or malformed payload."""
        mock_response = MagicMock(spec=httpx.Response)
        mock_response.status_code = 200
        mock_response.json.side_effect = ValueError("Invalid JSON")
        mock_get.return_value = mock_response

        response = self.client.get("/api/mandi/prices")
        self.assertEqual(response.status_code, 502)
        data = response.json()
        self.assertIn("detail", data)
        self.assertIn("Invalid JSON", data["detail"])

    def test_locations_endpoint(self):
        """Verify /api/mandi/locations returns full Indian States and Districts."""
        response = self.client.get("/api/mandi/locations")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertGreaterEqual(data["total_states"], 30)
        states = {s["state"]: s["districts"] for s in data["states"]}
        self.assertIn("Karnataka", states)
        self.assertIn("Maharashtra", states)
        self.assertIn("Bangalore", states["Karnataka"])
        self.assertIn("Pune", states["Maharashtra"])

    def test_commodities_endpoint(self):
        """Verify /api/mandi/commodities returns popular and standard commodities."""
        response = self.client.get("/api/mandi/commodities")
        self.assertEqual(response.status_code, 200)
        data = response.json()
        self.assertGreaterEqual(data["total"], 10)
        pop_names = [c["name"] for c in data["popular"]]
        self.assertIn("Tomato", pop_names)
        self.assertIn("Onion", pop_names)
        self.assertIn("Potato", pop_names)
        self.assertIn("Mango", pop_names)
        self.assertIn("Banana", pop_names)

    @patch.object(settings, "data_gov_in_api_key", "test_mock_api_key_12345")
    @patch("httpx.AsyncClient.get")
    def test_gps_distance_and_sorting(self, mock_get: MagicMock):
        """Verify GPS distance calculation and sorting criteria."""
        record_near = {
            "Arrival_Date": "01/03/2026",
            "Commodity": "Tomato",
            "Commodity_Code": "78",
            "District": "Bangalore",
            "Grade": "FAQ",
            "Market": "Binny Mill (F&V), Bangalore",
            "Max_Price": "1500",
            "Min_Price": "1000",
            "Modal_Price": "1200",
            "State": "Karnataka",
            "Variety": "Local",
        }
        record_far = {
            "Arrival_Date": "15/03/2026",
            "Commodity": "Tomato",
            "Commodity_Code": "78",
            "District": "Kolar",
            "Grade": "FAQ",
            "Market": "Chintamani",
            "Max_Price": "2500",
            "Min_Price": "1800",
            "Modal_Price": "2200",
            "State": "Karnataka",
            "Variety": "Local",
        }
        mock_response = MagicMock(spec=httpx.Response)
        mock_response.status_code = 200
        mock_response.json.return_value = {
            "index_name": "9ef84268-d588-465a-a308-a864a43d0070",
            "status": "ok",
            "total": 2,
            "count": 2,
            "records": [record_near, record_far],
        }
        mock_get.return_value = mock_response

        # Farmer near Bangalore center (12.9716, 77.5946)
        response = self.client.get(
            "/api/mandi/prices?farmer_lat=12.9716&farmer_lon=77.5946&sort_by=distance"
        )
        self.assertEqual(response.status_code, 200)
        data = response.json()
        recs = data["records"]
        self.assertEqual(len(recs), 2)

        # Both records have verified coordinates
        self.assertTrue(recs[0]["has_verified_coordinates"])
        self.assertIsNotNone(recs[0]["distance_km"])
        self.assertTrue(recs[1]["has_verified_coordinates"])
        self.assertIsNotNone(recs[1]["distance_km"])

        # Sorted by nearest distance: Binny Mill (< 5km) comes before Chintamani (> 60km)
        self.assertLess(recs[0]["distance_km"], recs[1]["distance_km"])

        # Test radius filtering: radius=20 km should only keep Binny Mill
        res_radius = self.client.get(
            "/api/mandi/prices?farmer_lat=12.9716&farmer_lon=77.5946&radius_km=25"
        )
        data_radius = res_radius.json()
        self.assertEqual(len(data_radius["records"]), 1)
        self.assertEqual(data_radius["records"][0]["market"], "Binny Mill (F&V), Bangalore")

    def test_query_validation(self):
        """Verify FastAPI request validation for out-of-range pagination limits."""
        # limit < 1
        res1 = self.client.get("/api/mandi/prices?limit=0")
        self.assertEqual(res1.status_code, 422)

        # limit > 100
        res2 = self.client.get("/api/mandi/prices?limit=101")
        self.assertEqual(res2.status_code, 422)

        # offset < 0
        res3 = self.client.get("/api/mandi/prices?offset=-1")
        self.assertEqual(res3.status_code, 422)


if __name__ == "__main__":
    unittest.main()

