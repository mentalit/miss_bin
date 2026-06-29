# app/services/camera_ocr_service.rb
require "tempfile"

class CameraOcrService
  DEVICE      = "/dev/video0"
  RESOLUTION  = "1280x720"

  class CaptureError < StandardError; end
  class OcrError     < StandardError; end

  def self.scan_and_compare(article)
    tmp = Tempfile.new(["scan", ".jpg"])

    begin
      capture!(tmp.path)
      detected_raw = ocr!(tmp.path)
      detected     = Article.normalise_artno(detected_raw)
      match        = detected.present? && detected == article.artno

      {
        match:       match,
        detected:    detected,
        expected:    article.artno,
        artname:     article.artname,
        slid_h:      article.slid_h,
        loc_price:   article.loc_price,
        confidence:  detected.present? ? "ok" : "unreadable"
      }
    ensure
      tmp.close!  # deletes the file immediately
    end
  end

  private

  def self.capture!(path)
    cmd    = "fswebcam -d #{DEVICE} -r #{RESOLUTION} --no-banner --quiet #{path} 2>&1"
    output = `#{cmd}`
    raise CaptureError, "fswebcam failed: #{output}" unless $?.success?
  end

  def self.ocr!(path)
    # -l eng: English, --psm 6: assume a uniform block of text
    # pipe through tr to strip newlines, keep only digits and dots
    cmd    = "tesseract #{path} stdout -l eng --psm 6 2>/dev/null | tr -cd '0-9.'"
    result = `#{cmd}`.strip
    raise OcrError, "Tesseract returned empty output" if result.empty?
    result
  end
end