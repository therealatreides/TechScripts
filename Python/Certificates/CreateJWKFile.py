"""
CreateJWKFile.py - Convert PEM public key files to JWK format

Description:
    This script converts a PEM-encoded public key file to a JSON Web Key (JWK) format.
    It outputs the JWK as a JSON file and displays the content on the console.
    The JWK is structured with a "keys" array to be compatible with standard JWK providers.

Usage:
    python CreateJWKFile.py <pem_file> [--kid KEY_ID] [--pretty]

Arguments:
    pem_file          Path to the PEM public key file
    --kid KEY_ID      Key ID to include in the JWK (default: servicenow-gcp-vai-key)
    --pretty          Pretty print the JSON output with indentation

Requirements:
    - jwcrypto
    - cryptography

Installation:
    pip install jwcrypto cryptography

Examples:
    # Basic usage
    python CreateJWKFile.py public_key.pem
    
    # With custom key ID
    python CreateJWKFile.py public_key.pem --kid my-custom-key-id
    
    # With pretty printing
    python CreateJWKFile.py public_key.pem --pretty

Output Format:
    {
      "keys": [
        {
          "kty": "RSA",
          "kid": "servicenow-gcp-vai-key",
          "n": "base64url_encoded_modulus...",
          "e": "AQAB"
        }
      ]
    }

Author: Scott Royalty
Version: 1.0.0
Date: August 20, 2025
License: MIT
"""

from jwcrypto import jwk
from cryptography.hazmat.primitives import serialization
import argparse
import sys
import os
import json

def main():
    # Set up command line argument parsing
    parser = argparse.ArgumentParser(description='Convert a PEM public key file to JWK format')
    parser.add_argument('pem_file', help='Path to the PEM public key file')
    parser.add_argument('--kid', default='servicenow-gcp-vai-key', help='Key ID to include in the JWK (default: servicenow-gcp-vai-key)')
    parser.add_argument('--pretty', action='store_true', help='Pretty print the JSON output')
    args = parser.parse_args()

    try:
        # Load the PEM public key from file
        with open(args.pem_file, 'rb') as file:
            pem_public_key = file.read()

        # Parse the PEM key
        public_key = serialization.load_pem_public_key(pem_public_key)

        # Convert to JWK
        jwk_key = jwk.JWK.from_pem(pem_public_key)
        
        # Add key ID if provided
        if args.kid:
            jwk_key.update({'kid': args.kid})
        
        # Get JWK as JSON
        jwk_json_str = jwk_key.export(private_key=False)
        
        # Parse the JSON string to a dictionary
        jwk_dict = json.loads(jwk_json_str)
        
        # Create the proper JWK structure with a keys array
        jwk_structure = {
            "keys": [jwk_dict]
        }
        
        # Convert back to a properly formatted JSON string
        if args.pretty:
            jwk_formatted = json.dumps(jwk_structure, indent=2)
        else:
            jwk_formatted = json.dumps(jwk_structure)

        # Print the JWK to console
        print(jwk_formatted)
        
        # Create output filename with .json extension
        base_filename = os.path.splitext(args.pem_file)[0]
        output_file = f"{base_filename}.json"
        
        # Save the JWK to file
        with open(output_file, 'w') as file:
            file.write(jwk_formatted)
        
        print(f"JWK saved to: {output_file}")
        
    except FileNotFoundError:
        print(f"Error: File not found: {args.pem_file}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Error: {str(e)}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()