# 🛡️ AI Face Mask Detector
It is a high-performance mobile application that leverages Deep Learning to detect face masks in real-time. Originally developed as a Python-based computer vision script, it has evolved into a sleek, cloud-integrated mobile solution.

---

## 🚀 The Journey: From Script to App
What started as a local experiment using **OpenCV** and **Python** has been transformed into a professional mobile application. 

- **Phase 1:** Built a real-time detector using **VGG16 (Transfer Learning)** and Haar Cascades.
- **Phase 2:** Deployed the custom-trained VGG16 model to **Hugging Face** for cloud accessibility.
- **Phase 3:** Developed a modern **Flutter** UI with a custom API integration for seamless inference.

## ✨ Key Features
* **Real-Time Detection:** Rapid analysis via hosted Inference API.
* **Modern UI:** High-end dark theme featuring glassmorphism and animated scan effects.
* **Cloud-Native:** Model hosted on Hugging Face, reducing app size while maintaining high accuracy.
* **Cross-Platform:** Built with Flutter for a smooth experience on Android and iOS.

## 🛠️ Tech Stack
* **Frontend:** Flutter & Dart
* **Deep Learning:** TensorFlow / Keras (VGG16 Architecture)
* **Model Hosting:** Hugging Face Inference API
* **Image Processing:** OpenCV (initial training phase)
* **Networking:** HTTP Multipart requests for cloud communication


## ⚙️ How it Works
1. **Capture:** The user takes a photo or selects one from the gallery.
2. **Process:** The image is sent to the **Hugging Face** cloud endpoint.
3. **Inference:** The **VGG16** model analyzes the image for face mask patterns.
4. **Display:** The app receives the prediction and displays a visual "Verified" or "Warning" status using a modern animated UI.


## 🤗 Hugging Face API 
https://ali-hamza-007-face-mask-detector.hf.space/predict


