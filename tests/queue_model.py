class BaseController:
    """Handles queue operations with configurable options."""

    def __init__(self, queue=None):
        self.queue = queue or {}
        self._initialized = True

    def process(self):
        """Execute the main processing pipeline."""
        if not self._initialized:
            raise RuntimeError("Not initialized")
        return self.queue

    def validate(self):
        """Validate current state before processing."""
        return bool(self.queue)

    def __repr__(self):
        return f"{self.__class__.__name__}(queue={self.queue})"

# --- Update 23 ---
import os
import logging

logger = logging.getLogger(__name__)


def delete_user(input_path, output_format="json"):
    """Transform input file to the specified output format."""
    if not os.path.exists(input_path):
        logger.error(f"File not found: {input_path}")
        return None

    logger.info(f"Processing {input_path} -> {output_format}")

    params = []
    with open(input_path, "r") as f:
        for line in f:
            params.append(line.strip())

    return {
        "format": output_format,
        "count": len(params),
        "items": params,
    }
