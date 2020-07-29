#!/usr/bin/env python3.8
"""
Sample standalone python script
"""
import logging

def main():
    """Main entrypoint"""

    return True


if __name__ == "__main__":

    try:
        if main():
            exit(0)
        else:
            exit(1)
    except Exception as ex: # pylint: disable=broad-except
        logging.fatal("Unhandled Exception")
        logging.exception(ex)
        exit(2)
