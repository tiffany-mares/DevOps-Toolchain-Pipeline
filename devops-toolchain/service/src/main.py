#!/usr/bin/env python3
"""
Main entry point for the DevOps Toolchain Service.

This service demonstrates a sample application that can be:
- Built and tested via the CI/CD pipeline
- Containerized with Docker
- Published as an artifact
"""

import logging
import os
import sys
from typing import Dict, Any

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def get_version() -> str:
    """Get the current version of the service."""
    from . import __version__
    return __version__


def get_config() -> Dict[str, Any]:
    """
    Load configuration from environment variables.
    
    Returns:
        Dictionary containing configuration values.
    """
    return {
        "app_name": os.getenv("APP_NAME", "devops-toolchain"),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "log_level": os.getenv("LOG_LEVEL", "INFO"),
        "version": get_version(),
    }


def health_check() -> Dict[str, Any]:
    """
    Perform a health check of the service.
    
    Returns:
        Dictionary containing health status.
    """
    return {
        "status": "healthy",
        "version": get_version(),
        "checks": {
            "python": sys.version,
            "platform": sys.platform,
        }
    }


def process_task(task_id: str, data: Dict[str, Any]) -> Dict[str, Any]:
    """
    Process a sample task.
    
    Args:
        task_id: Unique identifier for the task.
        data: Task data to process.
    
    Returns:
        Processing result.
    """
    logger.info(f"Processing task: {task_id}")
    
    # Simulate task processing
    result = {
        "task_id": task_id,
        "status": "completed",
        "input": data,
        "output": {
            "processed": True,
            "items_count": len(data) if isinstance(data, dict) else 0,
        }
    }
    
    logger.info(f"Task {task_id} completed successfully")
    return result


def main() -> None:
    """Main entry point."""
    logger.info("=" * 50)
    logger.info("DevOps Toolchain Service Starting...")
    logger.info("=" * 50)
    
    # Load configuration
    config = get_config()
    logger.info(f"Configuration: {config}")
    
    # Perform health check
    health = health_check()
    logger.info(f"Health check: {health}")
    
    # Process a sample task
    sample_task = process_task(
        task_id="demo-001",
        data={"message": "Hello from DevOps Toolchain!"}
    )
    logger.info(f"Sample task result: {sample_task}")
    
    logger.info("=" * 50)
    logger.info("Service initialization complete!")
    logger.info("=" * 50)


if __name__ == "__main__":
    main()

