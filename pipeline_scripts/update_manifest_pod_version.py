import json
import argparse

def update_version(file_path, service_name, new_image):
    with open(file_path, 'r') as file:
        manifest = json.load(file)

    manifest['versions'][service_name] = new_image

    with open(file_path, 'w') as file:
        json.dump(manifest, file, indent=2)

    print(f"Pod service {service_name} has been updated to image: {new_image}!")

if __name__ == "__main__":
    manifest_file_path = "/home/ubuntu/cdis-manifest/portal-dev.pedscommons.org/manifest.json"

    parser = argparse.ArgumentParser(description='Update pod image version in manifest.json')
    parser.add_argument('service_name', type=str, help='Name of the service to update')
    parser.add_argument('new_image', type=str, help='New image number')
    parser.add_argument('--file', type=str, default=manifest_file_path, help='Path to the manifest.json file')
    
    args = parser.parse_args()
    
    update_version(args.file, args.service_name, args.new_image)

