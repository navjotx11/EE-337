#include "at89c5131.h"
// #include <regx51.h> 
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "lcd.c"

sbit mot1 = P0^4; 
sbit mot2 = P0^5; 
sbit mot3 = P0^6; 
sbit mot4 = P0^7; 
sbit LED = P1^4;

char c[40] = {'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0',}; 


// char lower[16] = {'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'};
// char upper[16] = {'0','0','0','0','0','0','0','0','0','0','0','0','0','0','0','0'};

char xAxis[5] = {'0','0','0','0','0'};
char yAxis[5] = {'0','0','0','0','0'};
char zAxis[5] = {'0','0','0','0','0'};

int PWM_Pin = 0;		   // Pin P2.0 is named as PWM_Pin
unsigned char speed_state =0;

// Function declarations
void InitTimer0(void);
void InitPWM(void);

// Global variables
unsigned char PWM = 0;	  // It can have a value from 0 (0% duty cycle) to 255 (100% duty cycle)
unsigned int temp = 0;    // Used inside Timer0 ISR

// PWM frequency selector
/* PWM_Freq_Num can have values in between 1 to 257	only
 * When PWM_Freq_Num is equal to 1, then it means highest PWM frequency
 * which is approximately 1000000/(1*255) = 3.9kHz
 * When PWM_Freq_Num is equal to 257, then it means lowest PWM frequency
 * which is approximately 1000000/(257*255) = 15Hz
 *
 * So, in general you can calculate PWM frequency by using the formula
 *     PWM Frequency = 1000000/(PWM_Freq_Num*255)
 */
#define PWM_Freq_Num   1	 // Highest possible PWM Frequency


// Timer0 initialize
void InitTimer0(void)
{
	TMOD &= 0xF0;    // Clear 4bit field for timer0
	TMOD |= 0x02;    // Set timer0 in mode 1 = 16bit mode
	
	TH0 = 0x00;      // First time value
	TL0 = 0x00;      // Set arbitrarily zero
	
	TH0  = 0xE7;// - (temp>>8)&0xFF;
	TL0  = 0x00;// - temp&0xFF;	

	ET0 = 1;         // Enable Timer0 interrupts
	EA  = 1;         // Global interrupt enable
	
	TR0 = 1;         // Start Timer 0
}


// PWM initialize
void InitPWM(void)
{
	// PWM = 0;         // Initialize with 0% duty cycle
	InitTimer0();    // Initialize timer0 to start generating interrupts
					 // PWM generation code is written inside the Timer0 ISR
}

// Timer0 ISR
void Timer0_ISR (void) interrupt 1   
{
	// TR0 = 0;    // Stop Timer 0

	// if(PWM_Pin)	// if PWM_Pin is high
	// {
	// 	PWM_Pin = 0;
	// 	// temp = (255-PWM)*PWM_Freq_Num;
	// }
	// else	     // if PWM_Pin is low
	// {
	// 	PWM_Pin = 1;
	// 	// temp = PWM*PWM_Freq_Num;
	// 	// TH0  = 0xFF;// - (temp>>8)&0xFF;
	// 	// TL0  = 0xFE;// - temp&0xFF;
	// }
	if(speed_state == 1)
	{
		mot1 = PWM_Pin;
		mot2 = 0;
		mot3 = PWM_Pin;
		mot4 = 0;
	}

	else if(speed_state == 2)
	{
		mot1 = 0;
		mot2 = PWM_Pin;
		mot3 = 0;
		mot4 = PWM_Pin;
	}

	PWM_Pin = ~PWM_Pin;
	// TH0  = 0x;// - (temp>>8)&0xFF;
	// TL0  = 0xFE;// - temp&0xFF;	
	TF0 = 0;     // Clear the interrupt flag
	TR0 = 1;     // Start Timer 0
}

void main()   
{ 	
	mot1 = 0;
	mot2 = 0;
	mot3 = 0;
	mot4 = 0;
	LED = 0;
	InitPWM();              // Start PWM
 	PWM = 127;              // Make 50% duty cycle of PWM

	TMOD |=0x20;                                //Choosing Timer mode    
	TH1=0xF3;                                   //Selecting Baud Rate    
	PCON |= 0x80;
	SCON=0x50;                               //Serial mode selection    
	TR1=1;    
	// IE=0x90;
	RI=1;                                      //Enabling Serial Interrupt
	// printf("Y00000000000000");
	LCD_Init();  
	
	while(1)
	{ 
		short int p=0;	
		short int i=0;
		short int comma[4];
		short int commaCount=0;
		float x_acc,y_acc,z_acc;
		LCD_CmdWrite(0x80);
		while(SBUF != '>' && p < 40)
			{	
				while(RI==0);
				// while();
				// c[p] = SBUF;
				// if(SBUF == ',')
				// 	{
				// 		comma[commaCount] = p;
				// 		commaCount++;
				// 	}
				// LCD_DataWrite(SBUF);
				// if(p == 16)
				// {
				// 	LCD_CmdWrite(0xC0);
				// }
				// p++;
				RI=0;			
			}

		while(RI==0);
		RI=0;			

		while(SBUF != '>' && p < 40)
			{	
				while(RI==0);
				c[p] = SBUF;
				// while();
				if(SBUF == ',')
					{
						comma[commaCount] = p;
						commaCount++;
					}
				// LCD_DataWrite(c[p]);
				// if(p == 16)
				// {
				// 	LCD_CmdWrite(0xC0);
				// }
				p++;
				RI=0;			
			}


		for(i=comma[1]+1;i<comma[1]+6;i++)
		{
			xAxis[i-comma[1]-1]=c[i];
		}		

		for(i=comma[2]+1;i<comma[2]+6;i++)
		{
			yAxis[i-comma[2]-1]=c[i];
		}

		for(i=comma[3]+1;i<comma[3]+6;i++)
		{
			zAxis[i-comma[3]-1]=c[i];
		}

		x_acc = atof(xAxis);
		y_acc = atof(yAxis);
		z_acc = atof(zAxis);

		// Extracting X, Y, Z
		// for (int i = 0; i < 40; i++)
		//  		{
		 			
		//  		} 		

		// for (i = 0; i < 16; i++)
		// {
		// 	lower[i] = c[i];
		// 	upper[i] = c[16+i];
		// 	c[16+i] = '0';
		// 	c[i] = '0'; 
		// }
		// delay_ms(50);
		if(fabs(z_acc) > 9)
		{
			LCD_DataWrite('0');
				speed_state = 0;
				mot1 = 0;
				mot2 = 0;
				mot3 = 0;
				mot4 = 0;
		}
		
		else
		{
			if(-y_acc >  2*fabs(x_acc))
			{
				if(fabs(z_acc) < 7)
				{
					speed_state = 0;
					LCD_DataWrite('1');
					mot1 = 1;
					mot2 = 0;
					mot3 = 1;
					mot4 = 0;	
					LED = 1;
				}
				else
				{
					LCD_DataWrite('f');
					LED = PWM_Pin;
					speed_state = 1;
					// mot1 = PWM_Pin;
					// mot2 = 0;
					// mot3 = PWM_Pin;
					// mot4 = 0;

				}

			}
			else if(-x_acc/2 < -y_acc && -y_acc < 2*(-x_acc))
			{
				speed_state = 0;
				LCD_DataWrite('2');
				mot1 = 1;
				mot2 = 0;
				mot3 = 0;
				mot4 = 0;
			}
			else if(-x_acc > 2*fabs(y_acc))
			{
				speed_state = 0;
				LCD_DataWrite('3');
				mot1 = 1;
				mot2 = 0;
				mot3 = 0;
				mot4 = 1;
			}
			else if(-x_acc/2 < y_acc && y_acc < 2*(-x_acc))
			{
				speed_state = 0;
				LCD_DataWrite('4');
				mot1 = 0;
				mot2 = 1;
				mot3 = 0;
				mot4 = 0;
			}
			else if(y_acc > 2*fabs(x_acc))
			{
				if(fabs(z_acc) < 6.5)
				{
					speed_state = 0;
					LCD_DataWrite('5');
					mot1 = 0;
					mot2 = 1;
					mot3 = 0;
					mot4 = 1;
				}
				else
				{
					LCD_DataWrite('r');
					speed_state = 2;
					// mot1 = 0;
					// mot2 = PWM_Pin;
					// mot3 = 0;
					// mot4 = PWM_Pin;
				}

			}
			else if(x_acc/2 < y_acc && y_acc < 2*(x_acc))
			{
				speed_state = 0;
				LCD_DataWrite('6');
				mot1 = 0;
				mot2 = 0;
				mot3 = 0;
				mot4 = 1;
			}
			else if(x_acc > 2*fabs(y_acc))
			{
				speed_state = 0;
				LCD_DataWrite('7');
				mot1 = 0;
				mot2 = 1;
				mot3 = 1;
				mot4 = 0;
			}
			else/*(x_acc/2 < -y_acc && -y_acc < 2*(x_acc))*/
			{
				speed_state = 0;
				LCD_DataWrite('8');
				mot1 = 0;
				mot2 = 0;
				mot3 = 1;
				mot4 = 0;
			}
			// else
			// {
			// 	LCD_DataWrite('9');	
			// }	
		}


		// if(x_acc > 2*y_acc)
		// {
  //             mot1=1;
  //             mot2=0;
		// }
		
		// else
		// {
  //             mot1=0;
  //             mot2=1;
		// }
		delay_ms(5);
	}
}

// void ser_intr(void)interrupt 4        //Subroutine for Interrupt  
// {
		
// }