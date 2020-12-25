#ifndef MOTORS_H_
#define MOTORS_H_


#include <avr/io.h>

#define leftMotorPWMPin		OCR0 //pinb3
#define rightMotorPWMPin	OCR2 //pind7

void init_motors(void);
void set_motors(int leftMotorSpeed, int rightMotorSpeed);


/*	Initializes the OCR0 and OCR2 pins for phase correct PWM.
 *	with non-inverting mode. OCR0/OCR2 is cleared on compare match 
 *	when up-counting and is set on compare match when down-counting.
 */
void init_motors()
{
	//Configure PWM pins OCR0 and OCR2 to output mode
    DDRD |= (1<<PIND7);
	DDRB |= (1<<PINB3);
	
	//Configure motor direction control pins to output mode
	DDRC |= (1<<PINC0) | (1<<PINC1) | (1<<PINC6) | (1<<PINC7);
	
	//set phase correct PWM, NON inverting mode and set a pre scalar of 64
	TCCR0 |= (1<<WGM00) | (1<<COM01) | (1<<CS00) | (1<<CS01);
	TCCR2 |= (1<<COM21) | (1<<WGM20) | (1<<CS22) ;	
	
	//Sets TOP value to be 250
	TCNT0 = 250;
	TCNT2 = 250;
}


/*	Sets the speed and direction of the two motors. The value of each
 *	of the arguments can range from -250 to +250. A negative sign
 *	is used when the direction of the motor is to be reversed.
 */
void set_motors(int leftMotorSpeed, int rightMotorSpeed)
{
    if(leftMotorSpeed >= 0)
    {
        leftMotorPWMPin = leftMotorSpeed;
		PORTC |= (1<<PINC0);
		PORTC &= ~(1<<PINC1); //SET THE MOTOR TO ROTATE IN THE FORWARD DIRECTION.
    }
    else
    {
        leftMotorPWMPin = -leftMotorSpeed;
       	PORTC |= (1<<PINC1);
       	PORTC &= ~(1<<PINC0);	//SET THE MOTOR TO ROTATE IN THE OPPOSITE DIRECTION.
    }

	if(rightMotorSpeed >= 0)
    {
        rightMotorPWMPin = rightMotorSpeed;
       	PORTC |= (1<<PINC6);
       	PORTC &= ~(1<<PINC7); //SET THE MOTOR TO ROTATE IN THE FORWARD DIRECTION.
    }
    else
    {
        rightMotorPWMPin = -rightMotorSpeed;
        PORTC |= (1<<PINC7);
        PORTC &= ~(1<<PINC6); //SET THE MOTOR TO ROTATE IN THE OPPOSITE DIRECTION.
    }
}


#endif