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
