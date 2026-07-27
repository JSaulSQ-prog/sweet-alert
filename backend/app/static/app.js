const API_BASE = "http://127.0.0.1:8000";

const state = {
  profile: null,
  assessment: null,
  history: []
};

function $(selector) {
  return document.querySelector(selector);
}

function getBool(id) {
  const element = document.getElementById(id);
  return element ? element.value === "true" : false;
}

function getNumber(id, fallback = 0) {
  const element = document.getElementById(id);
  return element ? Number(element.value || fallback) : fallback;
}

function getString(id, fallback = "") {
  const element = document.getElementById(id);
  return element ? element.value : fallback;
}

function init() {
  bindEvents();
  loadProfile();
  loadHistory();
}

function bindEvents() {
  document.getElementById("save-profile").addEventListener("click", saveProfile);
  document.getElementById("run-checkin").addEventListener("click", runCheckIn);
  document.getElementById("reset-form").addEventListener("click", resetForm);
  document.querySelectorAll(".checkbox-pill").forEach((pill) => {
    pill.addEventListener("click", () => pill.classList.toggle("active"));
  });
}

async function loadProfile() {
  try {
    const response = await fetch(`${API_BASE}/profile`, { headers: { Authorization: "Bearer demo" } });
    if (!response.ok) throw new Error("Sin perfil");
    const profile = await response.json();
    state.profile = profile;
    document.getElementById("profile-summary").innerHTML = `Perfil listo para ${profile.sex === "M" ? "hombre" : "mujer"} · ${profile.height_cm} cm · ${profile.occupation || "sin ocupación"}`;
  } catch (error) {
    document.getElementById("profile-summary").innerHTML = "Completa tu perfil para personalizar el análisis.";
  }
}

async function loadHistory() {
  try {
    const response = await fetch(`${API_BASE}/assessments`, { headers: { Authorization: "Bearer demo" } });
    if (!response.ok) throw new Error("Sin historial");
    const history = await response.json();
    state.history = history;
    renderHistory();
  } catch (error) {
    document.getElementById("history-list").innerHTML = '<div class="history-item">Aún no hay evaluaciones registradas.</div>';
  }
}

async function saveProfile() {
  const payload = {
    sex: document.getElementById("sex").value,
    birth_date: document.getElementById("birth_date").value,
    height_cm: Number(document.getElementById("height_cm").value),
    education_level: Number(document.getElementById("education_level").value),
    income_level: Number(document.getElementById("income_level").value),
    occupation: document.getElementById("occupation").value || null
  };

  try {
    const response = await fetch(`${API_BASE}/profile`, {
      method: "PUT",
      mode: "same-origin",
      headers: { "Content-Type": "application/json", Authorization: "Bearer demo" },
      body: JSON.stringify(payload)
    });
    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Error ${response.status}: ${text || "No se pudo guardar el perfil"}`);
    }
    const profile = await response.json();
    state.profile = profile;
    document.getElementById("profile-summary").innerHTML = `Perfil guardado · ${profile.sex === "M" ? "hombre" : "mujer"} · ${profile.height_cm} cm`;
    alert("Perfil guardado correctamente.");
  } catch (error) {
    console.error("Error guardando perfil:", error);
    alert(error.message || "No se pudo comunicar con el servidor.");
  }
}

async function runCheckIn() {
  const payload = {
    weight_kg: getNumber("weight_kg", 70),
    high_bp: getBool("high_bp"),
    high_chol: getBool("high_chol"),
    chol_check: getBool("chol_check"),
    smoker: getBool("smoker"),
    stroke: getBool("stroke"),
    heart_disease: getBool("heart_disease"),
    phys_activity: getBool("phys_activity"),
    fruits: getBool("fruits"),
    veggies: getBool("veggies"),
    hvy_alcohol: getBool("hvy_alcohol"),
    any_healthcare: getBool("any_healthcare"),
    no_doc_cost: getBool("no_doc_cost"),
    gen_health: getNumber("gen_health", 3),
    ment_health_days: getNumber("ment_health_days", 2),
    phys_health_days: getNumber("phys_health_days", 1),
    diff_walk: getBool("diff_walk"),
    polyuria: getBool("polyuria"),
    polydipsia: getBool("polydipsia"),
    sudden_weight_loss: getBool("sudden_weight_loss"),
    weakness: getBool("weakness"),
    polyphagia: getBool("polyphagia"),
    genital_thrush: getBool("genital_thrush"),
    visual_blurring: getBool("visual_blurring"),
    itching: getBool("itching"),
    irritability: getBool("irritability"),
    delayed_healing: getBool("delayed_healing"),
    partial_paresis: getBool("partial_paresis"),
    muscle_stiffness: getBool("muscle_stiffness"),
    alopecia: getBool("alopecia"),
    obesity: getBool("obesity"),
    sleep_duration_hours: getNumber("sleep_duration_hours", 6.5),
    sleep_quality: getNumber("sleep_quality", 6),
    physical_activity_level: getNumber("physical_activity_level", 40),
    stress_level: getNumber("stress_level", 7),
    daily_steps: getNumber("daily_steps", 6000),
    heart_rate: getNumber("heart_rate", 78),
    daily_calories: getNumber("daily_calories", 2100),
    sugar_g: getNumber("sugar_g", 45),
    carbs_g: getNumber("carbs_g", 250),
    protein_g: getNumber("protein_g", 70),
    fat_g: getNumber("fat_g", 60),
    fiber_g: getNumber("fiber_g", 20),
    water_l: getNumber("water_l", 1.8),
    fruit_servings: getNumber("fruit_servings", 2),
    veggie_servings: getNumber("veggie_servings", 3)
  };

  try {
    const response = await fetch(`${API_BASE}/assessments`, {
      method: "POST",
      mode: "same-origin",
      headers: { "Content-Type": "application/json", Authorization: "Bearer demo" },
      body: JSON.stringify(payload)
    });
    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Error ${response.status}: ${text || "No se pudo enviar la evaluación"}`);
    }
    const assessment = await response.json();
    state.assessment = assessment;
    renderAssessment();
    await loadHistory();
  } catch (error) {
    alert(error.message);
  }
}

function renderAssessment() {
  const assessment = state.assessment;
  if (!assessment) return;

  document.getElementById("results").innerHTML = `
    <div class="result-card">
      <h3>Resultado del check-in</h3>
      <p class="muted">${assessment.llm_recommendation?.resumen || "Resumen disponible."}</p>
      <div class="result-grid">
        <div class="metric">
          <strong class="${riskClass(assessment.risk_level)}">Riesgo de diabetes: ${assessment.risk_level}</strong>
          <span>Probabilidad estimada: ${(assessment.risk_probability * 100).toFixed(1)}%</span>
          <div class="progress"><div style="width:${Math.min(100, assessment.risk_probability * 100)}%; background:${riskColor(assessment.risk_level)}"></div></div>
        </div>
        <div class="metric">
          <strong class="${riskClass(assessment.symptoms_level)}">Síntomas compatibles: ${assessment.symptoms_level}</strong>
          <span>Probabilidad estimada: ${(assessment.symptoms_probability * 100).toFixed(1)}%</span>
          <div class="progress"><div style="width:${Math.min(100, assessment.symptoms_probability * 100)}%; background:${riskColor(assessment.symptoms_level)}"></div></div>
        </div>
        <div class="metric">
          <strong>Nutrición: ${assessment.nutrition_category}</strong>
          <span>Puntaje: ${assessment.nutrition_score}/5</span>
        </div>
        <div class="metric">
          <strong>Estilo de vida: ${assessment.lifestyle_category}</strong>
          <span>Probabilidad de trastorno del sueño: ${(assessment.sleep_disorder_probability * 100).toFixed(1)}%</span>
        </div>
      </div>
    </div>
  `;
}

function renderHistory() {
  const history = state.history || [];
  if (!history.length) {
    document.getElementById("history-list").innerHTML = '<div class="history-item">Aún no hay evaluaciones registradas.</div>';
    return;
  }

  document.getElementById("history-list").innerHTML = history.map((item) => `
    <div class="history-item">
      <strong>${new Date(item.created_at).toLocaleDateString("es-ES")}</strong>
      <div class="muted">Riesgo ${item.risk_level} · Nutrición ${item.nutrition_category}</div>
    </div>
  `).join("");
}

function resetForm() {
  document.querySelectorAll("input, select").forEach((element) => {
    if (element.type === "text" || element.type === "number" || element.type === "date") element.value = "";
    if (element.tagName === "SELECT") element.value = element.options[0]?.value || "";
  });
  document.querySelectorAll(".checkbox-pill").forEach((pill) => pill.classList.remove("active"));
}

function riskClass(level) {
  if (level === "alto") return "level-high";
  if (level === "moderado") return "level-mid";
  return "level-low";
}

function riskColor(level) {
  if (level === "alto") return "#ff6b6b";
  if (level === "moderado") return "#f4b942";
  return "#2fbf71";
}

window.addEventListener("DOMContentLoaded", init);
