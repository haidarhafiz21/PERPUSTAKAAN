import face_recognition
import base64
import numpy as np
import cv2
from flask import Flask, request, jsonify
import json
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

FACE_THRESHOLD = 0.55
LIVE_MIN = 0.10
LIVE_MAX = 0.80


@app.route('/', methods=['GET'])
def home():
    return jsonify({
        "status": "Face API Running"
    })


def decode_image(base64_string):
    try:
        if base64_string is None:
            return None

        if "," in base64_string:
            base64_string = base64_string.split(",")[1]

        img_data = base64.b64decode(base64_string)
        np_arr = np.frombuffer(img_data, np.uint8)
        img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        if img is None:
            return None

        # resize supaya cepat
        h, w = img.shape[:2]
        if w > 400:
            scale = 400 / w
            img = cv2.resize(img, (0, 0), fx=scale, fy=scale)

        return img

    except Exception as e:
        print("DECODE ERROR:", e)
        return None


def get_encoding(img):
    try:
        if img is None:
            return None

        rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

        # PAKAI HOG BIAR CEPAT
        face_locations = face_recognition.face_locations(rgb, model="hog")

        if len(face_locations) == 0:
            return None

        encodings = face_recognition.face_encodings(rgb, face_locations)

        if len(encodings) == 0:
            return None

        return encodings[0]

    except Exception as e:
        print("ENCODING ERROR:", e)
        return None


@app.route('/encode-face', methods=['POST'])
def encode_face():
    try:
        data = request.json
        foto = data.get("foto")

        img = decode_image(foto)
        enc = get_encoding(img)

        if enc is None:
            return jsonify({
                "success": False,
                "message": "Wajah tidak terdeteksi"
            })

        return jsonify({
            "success": True,
            "encoding": enc.tolist()
        })

    except Exception as e:
        print("ENCODE ERROR:", e)
        return jsonify({
            "success": False,
            "message": "Encode error"
        })


@app.route('/verify-face', methods=['POST'])
def verify_face():
    try:
        data = request.json

        encoding_db_str = data.get("encoding_db")
        foto_scan = data.get("foto_scan")
        foto_live = data.get("foto_liveness")

        encoding_db = np.array(json.loads(encoding_db_str))

        img_scan = decode_image(foto_scan)
        img_live = decode_image(foto_live)

        enc_scan = get_encoding(img_scan)
        enc_live = get_encoding(img_live)

        if enc_scan is None or enc_live is None:
            return jsonify({
                "match": False,
                "message": "Wajah tidak terdeteksi"
            })

        face_distance = face_recognition.face_distance([encoding_db], enc_scan)[0]
        live_distance = face_recognition.face_distance([enc_scan], enc_live)[0]

        if not (LIVE_MIN < live_distance < LIVE_MAX):
            return jsonify({
                "match": False,
                "message": "Liveness gagal"
            })

        if face_distance > FACE_THRESHOLD:
            return jsonify({
                "match": False,
                "message": "Wajah tidak cocok"
            })

        return jsonify({
            "match": True
        })

    except Exception as e:
        print("VERIFY ERROR:", e)
        return jsonify({
            "match": False,
            "message": "Server error"
        })


if __name__ == '__main__':
    print("FACE API RUNNING ON 0.0.0.0:5000")
    app.run(host="0.0.0.0", port=5000)