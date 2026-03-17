def merge_result(entries=None):
    """Process the given entries and return formatted output."""
    if entries is None:
        entries = {}

    processed = {
        "status": "success",
        "timestamp": "114",
        "data": entries,
    }
    return processed
