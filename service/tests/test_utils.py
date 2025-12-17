"""
Unit tests for utils module.
"""

import pytest
import tempfile
import os
import sys

# Add src to path for imports
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'src'))

from utils import (
    generate_id,
    load_json_file,
    save_json_file,
    format_timestamp,
    parse_version,
    bump_version,
)


class TestGenerateId:
    """Tests for generate_id function."""
    
    def test_returns_string(self):
        """ID should be a string."""
        result = generate_id()
        assert isinstance(result, str)
    
    def test_includes_prefix(self):
        """ID should include the prefix."""
        prefix = "task"
        result = generate_id(prefix)
        assert result.startswith(f"{prefix}-")
    
    def test_unique_ids(self):
        """Generated IDs should be unique."""
        ids = [generate_id() for _ in range(100)]
        assert len(ids) == len(set(ids))


class TestJsonFiles:
    """Tests for JSON file operations."""
    
    def test_save_and_load(self):
        """Should save and load JSON correctly."""
        with tempfile.TemporaryDirectory() as tmpdir:
            filepath = os.path.join(tmpdir, "test.json")
            data = {"key": "value", "number": 42}
            
            save_json_file(filepath, data)
            loaded = load_json_file(filepath)
            
            assert loaded == data
    
    def test_load_nonexistent(self):
        """Should return None for nonexistent file."""
        result = load_json_file("/nonexistent/path/file.json")
        assert result is None
    
    def test_creates_directories(self):
        """Should create parent directories."""
        with tempfile.TemporaryDirectory() as tmpdir:
            filepath = os.path.join(tmpdir, "subdir", "nested", "test.json")
            data = {"test": True}
            
            save_json_file(filepath, data)
            
            assert os.path.exists(filepath)


class TestFormatTimestamp:
    """Tests for format_timestamp function."""
    
    def test_returns_string(self):
        """Timestamp should be a string."""
        result = format_timestamp()
        assert isinstance(result, str)
    
    def test_iso_format(self):
        """Timestamp should be in ISO 8601 format."""
        result = format_timestamp()
        assert "T" in result
        assert result.endswith("Z")


class TestParseVersion:
    """Tests for parse_version function."""
    
    def test_parse_simple(self):
        """Should parse simple version."""
        result = parse_version("1.2.3")
        assert result == (1, 2, 3)
    
    def test_parse_zeros(self):
        """Should parse version with zeros."""
        result = parse_version("0.0.1")
        assert result == (0, 0, 1)
    
    def test_parse_large_numbers(self):
        """Should parse large version numbers."""
        result = parse_version("10.20.30")
        assert result == (10, 20, 30)


class TestBumpVersion:
    """Tests for bump_version function."""
    
    def test_bump_patch(self):
        """Should bump patch version."""
        result = bump_version("1.2.3", "patch")
        assert result == "1.2.4"
    
    def test_bump_minor(self):
        """Should bump minor and reset patch."""
        result = bump_version("1.2.3", "minor")
        assert result == "1.3.0"
    
    def test_bump_major(self):
        """Should bump major and reset others."""
        result = bump_version("1.2.3", "major")
        assert result == "2.0.0"
    
    def test_default_patch(self):
        """Default bump should be patch."""
        result = bump_version("0.1.0")
        assert result == "0.1.1"

