#define F_CPU   16000000
 
#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>
 


// Timer0, PWM  Initialization
void timer0_init()
{
	// set up timer OC0A,OC0B pin in toggle mode and CTC mode
	TCCR0 |= (1 << COM01)|(1 << WGM00)|(1 << WGM01);
	// set up timer with prescaler = 256
	TCCR0 |= (1 << CS02);
	// initialize counter
	TCNT0 = 0;
	// initialize compare value
	OCR0 = 0;
	
}


// ADC Initialization
void ADC_init()
{
	// Enable ADC, sampling freq=osc_freq/128 set prescaler to max value, 128
	ADCSRA |= (1<<ADEN) | (1<<ADPS2)| (1<<	ADPS1)| (1<<ADPS0);

	ADMUX = (1<<REFS0); // Select Voltage Reference (AVCC)
	
}

// Motor Initialization
void motor_init()
{


	DDRD =0b00110000;  //PD4-ENB (OC1B), PD5-ENA (OC1A)
	PORTD=0b00000000;   // Initially all pins at low output
	
	DDRC = 0xFF;                          //All pins of PORT C as output 
  PORTC = 0x00;                         //Initially all pins at low output
  PORTC|=(1<<PC1)|(1<<PC4);            //PORT C 1 and 4 as high   -----   MOTOR A - PINC4,PINC5
  PORTC&=~((1<<PC2)|(1<<PC5));     //PORT C 2 and 5 as low        -----  MOTOR B - PINC1,PINC2
}




int Digitalized(Ana_reading)
{
	if (Ana_reading>72)
	{
		return 1	
	}
	else
	{
		return 0
	}
}



// Taking analog readings then convert into digital 
int Get_readings()
{

	ADMUX = 0b01100000;   // sensor-1, ADC0
	ADCSRA = 0b10000111;  // Enable the ADC and set the prescaler to max value (128)

    while (1) 
    {
		// Start an ADC conversion by setting ADSC bit (bit 6)
		ADCSRA = ADCSRA | (1 << ADSC);
		
		// Wait until the ADSC bit has been cleared
		while(ADCSRA & (1 << ADSC));
		float value1 = (ADCH*100)/1023;
		sensor1=Digitalized(value1)
	}
	
	
	ADMUX = 0b01100001;   // sensor-2, ADC1
	ADCSRA = 0b10000111;  // Enable the ADC and set the prescaler to max value (128)

    while (1) 
    {
		// Start an ADC conversion by setting ADSC bit (bit 6)
		ADCSRA = ADCSRA | (1 << ADSC);
		
		// Wait until the ADSC bit has been cleared
		while(ADCSRA & (1 << ADSC));
		float value2 = (ADCH*100)/1023;
		sensor2=Digitalized(value2)
	}
	
	ADMUX = 0b0110010;   // sensor-3, ADC2
	ADCSRA = 0b10000111;  // Enable the ADC and set the prescaler to max value (128)

    while (1) 
    {
		// Start an ADC conversion by setting ADSC bit (bit 6)
		ADCSRA = ADCSRA | (1 << ADSC);
		
		// Wait until the ADSC bit has been cleared
		while(ADCSRA & (1 << ADSC));
		float value3 = (ADCH*100)/1023;
		sensor3=Digitalized(value3)
	}
	
	ADMUX = 0b01100011;   // sensor-4, ADC3
	ADCSRA = 0b10000111;  // Enable the ADC and set the prescaler to max value (128)

    while (1) 
    {
		// Start an ADC conversion by setting ADSC bit (bit 6)
		ADCSRA = ADCSRA | (1 << ADSC);
		
		// Wait until the ADSC bit has been cleared
		while(ADCSRA & (1 << ADSC));
		float value4 = (ADCH*100)/1023;
		sensor4=Digitalized(value4)
	}
	ADMUX = 0b01100100;   // sensor-5, ADC4
	ADCSRA = 0b10000111;  // Enable the ADC and set the prescaler to max value (128)

    while (1) 
    {
		// Start an ADC conversion by setting ADSC bit (bit 6)
		ADCSRA = ADCSRA | (1 << ADSC);
		
		// Wait until the ADSC bit has been cleared
		while(ADCSRA & (1 << ADSC));
		float value5 = (ADCH*100)/1023;
		sensor5=Digitalized(value5)
	}
	
	ADMUX = 0b01100101;   // sensor-6, ADC5
	ADCSRA = 0b10000111;  // Enable the ADC and set the prescaler to max value (128)

    while (1) 
    {
		// Start an ADC conversion by setting ADSC bit (bit 6)
		ADCSRA = ADCSRA | (1 << ADSC);
		
		// Wait until the ADSC bit has been cleared
		while(ADCSRA & (1 << ADSC));
		float value6 = (ADCH*100)/1023;
		sensor6=Digitalized(value6)
	}
	
	ADMUX = 0b01100111;   // sensor-7, ADC6
	ADCSRA = 0b10000111;  // Enable the ADC and set the prescaler to max value (128)

    while (1) 
    {
		// Start an ADC conversion by setting ADSC bit (bit 6)
		ADCSRA = ADCSRA | (1 << ADSC);
		
		// Wait until the ADSC bit has been cleared
		while(ADCSRA & (1 << ADSC));
		float value7 = (ADCH*100)/1023;
		sensor7=Digitalized(value7)
	}
	
	
	
}




		

















