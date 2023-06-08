using Images, ImageView, Tesseract, ImageFiltering

# Load image and preprocess
img = load("Sudoku_From_Image/sudoku.jpg")
img_gray = Gray.(img)
img_pad = padarray(img_gray, (2,2), reflect)
img_blur = imfilter(img_pad, Kernel.gaussian(5))
img_thresh = imbinarize.(img_blur[3:end-2, 3:end-2] .|> Mean(), Otsu())

# Find contours
contours = Images.find_contours(img_thresh, 0.5)

# Loop through contours
for cnt in contours
    area = Images.area(cnt)
    if area > 5000
        Images.draw(img, cnt, RGB(0,1,0), 3)
        peri = Images.perimeter(cnt, true)
        approx = Images.approximate_polygon(cnt, 0.02 * peri, keepratio=true)
        if length(approx) == 4
            rect = Images.bounding_rectangle(approx)
            if rect.width > 100 && rect.height > 100
                # Crop and recognize digits using Tesseract.jl
                cell = img_gray[rect.y:rect.y+rect.height-1, rect.x:rect.x+rect.width-1]
                cell_pad = padarray(cell, (2,2), reflect)
                cell_thresh = imbinarize(cell_pad, Otsu())
                text = Tesseract.text(cell_thresh, psm=10)
                if isdigits(text)
                    Images.annotate!(img, text, pos=(rect.x, rect.y), color=RGB(1,0,0), fontsize=20)
                end
            end
        end
    end
end

imshow(img)