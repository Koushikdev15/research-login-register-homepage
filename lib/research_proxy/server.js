const express = require("express");
const fetch = require("node-fetch");
const cors = require("cors");
const https = require("https");

const app = express();
app.use(cors());

const agent = new https.Agent({
  rejectUnauthorized: false, // bypass SSL verification (testing only)
});

app.get("/researchid/:id", async (req, res) => {

  const id = req.params.id;

  try {

    const response = await fetch(`https://researchid.co/${id}`, {
      agent: agent,
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/120 Safari/537.36",
      },
    });

    const html = await response.text();

    res.send(html);

  } catch (error) {

    console.error(error);

    res.status(500).send("Failed to fetch ResearchID page");

  }

});

app.listen(3000, () => {
  console.log("Proxy running at http://localhost:3000");
});