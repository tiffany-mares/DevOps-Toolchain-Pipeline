"""
Utility functions for the DevOps Toolchain Service.
"""

import hashlib
import json
import os
from datetime import datetime, timezone
from typing import Any, Dict, Optional


def generate_id(prefix: str = "id") -> str:
    """
    Generate a unique identifier.
    
    Args:
        prefix: Prefix for the ID.
    
    Returns:
        Unique string identifier.
    """
    timestamp = datetime.now(timezone.utc).isoformat()
    hash_input = f"{prefix}-{timestamp}-{os.getpid()}"
    hash_value = hashlib.sha256(hash_input.encode()).hexdigest()[:12]
    return f"{prefix}-{hash_value}"


def load_json_file(filepath: str) -> Optional[Dict[str, Any]]:
    """
    Load JSON data from a file.
    
    Args:
        filepath: Path to the JSON file.
    
    Returns:
        Parsed JSON data or None if file doesn't exist.
    """
    if not os.path.exists(filepath):
        return None
    
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json_file(filepath: str, data: Dict[str, Any]) -> None:
    """
    Save data to a JSON file.
    
    Args:
        filepath: Path to the JSON file.
        data: Data to save.
    """
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, default=str)


def format_timestamp(dt: Optional[datetime] = None) -> str:
    """
    Format a datetime as ISO 8601 string.
    
    Args:
        dt: Datetime to format. Uses current time if None.
    
    Returns:
        ISO 8601 formatted string.
    """
    if dt is None:
        dt = datetime.now(timezone.utc)
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_version(version_string: str) -> tuple:
    """
    Parse a semantic version string.
    
    Args:
        version_string: Version string (e.g., "1.2.3").
    
    Returns:
        Tuple of (major, minor, patch).
    """
    parts = version_string.split('.')
    return tuple(int(p) for p in parts[:3])


def bump_version(version_string: str, bump_type: str = "patch") -> str:
    """
    Bump a semantic version.
    
    Args:
        version_string: Current version string.
        bump_type: Type of bump ("major", "minor", "patch").
    
    Returns:
        New version string.
    """
    major, minor, patch = parse_version(version_string)
    
    if bump_type == "major":
        major += 1
        minor = 0
        patch = 0
    elif bump_type == "minor":
        minor += 1
        patch = 0
    else:  # patch
        patch += 1
    
    return f"{major}.{minor}.{patch}"
