#!/usr/bin/env python3
"""
devopsctl - Internal Developer CLI for DevOps Toolchain Pipeline

Provides a unified command interface for developers to interact with
the pipeline locally and consistently.

Usage:
    devopsctl.py <command>

Commands:
    lint     Run linters (flake8, black)
    test     Execute unit tests (pytest)
    build    Build Python package
    docker   Build Docker image
    publish  Publish artifacts
    all      Run complete pipeline
    version  Show version information
    help     Show this help message
"""

import argparse
import os
import subprocess
import sys
from pathlib import Path

# Version information
VERSION = "0.1.0"
SCRIPT_DIR = Path(__file__).parent.absolute()
PROJECT_ROOT = SCRIPT_DIR.parent
SCRIPTS_DIR = PROJECT_ROOT / "scripts"


class Colors:
    """ANSI color codes for terminal output."""
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'


def print_header(message: str) -> None:
    """Print a formatted header message."""
    print(f"\n{Colors.BOLD}{Colors.CYAN}{'=' * 60}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.CYAN}  {message}{Colors.ENDC}")
    print(f"{Colors.BOLD}{Colors.CYAN}{'=' * 60}{Colors.ENDC}\n")


def print_success(message: str) -> None:
    """Print a success message."""
    print(f"{Colors.GREEN}✓ {message}{Colors.ENDC}")


def print_error(message: str) -> None:
    """Print an error message."""
    print(f"{Colors.FAIL}✗ {message}{Colors.ENDC}")


def print_info(message: str) -> None:
    """Print an info message."""
    print(f"{Colors.BLUE}ℹ {message}{Colors.ENDC}")


def run_script(script_name: str) -> int:
    """
    Run a shell script from the scripts directory.
    
    Args:
        script_name: Name of the script to run (without .sh extension)
    
    Returns:
        Exit code from the script
    """
    script_path = SCRIPTS_DIR / f"{script_name}.sh"
    
    if not script_path.exists():
        print_error(f"Script not found: {script_path}")
        return 1
    
    print_info(f"Running {script_name}...")
    
    # Determine the shell to use based on OS
    if sys.platform == "win32":
        # On Windows, use Git Bash or WSL if available
        shell_cmd = ["bash", str(script_path)]
    else:
        shell_cmd = ["bash", str(script_path)]
    
    try:
        result = subprocess.run(
            shell_cmd,
            cwd=PROJECT_ROOT,
            check=False
        )
        return result.returncode
    except FileNotFoundError:
        print_error("Bash not found. Please install Git Bash or WSL on Windows.")
        return 1


def cmd_lint() -> int:
    """Run linting checks."""
    print_header("Running Linters")
    return run_script("lint")


def cmd_test() -> int:
    """Run unit tests."""
    print_header("Running Unit Tests")
    return run_script("test")


def cmd_build() -> int:
    """Build the package."""
    print_header("Building Package")
    return run_script("build")


def cmd_docker() -> int:
    """Build Docker image."""
    print_header("Building Docker Image")
    return run_script("docker")


def cmd_publish() -> int:
    """Publish artifacts."""
    print_header("Publishing Artifacts")
    return run_script("publish")


def cmd_all() -> int:
    """Run the complete pipeline."""
    print_header("Running Complete Pipeline")
    
    stages = [
        ("Lint", cmd_lint),
        ("Test", cmd_test),
        ("Build", cmd_build),
        ("Docker", cmd_docker),
        ("Publish", cmd_publish),
    ]
    
    for stage_name, stage_func in stages:
        print_info(f"Stage: {stage_name}")
        result = stage_func()
        
        if result != 0:
            print_error(f"Pipeline failed at stage: {stage_name}")
            return result
        
        print_success(f"Stage {stage_name} completed successfully")
    
    print_header("Pipeline Completed Successfully! 🎉")
    return 0


def cmd_version() -> int:
    """Show version information."""
    print(f"devopsctl version {VERSION}")
    return 0


def cmd_help() -> int:
    """Show help message."""
    print(__doc__)
    return 0


def main() -> int:
    """Main entry point for the CLI."""
    parser = argparse.ArgumentParser(
        description="DevOps Toolchain CLI",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  devopsctl.py lint      Run code linters
  devopsctl.py test      Run unit tests
  devopsctl.py build     Build the package
  devopsctl.py docker    Build Docker image
  devopsctl.py publish   Publish artifacts
  devopsctl.py all       Run complete pipeline
        """
    )
    
    parser.add_argument(
        "command",
        choices=["lint", "test", "build", "docker", "publish", "all", "version", "help"],
        help="Command to execute"
    )
    
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose output"
    )
    
    args = parser.parse_args()
    
    # Command dispatch
    commands = {
        "lint": cmd_lint,
        "test": cmd_test,
        "build": cmd_build,
        "docker": cmd_docker,
        "publish": cmd_publish,
        "all": cmd_all,
        "version": cmd_version,
        "help": cmd_help,
    }
    
    # Execute the command
    cmd_func = commands.get(args.command)
    if cmd_func:
        return cmd_func()
    else:
        print_error(f"Unknown command: {args.command}")
        return 1


if __name__ == "__main__":
    sys.exit(main())

