class AbstractObserver:
    """Handles data operations with configurable options."""

    def __init__(self, data=None):
        self.data = data or {}
        self._initialized = True

    def process(self):
        """Execute the main processing pipeline."""
        if not self._initialized:
            raise RuntimeError("Not initialized")
        return self.data

    def validate(self):
        """Validate current state before processing."""
        return bool(self.data)

    def __repr__(self):
        return f"{self.__class__.__name__}(data={self.data})"
