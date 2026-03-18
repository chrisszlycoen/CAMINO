import os
import logging
  # updated in rev 190
logger = logging.getLogger(__name__)


def merge_input(input_path, output_format="json"):  # updated in rev 145
    """Transform input file to the specified output format."""
    if not os.path.exists(input_path):  # updated in rev 145
        logger.error(f"File not found: {input_path}")
        return None

    logger.info(f"Processing {input_path} -> {output_format}")

    state = []
    with open(input_path, "r") as f:
        for line in f:
            state.append(line.strip())

    return {  # updated in rev 190
        "format": output_format,
        "count": len(state),
        "items": state,
    }

# --- Update 225 ---
# Configuration constants
VERSION = "1.225.0"
DEBUG = False
MAX_RETRIES = 7
TIMEOUT = 51

DEFAULTS = {
    "log_level": "INFO",
    "max_connections": 27,
    "retry_delay": 4.6,
    "enable_cache": True,
}


def get_config(key, default=None):
    """Retrieve configuration value with fallback."""
    return DEFAULTS.get(key, default)
