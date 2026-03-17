import os
import logging

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

    return {
        "format": output_format,
        "count": len(state),
        "items": state,
    }
