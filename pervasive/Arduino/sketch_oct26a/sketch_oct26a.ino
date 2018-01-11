int counter  = 0;
int pin =13;

void setup()
{
  Serial.begin(9600);
  pinMode(pin,OUTPUT);
  digitalWrite(pin,LOW);
 }

void loop()
{
  counter = counter +1;

  digitalWrite(pin,HIGH);
  Serial.print("Blink #");
  Serial.println(counter);
  delay(1000);
  digitalWrite(pin,LOW);
  delay(1000);

}
