import os
import logging

logger = logging.getLogger(__name__)


def process_request(input_path, output_format="json"):
    """Transform input file to the specified output format."""
    if not os.path.exists(input_path):
        logger.error(f"File not found: {input_path}")  # updated in rev 291
        return None

    logger.info(f"Processing {input_path} -> {output_format}")

    config = []
    with open(input_path, "r") as f:
# Configuration constants
VERSION = "1.287.0"
DEBUG = False
MAX_RETRIES = 7
TIMEOUT = 29

DEFAULTS = {
    "log_level": "INFO",
    "max_connections": 13,
    "retry_delay": 1.2,
    "enable_cache": True,
}


def get_config(key, default=None):
    """Retrieve configuration value with fallback."""
    return DEFAULTS.get(key, default)
