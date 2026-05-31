const axios = require("axios");
const fs = require("fs");
const path = require("path");
const FormData = require("form-data");

exports.generate3DModel = async (req, res) => {
  try {
    const { imageUrl } = req.body;
    if (!imageUrl) {
      return res.status(400).json({ message: "Image URL is required" });
    }

    const TRIPO_API_KEY = process.env.TRIPO_API_KEY;
    if (!TRIPO_API_KEY) {
      return res.status(500).json({ message: "TRIPO_API_KEY is not configured on the server" });
    }

    // 1. Resolve local file path from the imageUrl
    const filename = imageUrl.split('/').pop();
    const filePath = path.join(__dirname, "../../uploads", filename);

    if (!fs.existsSync(filePath)) {
      return res.status(404).json({ message: "File not found locally: " + filename });
    }

    // 2. Upload file to Tripo directly
    const form = new FormData();
    form.append('file', fs.createReadStream(filePath));

    const uploadRes = await axios.post('https://api.tripo3d.ai/v2/openapi/upload', form, {
      headers: {
        ...form.getHeaders(),
        'Authorization': 'Bearer ' + TRIPO_API_KEY
      }
    });

    if (uploadRes.data.code !== 0) {
      throw new Error("Direct Upload Failed: " + JSON.stringify(uploadRes.data));
    }

    const fileToken = uploadRes.data.data.image_token;

    // 3. Trigger Image-to-3D Task
    const response = await axios.post(
      "https://api.tripo3d.ai/v2/openapi/task",
      {
        type: "image_to_model",
        file: {
          type: "png",
          file_token: fileToken 
        }
      },
      {
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${TRIPO_API_KEY}`
        }
      }
    );

    if (response.data && response.data.code === 0) {
      return res.status(200).json({
        taskId: response.data.data.task_id
      });
    } else {
      return res.status(400).json({
        message: "Tripo API returned an error",
        error: response.data
      });
    }

  } catch (error) {
    console.error("Error generating 3D model:", error.response?.data || error.message);
    
    if (error.response?.data?.code === 2010) {
      return res.status(402).json({
        message: "Tripo API Credits Exhausted",
        error: error.response.data
      });
    }

    return res.status(500).json({
      message: "Failed to communicate with Tripo API",
      error: error.response?.data || error.message
    });
  }
};

exports.getTaskStatus = async (req, res) => {
  try {
    const { taskId } = req.params;
    if (!taskId) {
      return res.status(400).json({ message: "Task ID is required" });
    }

    const TRIPO_API_KEY = process.env.TRIPO_API_KEY;
    if (!TRIPO_API_KEY) {
      return res.status(500).json({ message: "TRIPO_API_KEY is not configured on the server" });
    }

    const response = await axios.get(
      `https://api.tripo3d.ai/v2/openapi/task/${taskId}`,
      {
        headers: {
          "Authorization": `Bearer ${TRIPO_API_KEY}`
        }
      }
    );

    if (response.data && response.data.code === 0) {
      const taskData = response.data.data;
      const status = taskData.status; // queued, running, success, failed
      const progress = taskData.progress;

      let modelUrl = null;
      if (status === "success" && taskData.result && taskData.result.model) {
        modelUrl = taskData.result.model.url;
      }

      return res.status(200).json({
        status,
        progress,
        modelUrl
      });
    } else {
      return res.status(400).json({
        message: "Tripo API returned an error",
        error: response.data
      });
    }

  } catch (error) {
    console.error("Error fetching task status:", error.response?.data || error.message);
    return res.status(500).json({
      message: "Failed to fetch status from Tripo API",
      error: error.response?.data || error.message
    });
  }
};
