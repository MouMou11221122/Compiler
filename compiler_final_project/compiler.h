#define IS_ARRAY					true
#define IS_NOT_ARRAY				false
#define DECLARE_REGION				98
#define FOR_REGION					99
#define ASSIGNMENT_REGION			100
#define IF_ELSE_REGION				101

/*		gibc		*/
#include<stdbool.h>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

struct symbol{
	bool isArray;
	char symbolName[256];
	int region;
	int arraySize;
	char type[20];
};
