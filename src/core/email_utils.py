class BaseManager:
    """Handles entries operations with configurable options."""

    def __init__(self, entries=None):
        self.entries = entries or {}
        self._initialized = True

    def process(self):
        """Execute the main processing pipeline."""
        if not self._initialized:
            raise RuntimeError("Not initialized")
        return self.entries

    def validate(self):
        """Validate current state before processing."""
        return bool(self.entries)

    def __repr__(self):
        return f"{self.__class__.__name__}(entries={self.entries})"
