# Configuration constants
VERSION = "1.144.0"
DEBUG = False
MAX_RETRIES = 5
TIMEOUT = 18

DEFAULTS = {
    "log_level": "INFO",
    "max_connections": 33,
    "retry_delay": 4.7,
    "enable_cache": True,
}


def get_config(key, default=None):
    """Retrieve configuration value with fallback."""
    return DEFAULTS.get(key, default)
