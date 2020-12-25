#ifndef F_CPU
#define F_CPU 1600000UL
#endif

#include <avr/io.h>
#include <util/delay.h>
#include "motors.h"
#include <stdlib.h>
#include <avr/interrupt.h>
#define MAXSPEED 150
#define ROTATESPEED 150
#define TURNSPEED 150

static volatile int pulse = 0;
static volatile int i = 0;

void line_follower();

char sensors=0;
char line_break=0;

char location = 3;
char locationIdentifier = 0;

int main(void)
{
	DDRA = 0xE0;
	init_motors();
	
	while(1)
	{
		Ultra_sound();
		if(Ultra_sound() == 1){
			set_motors(0,0);
			break;
		}
		else
		{
		sensors = PINA;
			
		if (sensors == 0b00000000)
		{
			/*if(location == 0)
				{}
			else if ((location == 1) && (locationIdentifier = 1)) // Right turn
				set_motors(TURNSPEED,-ROTATESPEED);
			else if (((location == 2) || (location == 3)) && (locationIdentifier = 1)) // left turn
				set_motors(-ROTATESPEED,TURNSPEED);	
			
			else if ((location == 2) && (locationIdentifier = 2))
				set_motors(TURNSPEED,-ROTATESPEED);
			else if ((location == 3) && (locationIdentifier = 2))
				set_motors(-ROTATESPEED,TURNSPEED);	
			*/
			set_motors(MAXSPEED,MAXSPEED);
		}
		
		else if (sensors == 0b00011111)
		{
			if(location == 0)
				{}
			else if ((location == 1) && (locationIdentifier = 1))
				set_motors(TURNSPEED,-ROTATESPEED);
			else if (((location == 2) || (location == 3)) && (locationIdentifier = 1)) // left turn
				set_motors(-ROTATESPEED,TURNSPEED);
				
			else if ((location == 2) && (locationIdentifier != 1))
				set_motors(TURNSPEED,-ROTATESPEED);
			else if ((location == 3) && (locationIdentifier != 1))
				set_motors(-ROTATESPEED,TURNSPEED);
		}
	
		else
		{
			line_follower();
		}
		}
		}
}

ISR(INT0_vect)
{
	if(i==1)
	{
		TCCR1B = 0;
		pulse = TCNT1;
		TCNT1 = 0;
		i=0;
	}
	if(i==0)
	{
		TCCR1B |= 1<<CS10;
		i=1;
	}
}

int Ultra_sound()
{
	
	DDRD = 0b00000001;   // PIND0 -- TRIGGER ,  PIND2 -- ECHO
	
	GICR |= 1<<INT0;
	MCUCR |= 1<<ISC00;

	sei();
	while(1)
	{
		float distance;
		
		PORTD |= 1<<PIND0;
		_delay_us(20);
		PORTD &= ~(1<<PIND0);
		
		distance = pulse/58;
		if (distance < 5)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}
}

void line_follower()
{
	while(1)
	{
		sensors = PINA;
		
		//GO STRAIGHT
		if (sensors == 0b00011011)
		{
			set_motors(MAXSPEED,MAXSPEED);
		}
		
		else if(sensors == 0b00010001)
		{
			set_motors(MAXSPEED,MAXSPEED);
		}
		
		//RIGHT TURN
		
		else if((sensors == 0b00000001) || (sensors == 0b00000011) || (sensors == 0b00000111) || (sensors == 0b00001111) || (sensors == 0b00000101))
		{
			set_motors(TURNSPEED,-ROTATESPEED);
			_delay_ms(30);
		}
		
		//SLIGHT RIGHT TURN
		else if((sensors == 0b00010011) || (sensors == 0b00010111))
		{
			set_motors(MAXSPEED,(0.5*MAXSPEED));
			_delay_ms(10);
		}
		
		//LEFT TURN
		else if((sensors == 0b00010000) || (sensors == 0b00011000) || (sensors == 0b00011100) || (sensors == 0b00011110) || (sensors == 0b00010100))
		{
			set_motors(-ROTATESPEED,TURNSPEED);
			_delay_ms(30);
		}
		
		//SLIGHT LEFT TURN
		else if((sensors == 0b00011001) || (sensors == 0b00011101))
		{
			set_motors((0.5*MAXSPEED),MAXSPEED);
			_delay_ms(10);
		}
		
		else
		{
			set_motors(ROTATESPEED,-ROTATESPEED);
			//PORTB &= ~(1<<PINB0);
		}
	}
	
}
