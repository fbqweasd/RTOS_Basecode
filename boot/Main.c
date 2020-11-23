#include <stdint.h>
#include "HalUart.h"
#include "HalInterrupt.h"
#include "HalTimer.h"

#include "stdio.h"
#include "stdlib.h"

//#include "task.h"
#include "Kernel.h"

static void Hw_init(void);
static void Kernel_init(void);

void User_task0(void);
void User_task1(void);
void User_task2(void);

void main(void){

	Hw_init();

	uint32_t i;
	putstr("Hello, World!\n");

	debug_printf("test print\n");
	debug_printf("test print : %u\n", 100);
	debug_printf("%s\n", "testestst");

//	uint32_t * sysctrl0 = (uint32_t*)0x0001000;
//	debug_printf("time : %x\n", *sysctrl0);

//	while(1){
//		debug_printf("current count : %u\n", Hal_timer_get_1ms_counter());
//		delay(1000);
//	}

	Kernel_init();

	while(1);
}

static void Kernel_init(void)
{
    uint32_t taskId;
    Kernel_task_init();

    taskId = Kernel_task_create(User_task0);
    if (NOT_ENOUGH_TASK_NUM == taskId)
    {
        putstr("Task0 creation fail\n");
    }

    taskId = Kernel_task_create(User_task1);
    if (NOT_ENOUGH_TASK_NUM == taskId)
    {
        putstr("Task1 creation fail\n");
    }

    taskId = Kernel_task_create(User_task2);
    if (NOT_ENOUGH_TASK_NUM == taskId)
    {
        putstr("Task2 creation fail\n");
    }

    debug_printf("Kernel init test \n");
    
    Kernel_start();
}


static void Hw_init(void){
	Hal_interrupt_init();
	Hal_uart_init();
	Hal_timer_init();
}

void User_task0(void)
{
    uint32_t local = 0;

    while(1){
	debug_printf("User Task #0 SP = 0x%x\n", &local);
	Kernel_yield();
    }
}

void User_task1(void)
{
    uint32_t local = 0;

    while(1){
	debug_printf("User Task #1 SP = 0x%x\n", &local);
	Kernel_yield();
    }
}

void User_task2(void)
{
    uint32_t local = 0;

    while(1){
	debug_printf("User Task #2 SP = 0x%x\n", &local);
	Kernel_yield();
    }
}
