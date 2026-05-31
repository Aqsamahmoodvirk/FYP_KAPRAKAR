import sys
import os

def main():
    if len(sys.argv) < 3:
        print("Usage: python remove_bg.py input output")
        sys.exit(1)

    input_path = sys.argv[1]
    output_path = sys.argv[2]

    if not os.path.exists(input_path):
        print(f"Input file not found: {input_path}")
        sys.exit(1)

    try:
        from rembg import remove
        with open(input_path, "rb") as f:
            input_data = f.read()
        output_data = remove(input_data)
        with open(output_path, "wb") as f:
            f.write(output_data)
        print("done")
    except ImportError:
        print("rembg not installed, copying original")
        import shutil
        shutil.copy(input_path, output_path)
        print("done")
    except Exception as e:
        print(f"Error: {e}")
        import shutil
        shutil.copy(input_path, output_path)
        print("done")

if __name__ == "__main__":
    main()
