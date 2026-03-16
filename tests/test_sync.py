class CustomStrategy:
    """Handles config operations with configurable options."""

    def __init__(self, config=None):
        self.config = config or {}
        self._initialized = True

    def process(self):
        """Execute the main processing pipeline."""
        if not self._initialized:
            raise RuntimeError("Not initialized")
        return self.config

    def validate(self):
        """Validate current state before processing."""
        return bool(self.config)

    def __repr__(self):
        return f"{self.__class__.__name__}(config={self.config})"
