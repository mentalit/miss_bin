# app/services/camera_ocr_service.rb
require "tempfile"
require "base64"

class CameraOcrService
  class CaptureError < StandardError; end
  class OcrError     < StandardError; end

  def self.scan_and_compare(article, base64_image)
    # Decode base64 image and write to tempfile
    tmp = Tempfile.new(["scan", ".jpg"])

    begin
      tmp.binmode
      tmp.write(Base64.decode64(base64_image))
      tmp.flush

      detected_raw = ocr!(tmp.path)
      detected     = Article.normalise_artno(detected_raw)
      match        = detected.present? && detected == article.artno

      {
        match:      match,
        detected:   detected,
        expected:   article.artno,
        artname:    article.artname,
        slid_h:     article.slid_h,
        loc_price:  article.loc_price,
        confidence: detected.present? ? "ok" : "unreadable"
      }
    ensure
      tmp.close!  # deletes immediately
    end
  end

  private

  def self.ocr!(path)
    cmd    = "tesseract #{path} stdout -l eng --psm 6 2>/dev/null | tr -cd '0-9.'"
    result = `#{cmd}`.strip
    raise OcrError, "Tesseract returned empty output" if result.empty?
    result
  end
end
