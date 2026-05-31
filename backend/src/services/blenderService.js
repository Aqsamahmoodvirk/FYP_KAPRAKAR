const { exec } = require("child_process");
const path = require("path");

const runBlender = (height, width, imagePath) => {
  return new Promise((resolve, reject) => {

    const blendFile = path.join(
      __dirname,
      "../../blender/mannequin_base.blend"
    );

    const scriptFile = path.join(
      __dirname,
      "../../blender/render_script.py"
    );

    const outputImage = path.join(
      __dirname,
      "../../blender/preview_output.png"
    );

    const command = `
      blender -b "${blendFile}"
      -P "${scriptFile}"
      -- ${height} ${width} "${imagePath}"
    `;

    exec(command, (error) => {

      if (error) {
        reject(error);
      } else {
        resolve(outputImage);
      }
    });
  });
};

module.exports = runBlender;