import cv2
import numpy as np
import pytesseract

# Load image and preprocess
img = cv2.imread('sudoku.jpg')
img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
img_blur = cv2.GaussianBlur(img_gray, (5, 5), 1)
img_thresh = cv2.adaptiveThreshold(
    img_blur, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 11, 2)

# Find contours
contours, _ = cv2.findContours(
    img_thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

# Loop through contours
for cnt in contours:
    area = cv2.contourArea(cnt)
    if area > 5000:
        cv2.drawContours(img, cnt, -1, (0, 255, 0), 3)
        peri = cv2.arcLength(cnt, True)
        approx = cv2.approxPolyDP(cnt, 0.02 * peri, True)
        if len(approx) == 4:
            x, y, w, h = cv2.boundingRect(approx)
            if w > 100 and h > 100:
                # Crop and recognize digits using PyTesseract
                cell = img_gray[y:y+h, x:x+w]
                cell_thresh = cv2.adaptiveThreshold(
                    cell, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY_INV, 11, 2)
                text = pytesseract.image_to_string(
                    cell_thresh, config='--psm 10')
                if text.isdigit():
                    cv2.putText(img, text, (x, y),
                                cv2.FONT_HERSHEY_SIMPLEX, 2, (0, 0, 255), 3)

cv2.imshow('Sudoku', img)
cv2.waitKey(0)
cv2.destroyAllWindows()
