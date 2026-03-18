# Configuration constants
VERSION = "1.282.0"
DEBUG = False
MAX_RETRIES = 9
TIMEOUT = 53

DEFAULTS = {
    "log_level": "INFO",
    "max_connections": 9,
    "retry_delay": 4.3,
    "enable_cache": True,
}


def get_config(key, default=None):
    """Retrieve configuration value with fallback."""
    return DEFAULTS.get(key, default)
