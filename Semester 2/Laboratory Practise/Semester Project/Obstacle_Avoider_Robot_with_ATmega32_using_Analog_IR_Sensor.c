#include <avr/io.h>
/*Includes io.h header file where all the Input/Output Registers and its Bits are defined for all AVR microcontrollers*/

#define	F_CPU	1000000
/*Defines a macro for the delay.h header file. F_CPU is the microcontroller frequency value for the delay.h header file. Default value of F_CPU in delay.h header file is 1000000(1MHz)*/

#include <util/delay.h>
/*Includes delay.h header file which defines two functions, _delay_ms (millisecond delay) and _delay_us (microsecond delay)*/

#define 	REF 	615
/*Defines a macro for the Reference value of the sensors*/

/*ADC Function Declarations*/
void adc_init(void);
int read_adc_channel(unsigned char channel);

int main(void)
{
	DDRB=0x0f;
	/*PB0,PB1,PB2 and PB3 pins of PortB are declared output ( i/p1,i/p2,i/p3,i/p4 pins of DC Motor Driver are connected )*/

	int left_sensor_value,front_sensor_value,right_sensor_value;
	/*Variable declarations*/

	adc_init();
	/*ADC initialization*/
	
	/*Start of infinite loop*/
	while(1)
	{
		left_sensor_value=read_adc_channel(0);
		/*Reading left IR sensor value*/
		
		front_sensor_value=read_adc_channel(1);
		/*Reading front IR sensor value*/

		right_sensor_value=read_adc_channel(2);
		/*Reading right IR sensor value*/
		
		/*Checking the sensor values with the reference value*/
		if(front_sensor_value > REF)
		{
			PORTB=0x0a;
			/*Robot will move in forward direction*/
		}
		else if(left_sensor_value < REF)
		{
			PORTB=0x08;
 			/*Robot will move in right direction*/
		}
		else if(right_sensor_value < REF)
		{
			PORTB=0x02;
			/*Robot will move in left direction*/
		}
		else 
		{
			PORTB=0x08;
			/*Robot will move in right direction*/
		}
	}
}
/*End of program*/

/*ADC Function Definitions*/
void adc_init(void)
{
	ADCSRA=(1<<ADEN)|(1<<ADSC)|(1<<ADATE)|(1<<ADPS2);
	SFIOR=0x00;
}

int read_adc_channel(unsigned char channel)
{
	int adc_value;
	unsigned char temp;
	ADMUX=(1<<REFS0)|channel;
	_delay_ms(1);
	temp=ADCL;
	adc_value=ADCH;
	adc_value=(adc_value<<8)|temp;
	return adc_value;
}

