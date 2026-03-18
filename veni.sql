// Напояване без реле (MOSFET) + сензор за влажност
// Сензор: капацитивен, аналогов изход към A0
// Помпа: през MOSFET на пин D7

const int SOIL_PIN = A0;
const int PUMP_PIN = 7;

int HUMIDITY_THRESHOLD = 550;    // калибрира се според твоя сензор
unsigned long WATER_TIME = 30000; // 30 сек
unsigned long CHECK_INTERVAL = 6UL * 60UL * 60UL * 1000UL; // на 6 часа

unsigned long lastCheck = 0;

void setup()
{
  pinMode(PUMP_PIN, OUTPUT);
  digitalWrite(PUMP_PIN, LOW);

  Serial.begin(9600);
}

void loop()
{
  unsigned long now = millis();

  if (now - lastCheck >= CHECK_INTERVAL)
  {
    lastCheck = now;

    int soil = analogRead(SOIL_PIN);
    Serial.print("Soil moisture: ");
    Serial.println(soil);

    if (soil >= HUMIDITY_THRESHOLD)
	{
      Serial.println("Soil dry → Watering...");
      digitalWrite(PUMP_PIN, HIGH);
      delay(WATER_TIME);
      digitalWrite(PUMP_PIN, LOW);
      Serial.println("Done.");
    } else
	{
      Serial.println("Soil OK → Skip watering");
    }
  }
  delay(1000);
}
