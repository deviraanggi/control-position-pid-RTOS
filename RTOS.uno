#include <Arduino_FreeRTOS.h>
#include <semphr.h> 

SemaphoreHandle_t xSerialSemaphore;

//define two task read adc
void Taskadc1 (void *pvParameter);
void Taskadc2 (void *pvParameter);

void setup (){
  
  //inisialisasi serial 9600 bits per second
  Serial.begin(9600);
  while (!Serial) {
    ; //menunggu untuk port serial connect
    }
  if ( xSerialSemaphore == NULL )  
  {
    xSerialSemaphore = xSemaphoreCreateMutex();  
    if ( ( xSerialSemaphore ) != NULL )
      xSemaphoreGive( ( xSerialSemaphore ) );  
  }
  //mengeset 2 task yang berjalan sendiri-sendiri
  xTaskCreate(
    Taskadc1
    , (const portCHAR *)"ReadAdcPotensio"
    , 128 // stack depth in words
    , NULL // we are not using the task parameter
    , 1 // this task will run at priority 1
    , NULL ); // we are not going to use the task handle
    
    xTaskCreate(
    Taskadc2
    , (const portCHAR *)"ReadAdcPotensio"
    , 128
    , NULL
    , 2
    , NULL );

     /* Start the RTOS scheduler, this function should not return as it causes the
   execution context to change from main() to one of the created tasks. */
  vTaskStartScheduler();
  for(;;);
}
  

void loop()
{
 //empty. Sudah dilakukan pada task
 //void ini empty karena tidak akan melakukan tugas apa apa.. 
 //struktur RTOS berbeda dengan arduino biasanya
 
}


void Taskadc1( void *pvParameters) //This is a task
{
    int potensiovalue = A0;
    int led = 8;
    float val;
    float outputan;
    pinMode(potensiovalue, INPUT);
    pinMode(led, OUTPUT);
  for (;;)
  {
    //membca input analog pin A0 potensio
      val = analogRead(potensiovalue);
      outputan= (val*5/1023);
      int brightness = map(val,0,1023,0,255);
      analogWrite(led,brightness);
      if (xSemaphoreTake( xSerialSemaphore, (TickType_t)5) == pdTRUE)
      {
        //Serial.print(val);
        //Serial.println("  volt");
       Serial.print(outputan);
        Serial.print("\t");
        xSemaphoreGive(xSerialSemaphore);
      }
    vTaskDelay(1);

  }
}
void Taskadc2( void *pvParameters __attribute__((unused)) ) //This is a Task
{
  int analogmasukan=A2;
  float hasil;
  for (;;)
  {
      hasil = analogRead(analogmasukan);
      float keluaran = (hasil*5/1023);
      if (xSemaphoreTake( xSerialSemaphore, (TickType_t)5) == pdTRUE)
      {
        Serial.println(keluaran);
        //Serial.println(hasil);
        //Serial.println(" adc2 ");
      xSemaphoreGive(xSerialSemaphore);
      }
   vTaskDelay(1);
  }   
}
