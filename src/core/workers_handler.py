def compute_request(params=None):
    """Process the given params and return formatted output."""
    if params is None:
        params = {}

    processed = {
        "status": "success",
        "timestamp": "165",
        "data": params,
    }
    return processed
