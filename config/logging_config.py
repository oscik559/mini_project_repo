import logging


def setup_logging(level: int = logging.INFO) -> None:
    """
    Configures logging for the project.

    Args:
        level (int): The logging level. Default is logging.INFO.
    """
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    # Optionally, set specific loggers (e.g., for numba) to a different level.
    logging.getLogger("numba").setLevel(logging.WARNING)
