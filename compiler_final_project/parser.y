%{
#include"compiler.h"

/*	glibc	*/
#include<stdio.h>
#include<stdbool.h>

/*				
 *region of the data structures	
 */
char programName[256];

/* symbol table	*/
struct symbol symbolTable[64];
int symbolNum;
char symbolType[12];

/*	output the content of output buffer to screen before exit	*/
char outputBuffer[64][256];
int outputLineCount;

/*	for loop	*/
int loopStart, loopEnd;
bool firstOperation = true;
struct symbol* loopControlVariable;		/*	I in loop	*/

/*	tmp data	*/
int tmpVarCounter;

/*	label	*/
int labelCounter;

/*	current region	*/
int region;

/*	a sequnce of numbers	*/
char sequence[64][32];
int sequenceNumCount;

char tmpLine[256];
char microBuffer[8];
int offset;
int len;

char ifOrElse;
/*
 *end of data structure region				
 */



int start;
int end = -1;

/*	decalre all tmp datas	*/
void releaseTmpDataDeclaration();

/*	output the results to the stdout if compile successfully	*/
static void cleanBuffer();

/*	symbol table look up	*/
struct symbol* lookup(char* symbol);

/*	external functions and variables	*/
extern int yylex(void); 
extern char assignmentRegionSymbol[256];
%}

/*	for yylval data type*/
%union{
	int symbolValue;
	struct symbol* symbolPointer;
}

/*	terminals	*/
%token COMPILER COMMENT BEGINNING ENDING PROGRAM PROGRAM_NAME DECLARE AS INTEGER FLOAT FOR TO ENDFOR IF THEN ELSE ENDIF PRINT
%token <symbolValue> NUM
%token <symbolPointer> FLOAT_NUM
%token <symbolPointer> VAR_NAME 

/*	non-terminals	*/
%type <symbolPointer> var_name
%type <symbolPointer> expression
%type <symbolPointer> var_name_special_top_half
%type <symbolPointer> var_name_special_bottom_half
%type <symbolPointer> sequence_num

/*	associative	and priority	*/
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS


%%
go				:	comment program_header BEGINNING statement_list ENDING	{
						releaseTmpDataDeclaration();	
						cleanBuffer();
					}
				;

comment			:	COMMENT comment
				|
				;

program_header	:	COMPILER PROGRAM PROGRAM_NAME	{
						sprintf(outputBuffer[outputLineCount], "          START %s\n", programName);
						outputLineCount++;	
					}
				;

statement_list	: 	statement 
				|	statement_list statement
				;

statement		:	var_declare
				|	for
				|	assignment
				|	if_else
				|	print
				;

/*	ASSIGNMENT REGION	*/
assignment		:	var_name ':' '=' expression	';'	{
						if(firstOperation){
							if($1->isArray == IS_ARRAY && $4->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_STORE %s,%s[%s]\n", labelCounter + 1, *($1->type), $4->symbolName, $1->symbolName, loopControlVariable->symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $4->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_STORE %s[%s],%s\n", labelCounter + 1, *($1->type), $4->symbolName, loopControlVariable->symbolName, $1->symbolName);
							}else if($1->isArray == IS_ARRAY && $4->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_STORE %s[%s],%s[%s]\n", labelCounter + 1, *($1->type), $4->symbolName, loopControlVariable->symbolName, $1->symbolName, loopControlVariable->symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_STORE %s,%s\n", labelCounter + 1, *($1->type), $4->symbolName, $1->symbolName);
							}
							++labelCounter;
							firstOperation = false;
						}else{
							if($1->isArray == IS_ARRAY && $4->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_STORE %s,%s[%s]\n", *($1->type), $4->symbolName, $1->symbolName, loopControlVariable->symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $4->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_STORE %s[%s],%s\n", *($1->type), $4->symbolName, loopControlVariable->symbolName, $1->symbolName);
							}else if($1->isArray == IS_ARRAY && $4->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_STORE %s[%s],%s[%s]\n", *($1->type), $4->symbolName, loopControlVariable->symbolName, $1->symbolName, loopControlVariable->symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "          %c_STORE %s,%s\n", *($1->type), $4->symbolName, $1->symbolName);
							}
						}
						++outputLineCount;
					}
				;

expression		:	expression '+' expression	{
						symbolTable[symbolNum].isArray = IS_NOT_ARRAY;
						sprintf(symbolTable[symbolNum].symbolName, "T&%d", tmpVarCounter + 1);
						++tmpVarCounter;
						symbolTable[symbolNum].region = ASSIGNMENT_REGION;
						symbolTable[symbolNum].arraySize = -1;
						strcpy(symbolTable[symbolNum].type, $1->type);
						if(firstOperation){
							if($1->isArray == IS_ARRAY && $3->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_ADD %s[%s],%s,%s\n", labelCounter + 1, *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_ADD %s,%s[%s],%s\n", labelCounter + 1, *($1->type), $1->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_ADD %s[%s],%s[%s],%s\n", labelCounter + 1, *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_ADD %s,%s,%s\n", labelCounter + 1, *($1->type), $1->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}
							++labelCounter;
							firstOperation = false;
						}else{
							if($1->isArray == IS_ARRAY && $3->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_ADD %s[%s],%s,%s\n", *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_ADD %s,%s[%s],%s\n", *($1->type), $1->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_ADD %s[%s],%s[%s],%s\n", *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "          %c_ADD %s,%s,%s\n", *($1->type), $1->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}
						}
						++outputLineCount;
						$$ = &symbolTable[symbolNum];
						++symbolNum;
					}
				|	expression '-' expression	{
						symbolTable[symbolNum].isArray = IS_NOT_ARRAY;
						sprintf(symbolTable[symbolNum].symbolName, "T&%d", tmpVarCounter + 1);
						++tmpVarCounter;
						symbolTable[symbolNum].region = ASSIGNMENT_REGION;
						symbolTable[symbolNum].arraySize = -1;
						strcpy(symbolTable[symbolNum].type, $1->type);
						if(firstOperation){
							if($1->isArray == IS_ARRAY && $3->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_SUB %s[%s],%s,%s\n", labelCounter + 1, *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_SUB %s,%s[%s],%s\n", labelCounter + 1, *($1->type), $1->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_SUB %s[%s],%s[%s],%s\n", labelCounter + 1, *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_SUB %s,%s,%s\n", labelCounter + 1, *($1->type), $1->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}
							++labelCounter;
							firstOperation = false;
						}else{
							if($1->isArray == IS_ARRAY && $3->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_SUB %s[%s],%s,%s\n", *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_SUB %s,%s[%s],%s\n", *($1->type), $1->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_SUB %s[%s],%s[%s],%s\n", *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "          %c_SUB %s,%s,%s\n", *($1->type), $1->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}
						}
						++outputLineCount;
						$$ = &symbolTable[symbolNum];
						++symbolNum;
					}
				|	expression '*' expression 	{
						symbolTable[symbolNum].isArray = IS_NOT_ARRAY;
						sprintf(symbolTable[symbolNum].symbolName, "T&%d", tmpVarCounter + 1);
						++tmpVarCounter;
						symbolTable[symbolNum].region = ASSIGNMENT_REGION;
						symbolTable[symbolNum].arraySize = -1;
						strcpy(symbolTable[symbolNum].type, $1->type);
						if(firstOperation){
							if($1->isArray == IS_ARRAY && $3->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_MUL %s[%s],%s,%s\n", labelCounter + 1, *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_MUL %s,%s[%s],%s\n", labelCounter + 1, *($1->type), $1->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_MUL %s[%s],%s[%s],%s\n", labelCounter + 1, *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_MUL %s,%s,%s\n", labelCounter + 1, *($1->type), $1->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}
							++labelCounter;
							firstOperation = false;
						}else{
							if($1->isArray == IS_ARRAY && $3->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_MUL %s[%s],%s,%s\n", *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_MUL %s,%s[%s],%s\n", *($1->type), $1->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_MUL %s[%s],%s[%s],%s\n", *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "          %c_MUL %s,%s,%s\n", *($1->type), $1->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}
						}
						++outputLineCount;
						$$ = &symbolTable[symbolNum];
						++symbolNum;
					}
				|	expression '/' expression	{
						symbolTable[symbolNum].isArray = IS_NOT_ARRAY;
						sprintf(symbolTable[symbolNum].symbolName, "T&%d", tmpVarCounter + 1);
						++tmpVarCounter;
						symbolTable[symbolNum].region = ASSIGNMENT_REGION;
						symbolTable[symbolNum].arraySize = -1;
						strcpy(symbolTable[symbolNum].type, $1->type);
						if(firstOperation){
							if($1->isArray == IS_ARRAY && $3->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_DIV %s[%s],%s,%s\n", labelCounter + 1, *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_DIV %s,%s[%s],%s\n", labelCounter + 1, *($1->type), $1->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_DIV %s[%s],%s[%s],%s\n", labelCounter + 1, *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_DIV %s,%s,%s\n", labelCounter + 1, *($1->type), $1->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}
							++labelCounter;
							firstOperation = false;
						}else{
							if($1->isArray == IS_ARRAY && $3->isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_DIV %s[%s],%s,%s\n", *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_NOT_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_DIV %s,%s[%s],%s\n", *($1->type), $1->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else if($1->isArray == IS_ARRAY && $3->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_DIV %s[%s],%s[%s],%s\n", *($1->type), $1->symbolName, loopControlVariable->symbolName, $3->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "          %c_DIV %s,%s,%s\n", *($1->type), $1->symbolName, $3->symbolName, symbolTable[symbolNum].symbolName);
							}
						}
						++outputLineCount;
						$$ = &symbolTable[symbolNum];
						++symbolNum;
					}

					/*	'-' expression %prec UMINUS	*/
				|	'-' expression %prec UMINUS	{
						symbolTable[symbolNum].isArray = IS_NOT_ARRAY;
						sprintf(symbolTable[symbolNum].symbolName, "T&%d", tmpVarCounter + 1);
						++tmpVarCounter;
						symbolTable[symbolNum].region = ASSIGNMENT_REGION;
						symbolTable[symbolNum].arraySize = -1;
						strcpy(symbolTable[symbolNum].type, $2->type);
						if(firstOperation){
							if($2->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_UMINUS %s[%s],%s\n", labelCounter + 1, *($2->type), $2->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}
							else{
								sprintf(outputBuffer[outputLineCount], "lb&%d:     %c_UMINUS %s,%s\n", labelCounter + 1, *($2->type), $2->symbolName, symbolTable[symbolNum].symbolName);
							}
							++labelCounter;
							firstOperation = false;
						}else{
							if($2->isArray == IS_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          %c_UMINUS %s[%s],%s\n", *($2->type), $2->symbolName, loopControlVariable->symbolName, symbolTable[symbolNum].symbolName);
							}else{
								sprintf(outputBuffer[outputLineCount], "          %c_UMINUS %s,%s\n", *($2->type), $2->symbolName, symbolTable[symbolNum].symbolName);
							}
						}
						++outputLineCount;
						$$ = &symbolTable[symbolNum];
						++symbolNum;
					}
				|	'(' expression ')'	{	$$ = $2;	}
				|	NUM		{
						symbolTable[symbolNum].isArray = false;
						sprintf(symbolTable[symbolNum].symbolName, "%d",$1);
						symbolTable[symbolNum].region = region;
						symbolTable[symbolNum].arraySize = -1;
						strcpy(symbolTable[symbolNum].type, "ConstantInteger");
						$$ = &symbolTable[symbolNum];
						++symbolNum;
					}
				|	FLOAT_NUM	{
					$$ = $1;	
				}
				|	var_name	{	$$ = $1;	}
				;
/*	ASSIGNMENT	REGION	*/

/*	start_for statement ENDFOR	*/
for				:	start_for statement ENDFOR	{
						sprintf(outputBuffer[outputLineCount],"          INC %s\n", loopControlVariable->symbolName);
						++outputLineCount;
						sprintf(outputBuffer[outputLineCount],"          I_CMP %s,%d\n", loopControlVariable->symbolName, loopEnd);
						++outputLineCount;
						sprintf(outputBuffer[outputLineCount], "          JL lb&%d\n", labelCounter);
						++outputLineCount;
						//firstOperation = true;
					}
				;

start_for		:	start_for_top_half start_for_bottom_half	{	
						region = ASSIGNMENT_REGION;
					}		
				;

start_for_top_half		:	FOR '(' var_name	{
								loopControlVariable = $3;
								strcpy(loopControlVariable->type, "Integer");
							}
						;

start_for_bottom_half	:	':' '=' range ')'
						;

range			:	NUM TO NUM	{
						loopStart = $1;
						loopEnd = $3;
						sprintf(outputBuffer[outputLineCount], "          I_STORE %d,%s\n", loopStart, loopControlVariable->symbolName);
						outputLineCount++;
						//error case
					}
				;
/*	development	*/
if_else								:	if_top if_middle if_bottom
									|	if_top if_bottom
									;

if_top								:	IF conditional_expression THEN	{
											sprintf(outputBuffer[outputLineCount], "          JL lb&%d\n", labelCounter + 1);
											++outputLineCount;
											++labelCounter;
											ifOrElse = 'I';
										}
									;

conditional_expression				:	'(' VAR_NAME '>' '=' NUM ')'	{
											if(strcmp($2->type, "Integer"))
											{
												fprintf(stderr, "Incompatible type of variable %s : %s, expect Integer data type.\n", $2->symbolName, $2->type);
												exit(1);
											}
											sprintf(outputBuffer[outputLineCount], "          I_CMP %s,%d\n", $2->symbolName, $5);
											++outputLineCount;
										}
									|	'(' VAR_NAME '>' '=' FLOAT_NUM ')'	{
											if(strcmp($2->type, "Float"))
											{
												fprintf(stderr, "Incompatible type of variable %s : %s, expect Float data type.\n", $2->symbolName, $2->type);
												exit(1);
											}
											sprintf(outputBuffer[outputLineCount], "          F_CMP %s,%s\n", $2->symbolName, $5->symbolName);
											++outputLineCount;
										}
									;

if_middle							:	statement ELSE	{
											sprintf(outputBuffer[outputLineCount], "          J lb&%d\n", labelCounter + 1);
											++outputLineCount;
											//++labelCounter;
											ifOrElse = 'E';
										} 
									;

if_bottom							:	statement ENDIF	{
											sprintf(outputBuffer[outputLineCount], "lb&%d:     HALT %s\n", labelCounter + 1, programName);
											++outputLineCount;
										}
									;

print								:	PRINT '(' expression ')' ';'	{
											if(ifOrElse == 'I')
											{
												sprintf(outputBuffer[outputLineCount], "          CALL print,%s\n", $3->symbolName);
												++outputLineCount;
											}else{	/*	ifOrElse == 'E'	*/
												sprintf(outputBuffer[outputLineCount], "lb&%d:     CALL print,%s\n", labelCounter, $3->symbolName);
												++outputLineCount;
											}
										}
									|	PRINT '(' sequence ')' ';'	{
											if(ifOrElse == 'I')
											{
												sprintf(tmpLine + offset, "          CALL print,");
												offset += 21;
												for(int i = 0; i < sequenceNumCount; ++i)
												{
													if(i != 0){
														sprintf(tmpLine + offset, ",");
														++offset;
													}
													strcpy(tmpLine + offset, sequence[i]);
													len = strlen(sequence[i]);
													offset += len;
												}
												sprintf(tmpLine + offset, "\n");
												strcpy(outputBuffer[outputLineCount], tmpLine);
												++outputLineCount;
											}else{	/*	ifOrElse == 'E'	*/
												int labelLength;
												sprintf(microBuffer, "%d", labelCounter - 1);
												labelLength = strlen(microBuffer);
												sprintf(tmpLine + offset, "lb&%d", labelCounter);
												offset += 3 + labelLength;
												sprintf(tmpLine + offset, ":     CALL print,");
												offset += 17;
												for(int i = 0; i < sequenceNumCount; ++i)
												{
													if(i != 0){
														sprintf(tmpLine + offset, ",");
														++offset;
													}
													strcpy(tmpLine + offset, sequence[i]);
													len = strlen(sequence[i]);
													offset += len;
												}
												sprintf(tmpLine + offset, "\n");
												strcpy(outputBuffer[outputLineCount], tmpLine);	
												++outputLineCount;
											}
										}
									;

sequence							:	sequence_num ',' sequence
									|	sequence_num
									;

sequence_num						:	NUM		{
											symbolTable[symbolNum].isArray = false;
											sprintf(symbolTable[symbolNum].symbolName, "%d",$1);
											symbolTable[symbolNum].region = region;
											symbolTable[symbolNum].arraySize = -1;
											strcpy(symbolTable[symbolNum].type, "ConstantInteger");
											$$ = &symbolTable[symbolNum];
											++symbolNum;

											strcpy(sequence[sequenceNumCount], $$->symbolName);
											++sequenceNumCount;
										}
									|	FLOAT_NUM	{	
											$$ = $1;
											strcpy(sequence[sequenceNumCount], $$->symbolName);
											++sequenceNumCount;
										}
									;

/*	development	*/

var_declare		:	DECLARE var_list AS var_type ';'	{
						for(int i = start; i <= end; i++)
						{
							strcpy(symbolTable[i].type, symbolType);	
						}

						for(int i = start; i <= end; i++)
						{
							if(symbolTable[i].isArray == IS_NOT_ARRAY)
							{
								sprintf(outputBuffer[outputLineCount], "          Declare %s,%s\n", symbolTable[i].symbolName, symbolTable[i].type);
							}else{
								sprintf(outputBuffer[outputLineCount], "          Declare %s,%s_array,%d\n", symbolTable[i].symbolName, symbolTable[i].type, symbolTable[i].arraySize);
							}
							++outputLineCount;
						}
					}
				;

var_list		:	var_name	
				|	var_list ',' var_name
				;

var_name		:	VAR_NAME	{
						if(region == DECLARE_REGION || region == FOR_REGION){
							symbolTable[symbolNum].isArray = IS_NOT_ARRAY;
							symbolTable[symbolNum].arraySize = -1;
							$$ = &symbolTable[symbolNum];
							++symbolNum;
						}else{	/*	ASSIGNMENT_REGION	*/
							$$ = $1;
						}
					}
				|	VAR_NAME '[' NUM ']'	{
						if(region == DECLARE_REGION || region == FOR_REGION){
							symbolTable[symbolNum].isArray = IS_ARRAY;
							symbolTable[symbolNum].arraySize = $3;
							++symbolNum;
						}else{	/*	ASSIGNMENT_REGION	*/
							$$ = $1;	/*	temporarily wrong	*/
						}
					}
				|	var_name_special_top_half var_name_special_bottom_half	{
						$$ = $1;
					}
				;

var_name_special_top_half			:	VAR_NAME '['	{
											$$ = $1;
										}
									;
var_name_special_bottom_half		:	VAR_NAME ']'	{
											$$ = $1;
										}
									;

var_type		:	INTEGER
				|	FLOAT
				;
%%

static void cleanBuffer()
{
	for(int i = 0; i < outputLineCount; i++)
	{
		printf("%s", outputBuffer[i]);
	}
}

struct symbol* lookup(char* symbol)
{
	for(int i = 0; i < symbolNum; i++)
	{
		if(!strcmp(symbol, symbolTable[i].symbolName))
		{
			return &symbolTable[i];
		}
	}
	fprintf(stderr, "Undefined variable:%s\n", symbol);
	exit(1);
	return 0x00;
}

void releaseTmpDataDeclaration()
{
	sprintf(outputBuffer[outputLineCount], "\n");
	++outputLineCount;
	for(int i = 0; i < symbolNum; i++)
	{
		if((symbolTable[i].symbolName)[0] == 'T' && (symbolTable[i].symbolName)[1] == '&')
		{
			sprintf(outputBuffer[outputLineCount], "          Declare %s,%s\n", symbolTable[i].symbolName, symbolTable[i].type);
			++outputLineCount;
		}
	}
}
