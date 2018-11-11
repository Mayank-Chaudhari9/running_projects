int analogPin = 0; // taking input from pulse sensor;

int val = 0; // storing intitial read;
int s_min = 1008; // sensor min val
int s_max = 0; // sensor max_val


void setup()
{
  // put your setup code here, to run once:
  Serial.begin(9600);
  // caliberating the output for first 10sec

  while(millis() <100)
  {
     val= analogRead(analogPin);

    // value caliberation  code for sensor values;
     if(s_max < val)
        s_max=val;
     if(val < s_min)
        s_min =val;
  }

}

void loop()
{
  // put your main code here, to run repeatedly:
  val = analogRead(analogPin);
  val = map(val,s_min,s_max,0,100);
  val = constrain(val,0,100);
  Serial.println(val);
  delay(500);

}
