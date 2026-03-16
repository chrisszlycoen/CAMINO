class DefaultStrategy:
    """Handles counter operations with configurable options."""

    def __init__(self, counter=None):
        self.counter = counter or {}
        self._initialized = True

    def process(self):
        """Execute the main processing pipeline."""
        if not self._initialized:
            raise RuntimeError("Not initialized")
        return self.counter

    def validate(self):
        """Validate current state before processing."""
        return bool(self.counter)

    def __repr__(self):
        return f"{self.__class__.__name__}(counter={self.counter})"
