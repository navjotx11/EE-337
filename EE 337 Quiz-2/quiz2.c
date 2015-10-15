#include "at89c5131.h"
#include "stdio.h"

void SPI_Init();
void Timer_Init();
void modereq();
sbit CS_BAR = P2^0;									// Chip Select for the ADC
bit transmit_completed= 0;					// To check if spi data transmit is complete
sbit w0 = P1^0; 
sbit w1 = P1^1;
sbit f0 = P1^2;
sbit f1 = P1^3;
bit p=0,q=0,r=0,s=0;           //temp bits to take switch values
bit inv=0;                    //needed for square wave generation
bit rep=0;
int tm=0;                     //Selecting the frequency in timer interrupt
int count=0;
unsigned char serial_data;
unsigned char a=0x00;
unsigned char b=0x00;
 
void main(void)
{
	P3 = 0X00;											// Make Port 3 output 
	P2 = 0x00;											// Make Port 2 output 
	P1 |= 0x0F;											// Make P1 Pin 0-3 as input
	P0 &= 0xF0;											// Make Port 0 Pins 0,1,2 output
	
	SPI_Init();
	Timer_Init();
	modereq();
	
	while(1)												// endless 
	{ 
	
		
		if(inv==1 && (p==0&&q==0))            //for implementing square wave
		{
		 CS_BAR=0;
		
		 SPDAT=0x70;
		 while(!transmit_completed);	// wait end of transmition;TILL SPIF = 1 
		 transmit_completed = 0;    	// clear software transfert flag
    
		 SPDAT=0x00;
     while(!transmit_completed);	// wait end of transmition;TILL SPIF = 1 
		 transmit_completed = 0;    	// clear software transfert flag		
		
		 CS_BAR=1;
		}
		if(inv==0 && (p==0&&q==0))      
		{
		 CS_BAR=0;
		
		 SPDAT=a;
		 while(!transmit_completed);	// wait end of transmition;TILL SPIF = 1 
		 transmit_completed = 0;    	// clear software transfert flag
    
		 SPDAT=b;
     while(!transmit_completed);	// wait end of transmition;TILL SPIF = 1 
		 transmit_completed = 0;    	// clear software transfert flag		
		
		 CS_BAR=1;
		}
		
		if(p==0&&q==1)                    //For implementing Sawtooth
		{
				
			if (rep==1)                  //To repeat pattern
		  {b=0xFF;
			a=0x7F;
		  rep =0;
		  count =0;}
			
		 CS_BAR=0;
		
		 SPDAT=a;
		 while(!transmit_completed);	// wait end of transmition;TILL SPIF = 1 
		 transmit_completed = 0;    	// clear software transfert flag
    
		 SPDAT=b;
     while(!transmit_completed);	// wait end of transmition;TILL SPIF = 1 
		 transmit_completed = 0;    	// clear software transfert flag
					
		 if(count>=15000&&count<29000)
		 {a=0x77;b=0xFF;}
		 if (count >=29000)
		 {a=0x70;b=0x00;}
		 count++;
		 CS_BAR=1;
			
		}
	}
}	


void modereq(void)                //Function to decide which waveform to produce
{ p=w0;
	q=w1;
	r=f0;
	s=f1;
	if(p==0&&q==0)               //Square Wave
	{ 
		if(r==0&&s==0)            //For deciding frequency
		{ tm=0;
			a=0x7F;
		  b=0xFF;
		}
		if(r==1&&s==0)
		{ tm=1;
			a=0x7F;
		  b=0xFF;
		}
		if(r==0&&s==1)
		{ tm=2;
			a=0x7F;
		  b=0xFF;
		}
		
	}
	else{
	if(p==1&&q==0)                        //Triangular Wave
	{ inv=0;
		if(r==0&&s==0)
		{ tm=0;
			a=0x7F;
		  b=0xFF;
		}
		if(r==1&&s==0)
		{ tm=1;
			a=0x7F;
		  b=0xFF;
		}
		if(r==0&&s==1)
		{ tm=2;
			a=0x7F;
		  b=0xFF;
		}
		
	}
	else{
	if(p==0&&q==1)                          //Sawtooth wave
	{ inv=0;
		rep=1;
		if(r==0&&s==0)
		{ tm=0;
			a=0x7F;
		  b=0xFF;
		}
		if(r==1&&s==0)
		{ tm=1;
			a=0x7F;
		  b=0xFF;
		}
		if(r==0&&s==1)
		{ tm=2;
			a=0x7F;
		  b=0xFF;
		}
		
	}
	if(p==1&&q==1)                              //DC Value
	{ inv=0;
		a=0x7F;
		b=0xFF;
	}
}	
	}
}





void it_SPI(void) interrupt 9 /* interrupt address is 0x004B */
{
	switch	( SPSTA )         /* read and clear spi status register */
	{
		case 0x80:	
			serial_data=SPDAT;   /* read receive data */
      transmit_completed=1;/* set software flag */
 		break;

		case 0x10:
         /* put here for mode fault tasking */	
		break;
	
		case 0x40:
         /* put here for overrun tasking */	
		break;
	}
}



void SPI_Init()
{
	CS_BAR = 1;	                  	// DISABLE ADC SLAVE SELECT-CS 
	SPCON |= 0x20;               	 	// P1.1(SSBAR) is available as standard I/O pin 
	SPCON |= 0x01;                	// Fclk Periph/4 AND Fclk Periph=12MHz ,HENCE SCK IE. BAUD RATE=3000KHz 
	SPCON |= 0x10;               	 	// Master mode 
	SPCON |= 0x08;               	  // CPOL=1; transmit mode example|| SCK is 0 at idle state
	SPCON |= 0x04;                	// CPHA=1; transmit mode example 
	IEN1 |= 0x04;                	 	// enable spi interrupt 
	EA=1;                         	// enable interrupts 
	SPCON |= 0x40;                	// run spi;ENABLE SPI INTERFACE SPEN= 1 
}


void Timer_Init()
{
	// Set Timer0 to work in up counting 16 bit mode. Counts upto 
	// 65536 depending upon the calues of TH0 and TL0
	// The timer counts 65536 processor cycles. A processor cycle is 
	// 12 clocks. FOr 24 MHz, it takes 65536/2 uS to overflow
	// By setting TH0TL0 to 3CB0H, the timer overflows every 25 ms
	
	TH0 = 0xB1;											//For 25ms operation
	TL0 = 0xE0;
	TMOD = (TMOD & 0xF0) | 0x01;  	// Set T/C0 Mode 
	ET0 = 1;                      	// Enable Timer 0 Interrupts 
	TR0 = 1;                      	// Start Timer 0 Running 
}


void timer0_ISR (void) interrupt 1
{
	if(p==0&&q==0)      //To invert values for square
  {inv=~inv;
	if(tm==0)          //100Hz
	{	
	TH0 = 0xD8;											
	TL0 = 0xF0;
	}
	if(tm==1)         //200Hz
	{
	TH0 = 0xEC;											
	TL0 = 0x78;
	}
	if(tm==2)         //500Hz
	{
	TH0 = 0xF8;											
	TL0 = 0x30;
	}
	}
		
	if(p==0&&q==1)      //For Sawtooth
	{rep=1;
	
	if(tm==0)          //100Hz
	{	
	TH0 = 0xB1;											
	TL0 = 0xE0;
	}
	if(tm==1)         //200Hz
	{
	TH0 = 0xD8;											
	TL0 = 0xF0;
	}
	if(tm==2)         //500Hz
	{
	TH0 = 0xF0;											
	TL0 = 0x60;
	}
	}
}
