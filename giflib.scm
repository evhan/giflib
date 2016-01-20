(module giflib
  (open-gif gif? slurp-gif close-gif
   gif-width gif-height gif-resolution gif-bg-index
   gif-color-map color-map? color-map-resolution
   color-map-count color-map-ref color-map-for-each color-map-for-each-indexed
   color? color-red color-green color-blue
   gif-extension-block-count gif-extension-block-ref gif-extension-block-for-each gif-extension-block-for-each-indexed
   gif-frame-count gif-frame-ref gif-frame-for-each gif-frame-for-each-indexed
   frame? frame-width frame-height frame-left frame-top frame-interlaced? frame-color-map frame-pixel
   frame-extension-block-count frame-extension-block-ref frame-extension-block-for-each frame-extension-block-for-each-indexed
   sub-block? sub-block-id sub-block-data
   comment-block? comment-block-text
   graphics-control-block? graphics-control-block-disposal graphics-control-block-user-input? graphics-control-block-delay graphics-control-block-transparency-index
   text-block? text-block-grid-left text-block-grid-top text-block-grid-width text-block-grid-height text-block-cell-width text-block-cell-height text-block-fg-index text-block-bg-index
   application-block? application-block-identifier application-block-auth-code)

(import chicken scheme foreign)
(use srfi-4 bitstring)

(foreign-declare "#include <gif_lib.h>")

;;; foreign constants

(define GIF_ERROR (foreign-value "GIF_ERROR" byte))
(define GIF_OK (foreign-value "GIF_OK" byte))

(define CONTINUE_EXT_FUNC_CODE (foreign-value "CONTINUE_EXT_FUNC_CODE" unsigned-byte))
(define COMMENT_EXT_FUNC_CODE (foreign-value "COMMENT_EXT_FUNC_CODE" unsigned-byte))
(define GRAPHICS_EXT_FUNC_CODE (foreign-value "GRAPHICS_EXT_FUNC_CODE" unsigned-byte))
(define PLAINTEXT_EXT_FUNC_CODE (foreign-value "PLAINTEXT_EXT_FUNC_CODE" unsigned-byte))
(define APPLICATION_EXT_FUNC_CODE (foreign-value "APPLICATION_EXT_FUNC_CODE" unsigned-byte))

(define DISPOSAL_UNSPECIFIED (foreign-value "DISPOSAL_UNSPECIFIED" unsigned-byte))
(define DISPOSE_DO_NOT (foreign-value "DISPOSE_DO_NOT" unsigned-byte))
(define DISPOSE_BACKGROUND (foreign-value "DISPOSE_BACKGROUND" unsigned-byte))
(define DISPOSE_PREVIOUS (foreign-value "DISPOSE_PREVIOUS" unsigned-byte))

;;; foreign functions

(define DGifOpenFileName (foreign-lambda (c-pointer (struct "GifFileType")) "DGifOpenFileName" c-string (c-pointer int)))
(define DGifSlurp (foreign-lambda int "DGifSlurp" (c-pointer (struct "GifFileType"))))
(define DGifCloseFile (foreign-lambda int "DGifCloseFile" (c-pointer (struct "GifFileType")) (c-pointer int)))

;;; foreign accessors

(define GifFileType->SWidth (foreign-lambda* int (((c-pointer (struct "GifFileType")) gif)) "C_return(gif->SWidth);"))
(define GifFileType->SHeight (foreign-lambda* int (((c-pointer (struct "GifFileType")) gif)) "C_return(gif->SHeight);"))
(define GifFileType->SColorResolution (foreign-lambda* int (((c-pointer (struct "GifFileType")) gif)) "C_return(gif->SColorResolution);"))
(define GifFileType->SBackGroundColor (foreign-lambda* int (((c-pointer (struct "GifFileType")) gif)) "C_return(gif->SBackGroundColor);"))
(define GifFileType->SColorMap (foreign-lambda* (c-pointer (struct "ColorMapObject")) (((c-pointer (struct "GifFileType")) gif)) "C_return(gif->SColorMap);"))
(define GifFileType->ImageCount (foreign-lambda* int (((c-pointer (struct "GifFileType")) gif)) "C_return(gif->ImageCount);"))
(define GifFileType->SavedImage (foreign-lambda* (c-pointer (struct "SavedImage")) (((c-pointer (struct "GifFileType")) gif) (int i)) "C_return(&(gif->SavedImages[i]));"))
(define GifFileType->ExtensionBlockCount (foreign-lambda* int (((c-pointer (struct "GifFileType")) gif)) "C_return(gif->ExtensionBlockCount);"))
(define GifFileType->ExtensionBlock (foreign-lambda* (c-pointer (struct "ExtensionBlock")) (((c-pointer (struct "GifFileType")) gif) (int i)) "C_return(&(gif->ExtensionBlocks[i]));"))
(define GifFileType->Error (foreign-lambda* int (((c-pointer (struct "GifFileType")) gif)) "C_return(gif->Error);"))

(define ColorMapObject->ColorCount (foreign-lambda* int (((c-pointer (struct "ColorMapObject")) color_map)) "C_return(color_map->ColorCount);"))
(define ColorMapObject->BitsPerPixel (foreign-lambda* int (((c-pointer (struct "ColorMapObject")) color_map)) "C_return(color_map->BitsPerPixel);"))
(define ColorMapObject->Color (foreign-lambda* (c-pointer (struct "GifColorType")) (((c-pointer (struct "ColorMapObject")) color_map) (int i)) "C_return(&(color_map->Colors[i]));"))

(define GifColorType->Red (foreign-lambda* unsigned-byte (((c-pointer (struct "GifColorType")) color)) "C_return(color->Red);"))
(define GifColorType->Green (foreign-lambda* unsigned-byte (((c-pointer (struct "GifColorType")) color)) "C_return(color->Green);"))
(define GifColorType->Blue (foreign-lambda* unsigned-byte (((c-pointer (struct "GifColorType")) color)) "C_return(color->Blue);"))

(define ExtensionBlock->Function (foreign-lambda* int (((c-pointer (struct "ExtensionBlock")) extension_block)) "C_return(extension_block->Function);"))
(define ExtensionBlock->ByteCount (foreign-lambda* int (((c-pointer (struct "ExtensionBlock")) extension_block)) "C_return(extension_block->ByteCount);"))
(define ExtensionBlock->Bytes (foreign-lambda* (c-pointer unsigned-byte) (((c-pointer (struct "ExtensionBlock")) extension_block)) "C_return(extension_block->Bytes);"))
(define ExtensionBlock->u8vector (foreign-lambda* void ((u8vector dest) ((c-pointer unsigned-byte) src) (int size)) "memcpy(dest, src, size * sizeof(unsigned char));"))

(define SavedImage->Width (foreign-lambda* int (((c-pointer (struct "SavedImage")) frame)) "C_return(frame->ImageDesc.Width);"))
(define SavedImage->Height (foreign-lambda* int (((c-pointer (struct "SavedImage")) frame)) "C_return(frame->ImageDesc.Height);"))
(define SavedImage->Left (foreign-lambda* int (((c-pointer (struct "SavedImage")) frame)) "C_return(frame->ImageDesc.Left);"))
(define SavedImage->Top (foreign-lambda* int (((c-pointer (struct "SavedImage")) frame)) "C_return(frame->ImageDesc.Top);"))
(define SavedImage->Interlace (foreign-lambda* bool (((c-pointer (struct "SavedImage")) frame)) "C_return(frame->ImageDesc.Interlace);"))
(define SavedImage->ColorMap (foreign-lambda* (c-pointer (struct "ColorMapObject")) (((c-pointer (struct "SavedImage")) frame)) "C_return(frame->ImageDesc.ColorMap);"))
(define SavedImage->ExtensionBlockCount (foreign-lambda* int (((c-pointer (struct "SavedImage")) frame)) "C_return(frame->ExtensionBlockCount);"))
(define SavedImage->ExtensionBlock (foreign-lambda* (c-pointer (struct "ExtensionBlock")) (((c-pointer (struct "SavedImage")) frame) (int i)) "C_return(&(frame->ExtensionBlocks[i]));"))
(define SavedImage->pixel (foreign-lambda* unsigned-byte (((c-pointer (struct "SavedImage")) frame) (int width) (int x) (int y)) "C_return(frame->RasterBits[y*width+x]);"))

;;; auxiliary records

(define-record gif pointer)
(define-record frame pointer)
(define-record color-map pointer)
(define-record color pointer)
;; (define-record extension-block pointer type data-length data-pointer)
(define-record sub-block id data)
(define-record comment-block text)
(define-record graphics-control-block disposal user-input? delay transparency-index)
;; see also http://www.vurdalakov.net/misc/gif
(define-record application-block identifier auth-code)
(define-record text-block grid-left grid-top grid-width grid-height cell-width cell-height fg-index bg-index)

;;; errors

(define (giflib-error status location)
  (abort
   (make-composite-condition
    (make-property-condition
     'exn
     'location location
     'message ((foreign-lambda c-string "GifErrorString" byte)
               status))
    (make-property-condition
     'giflib
     'code status))))

(define (oob-error index count location)
  (abort
   (make-composite-condition
    (make-property-condition
     'exn
     'location location
     'message (format "Out of bounds: ~a / ~a" index count))
    (make-property-condition
     'bounds))))

(define (unknown-extension-block-error location)
  (abort
   (make-composite-condition
    (make-property-condition
     'exn
     'location location
     'message "Unknown extension block")
    (make-property-condition
     'match))))

(define (unknown-disposal-error location)
  (abort
   (make-composite-condition
    (make-property-condition
     'exn
     'location location
     'message "Unknown disposal")
    (make-property-condition
     'match))))

(define (unpack-error location)
  (abort
   (make-composite-condition
    (make-property-condition
     'exn
     'location location
     'message "Unpacking error")
    (make-property-condition
     'match))))

;;; extension block data unpacking

(define (data->sub-block data)
  (bitmatch data
    (((id 8 little)
      (data bitstring))
     (make-sub-block id (bitstring->u8vector data 8)))
    (else (unpack-error 'extension-block->sub-block))))

(define (data->comment-block data)
  (make-comment-block (blob->string (u8vector->blob data))))

(define (data->graphics-control-block data)
  (bitmatch data
    (((reserved 3 little)
      (disposal 3 little)
      (user-input? 1 boolean little)
      (transparency-index? 1 boolean little)
      (delay-time (* 2 8) little) ; hundredths of seconds
      (transparency-index 8 little)) ; index
     (make-graphics-control-block
      (select disposal
        ((DISPOSAL_UNSPECIFIED) 'unspecified)
        ((DISPOSE_DO_NOT) 'none)
        ((DISPOSE_BACKGROUND) 'background)
        ((DISPOSE_PREVIOUS) 'previous)
        (else (unknown-disposal-error 'extension-block->graphics-control-block)))
      user-input? delay-time (and transparency-index? transparency-index)))
    (else (unpack-error 'extension-block->graphics-control-block))))

(define (data->text-block data)
  (bitmatch data
    (((grid-left (* 2 8) little)
      (grid-top (* 2 8) little)
      (grid-width (* 2 8) little)
      (grid-height (* 2 8) little)
      (cell-width 8 little)
      (cell-height 8 little)
      (fg-index 8 little)
      (bg-index 8 little))
     (make-text-block grid-left grid-top grid-width grid-height
                      cell-width cell-height fg-index bg-index))
    (else (unpack-error 'extension-block->text-block))))

(define (data->application-block data)
  (bitmatch data
    (((identifier (* 8 8) bitstring)
      (auth-code (* 3 8) bitstring))
     (make-application-block (bitstring->string identifier)
                             (bitstring->string auth-code)))
    (else (unpack-error 'extension-block->application-block))))

;;; setting up and tearing down gifs

;; TODO: check whether and-let* is necessary for anything not gif*
(define (open-gif filename)
  (let-location ((status int 0))
    (let ((gif* (DGifOpenFileName filename (location status))))
      (if gif*
          (set-finalizer! (make-gif gif*) close-gif)
          (giflib-error status 'open-gif)))))

(define (slurp-gif gif)
  (and-let* ((gif* (gif-pointer gif)))
    (when (= (DGifSlurp gif*) GIF_ERROR)
      (giflib-error (GifFileType->Error gif*) 'slurp-gif))))

(define (close-gif gif)
  (and-let* ((gif* (gif-pointer gif)))
    (let-location ((status int 0))
      (when (= (DGifCloseFile gif* (location status)) GIF_ERROR)
        (giflib-error status 'close-gif)))
    (gif-pointer-set! gif #f)))

;;; gifs

(define (gif-width gif)
  (and-let* ((gif* (gif-pointer gif)))
    (GifFileType->SWidth gif*)))

(define (gif-height gif)
  (and-let* ((gif* (gif-pointer gif)))
    (GifFileType->SHeight gif*)))

(define (gif-resolution gif)
  (and-let* ((gif* (gif-pointer gif)))
    (GifFileType->SColorResolution gif*)))

(define (gif-bg-index gif)
  (and-let* ((gif* (gif-pointer gif)))
    (GifFileType->SBackGroundColor gif*)))

(define (gif-color-map gif)
  (and-let* ((gif* (gif-pointer gif)))
    (let ((color-map* (GifFileType->SColorMap gif*)))
      (if color-map*
          (make-color-map color-map*)
          #f))))

(define (gif-extension-block-count gif)
  (and-let* ((gif* (gif-pointer gif)))
    (GifFileType->ExtensionBlockCount gif*)))

(define (gif-extension-block-ref gif index)
  (and-let* ((gif* (gif-pointer gif)))
    (let ((count (GifFileType->ExtensionBlockCount gif*)))
      (if (and (>= index 0) (< index count))
          (let* ((extension-block* (GifFileType->ExtensionBlock gif* index))
                 (function (ExtensionBlock->Function extension-block*))
                 (data-length (ExtensionBlock->ByteCount extension-block*))
                 (data-pointer (ExtensionBlock->Bytes extension-block*))
                 (data (make-u8vector data-length 0)))
            (ExtensionBlock->u8vector data data-pointer data-length)
            (select function
              ((CONTINUE_EXT_FUNC_CODE) (data->sub-block data))
              ((COMMENT_EXT_FUNC_CODE) (data->comment-block data))
              ((GRAPHICS_EXT_FUNC_CODE) (data->graphics-control-block data))
              ((PLAINTEXT_EXT_FUNC_CODE) (data->text-block data))
              ((APPLICATION_EXT_FUNC_CODE) (data->application-block data))))
          (oob-error index count 'gif-extension-block-ref)))))

(define (gif-extension-block-for-each proc gif)
  (and-let* ((gif* (gif-pointer gif)))
    (let ((count (GifFileType->ExtensionBlockCount gif*)))
      (let loop ((i 0))
        (when (< i count)
          (let* ((extension-block* (GifFileType->ExtensionBlock gif* i))
                 (function (ExtensionBlock->Function extension-block*))
                 (data-length (ExtensionBlock->ByteCount extension-block*))
                 (data-pointer (ExtensionBlock->Bytes extension-block*))
                 (data (make-u8vector data-length 0)))
            (ExtensionBlock->u8vector data data-pointer data-length)
            (proc
             (select function
               ((CONTINUE_EXT_FUNC_CODE) (data->sub-block data))
               ((COMMENT_EXT_FUNC_CODE) (data->comment-block data))
               ((GRAPHICS_EXT_FUNC_CODE) (data->graphics-control-block data))
               ((PLAINTEXT_EXT_FUNC_CODE) (data->text-block data))
               ((APPLICATION_EXT_FUNC_CODE) (data->application-block data)))))
          (loop (add1 i)))))))

(define (gif-extension-block-for-each-indexed proc gif)
  (and-let* ((gif* (gif-pointer gif)))
    (let ((count (GifFileType->ExtensionBlockCount gif*)))
      (let loop ((i 0))
        (when (< i count)
          (let* ((extension-block* (GifFileType->ExtensionBlock gif* i))
                 (function (ExtensionBlock->Function extension-block*))
                 (data-length (ExtensionBlock->ByteCount extension-block*))
                 (data-pointer (ExtensionBlock->Bytes extension-block*))
                 (data (make-u8vector data-length 0)))
            (ExtensionBlock->u8vector data data-pointer data-length)
            (proc
             (select function
               ((CONTINUE_EXT_FUNC_CODE) (data->sub-block data))
               ((COMMENT_EXT_FUNC_CODE) (data->comment-block data))
               ((GRAPHICS_EXT_FUNC_CODE) (data->graphics-control-block data))
               ((PLAINTEXT_EXT_FUNC_CODE) (data->text-block data))
               ((APPLICATION_EXT_FUNC_CODE) (data->application-block data)))
             i))
          (loop (add1 i)))))))

(define (gif-frame-count gif)
  (and-let* ((gif* (gif-pointer gif)))
    (GifFileType->ImageCount gif*)))

(define (gif-frame-ref gif index)
  (and-let* ((gif* (gif-pointer gif)))
    (let ((count (GifFileType->ImageCount gif*)))
      (if (and (>= index 0) (< index count))
          (make-frame (GifFileType->SavedImage gif* index)))
      (oob-error index count 'gif-frame-ref))))

(define (gif-frame-for-each proc gif)
  (and-let* ((gif* (gif-pointer gif)))
    (let ((count (GifFileType->ImageCount gif*)))
      (let loop ((i 0))
        (when (< i count)
          (proc (make-frame (GifFileType->SavedImage gif* i)))
          (loop (add1 i)))))))

(define (gif-frame-for-each-indexed proc gif)
  (and-let* ((gif* (gif-pointer gif)))
    (let ((count (GifFileType->ImageCount gif*)))
      (let loop ((i 0))
        (when (< i count)
          (proc (make-frame (GifFileType->SavedImage gif* i)) i)
          (loop (add1 i)))))))

;;; color maps

(define (color-map-count color-map)
  (and-let* ((color-map* (color-map-pointer color-map)))
    (ColorMapObject->ColorCount color-map*)))

(define (color-map-resolution color-map)
  (and-let* ((color-map* (color-map-pointer color-map)))
    (ColorMapObject->BitsPerPixel color-map*)))

(define (color-map-ref color-map index)
  (and-let* ((color-map* (color-map-pointer color-map)))
    (let ((count (ColorMapObject->ColorCount color-map*)))
      (if (and (>= index 0) (< index count))
          (make-color (ColorMapObject->Color color-map* index))
          (oob-error index count 'color-map-ref)))))

(define (color-map-for-each proc color-map)
  (and-let* ((color-map* (color-map-pointer color-map)))
    (let ((count (ColorMapObject->ColorCount color-map*)))
      (let loop ((i 0))
        (when (< i count)
          (proc (make-color (ColorMapObject->Color color-map* i)))
          (loop (add1 i)))))))

(define (color-map-for-each-indexed proc color-map)
  (and-let* ((color-map* (color-map-pointer color-map)))
    (let ((count (ColorMapObject->ColorCount color-map*)))
      (let loop ((i 0))
        (when (< i count)
          (proc (make-color (ColorMapObject->Color color-map* i)) i)
          (loop (add1 i)))))))

;;; colors

(define (color-red color)
  (GifColorType->Red (color-pointer color)))

(define (color-green color)
  (GifColorType->Green (color-pointer color)))

(define (color-blue color)
  (GifColorType->Blue (color-pointer color)))

;;; frames

(define (frame-width frame)
  (and-let* ((frame* (frame-pointer frame)))
    (SavedImage->Width frame*)))

(define (frame-height frame)
  (and-let* ((frame* (frame-pointer frame)))
    (SavedImage->Height frame*)))

(define (frame-left frame)
  (and-let* ((frame* (frame-pointer frame)))
    (SavedImage->Left frame*)))

(define (frame-top frame)
  (and-let* ((frame* (frame-pointer frame)))
    (SavedImage->Top frame*)))

(define (frame-interlaced? frame)
  (and-let* ((frame* (frame-pointer frame)))
    (SavedImage->Interlace frame*)))

(define (frame-color-map frame)
  (and-let* ((frame* (frame-pointer frame)))
    (let ((color-map* (SavedImage->ColorMap frame*)))
      (if color-map*
          (make-color-map color-map*)
          #f))))

;; TODO: implement gif-frame-fold with more intuitive semantics
;; NOTE: https://github.com/muennich/sxiv/blob/master/image.c#L147-L155
(define (frame-pixel frame x y)
  (and-let* ((frame* (frame-pointer frame)))
    (let ((width (SavedImage->Width frame*))
          (height (SavedImage->Height frame*)))
      (if (and (>= x 0) (>= y 0)
               (< x width) (< y height))
          (SavedImage->pixel frame* width x y)
          (oob-error (format "~a|~a" x y) (format "~ax~a" width height) 'frame-pixel)))))

;; (define (frame-pixel-row frame row) ...)
;; (define (frame-pixel-rect frame x y width height) ...)
;; (define (frame-pixels frame) ...)

(define (frame-extension-block-count frame)
  (and-let* ((frame* (frame-pointer frame)))
    (SavedImage->ExtensionBlockCount frame*)))

(define (frame-extension-block-ref frame index)
  (and-let* ((frame* (frame-pointer frame)))
    (let ((count (SavedImage->ExtensionBlockCount frame*)))
      (if (and (>= index 0) (< index count))
          (let* ((extension-block* (SavedImage->ExtensionBlock frame* index))
                 (function (ExtensionBlock->Function extension-block*))
                 (data-length (ExtensionBlock->ByteCount extension-block*))
                 (data-pointer (ExtensionBlock->Bytes extension-block*))
                 (data (make-u8vector data-length 0)))
            (ExtensionBlock->u8vector data data-pointer data-length)
            (select function
              ((CONTINUE_EXT_FUNC_CODE) (data->sub-block data))
              ((COMMENT_EXT_FUNC_CODE) (data->comment-block data))
              ((GRAPHICS_EXT_FUNC_CODE) (data->graphics-control-block data))
              ((PLAINTEXT_EXT_FUNC_CODE) (data->text-block data))
              ((APPLICATION_EXT_FUNC_CODE) (data->application-block data))))
          (oob-error index count 'frame-extension-block-ref)))))

(define (frame-extension-block-for-each proc frame)
  (and-let* ((frame* (frame-pointer frame)))
    (let ((count (SavedImage->ExtensionBlockCount frame*)))
      (let loop ((i 0))
        (when (< i count)
          (let* ((extension-block* (SavedImage->ExtensionBlock frame* i))
                 (function (ExtensionBlock->Function extension-block*))
                 (data-length (ExtensionBlock->ByteCount extension-block*))
                 (data-pointer (ExtensionBlock->Bytes extension-block*))
                 (data (make-u8vector data-length 0)))
            (ExtensionBlock->u8vector data data-pointer data-length)
            (proc
             (select function
               ((CONTINUE_EXT_FUNC_CODE) (data->sub-block data))
               ((COMMENT_EXT_FUNC_CODE) (data->comment-block data))
               ((GRAPHICS_EXT_FUNC_CODE) (data->graphics-control-block data))
               ((PLAINTEXT_EXT_FUNC_CODE) (data->text-block data))
               ((APPLICATION_EXT_FUNC_CODE) (data->application-block data)))))
          (loop (add1 i)))))))

(define (frame-extension-block-for-each-indexed proc frame)
  (and-let* ((frame* (frame-pointer frame)))
    (let ((count (SavedImage->ExtensionBlockCount frame*)))
      (let loop ((i 0))
        (when (< i count)
          (let* ((extension-block* (SavedImage->ExtensionBlock frame* i))
                 (function (ExtensionBlock->Function extension-block*))
                 (data-length (ExtensionBlock->ByteCount extension-block*))
                 (data-pointer (ExtensionBlock->Bytes extension-block*))
                 (data (make-u8vector data-length 0)))
            (ExtensionBlock->u8vector data data-pointer data-length)
            (proc
             (select function
               ((CONTINUE_EXT_FUNC_CODE) (data->sub-block data))
               ((COMMENT_EXT_FUNC_CODE) (data->comment-block data))
               ((GRAPHICS_EXT_FUNC_CODE) (data->graphics-control-block data))
               ((PLAINTEXT_EXT_FUNC_CODE) (data->text-block data))
               ((APPLICATION_EXT_FUNC_CODE) (data->application-block data)))
             i))
          (loop (add1 i)))))))

)
