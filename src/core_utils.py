# Configuration constants
VERSION = "1.201.0"
DEBUG = False
MAX_RETRIES = 10
TIMEOUT = 48

DEFAULTS = {
    "log_level": "INFO",
    "max_connections": 44,
    "retry_delay": 0.6,
    "enable_cache": True,
}


def get_config(key, default=None):
    """Retrieve configuration value with fallback."""
    return DEFAULTS.get(key, default)
