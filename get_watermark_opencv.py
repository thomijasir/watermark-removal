#!/usr/bin/env python3

import sys
from pathlib import Path
import cv2
import numpy as np

def normalize(x):
    return cv2.normalize(x, None, 0, 1, cv2.NORM_MINMAX, dtype=cv2.CV_32F)

def compute_gradients(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    dx = cv2.Sobel(gray, cv2.CV_32F, 1, 0, ksize=3)
    dy = cv2.Sobel(gray, cv2.CV_32F, 0, 1, ksize=3)
    return np.abs(dx), np.abs(dy)

def process_images(root_path):
    image_paths = list(root_path.glob("output_*.png"))
    if not image_paths:
        raise ValueError(f"No images found in {root_path}")

    total_dx = np.zeros_like(cv2.imread(str(image_paths[0]), cv2.IMREAD_GRAYSCALE), dtype=np.float32)
    total_dy = np.zeros_like(total_dx)

    for path in image_paths:
        img = cv2.imread(str(path))
        dx, dy = compute_gradients(img)
        total_dx += dx
        total_dy += dy

    mean_dx = total_dx / len(image_paths)
    mean_dy = total_dy / len(image_paths)
    return mean_dx, mean_dy

def create_mask(mean_dx, mean_dy, threshold=10, sigma=3):
    salient = ((mean_dx > threshold) | (mean_dy > threshold)).astype(np.float32)
    salient = normalize(cv2.GaussianBlur(salient, (0, 0), sigma))
    return (salient > 0.1).astype(np.uint8) * 255

def main(root_path):
    try:
        root = Path(root_path)
        mean_dx, mean_dy = process_images(root)
        mask = create_mask(mean_dx, mean_dy)
        cv2.imwrite(str(root / "mask.png"), mask)
        print(f"Mask saved successfully to {root / 'mask.png'}")
    except Exception as e:
        print(f"An error occurred: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <path_to_image_folder>")
        sys.exit(1)
    main(sys.argv[1])