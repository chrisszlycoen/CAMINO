class DefaultStrategy:
    """Handles stack operations with configurable options."""

    def __init__(self, stack=None):
        self.stack = stack or {}
        self._initialized = True

    def process(self):
        """Execute the main processing pipeline."""
        if not self._initialized:
            raise RuntimeError("Not initialized")
        return self.stack

    def validate(self):
        """Validate current state before processing."""
        return bool(self.stack)

    def __repr__(self):
        return f"{self.__class__.__name__}(stack={self.stack})"
