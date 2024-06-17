%{
#include"parser.h"
#include"compiler.h"

extern char programName[256];
extern struct symbol symbolTable[32];
extern int symbolNum;
extern char symbolType[10];
extern int region;		
extern char outputBuffer[64][256];
extern int outputLineCount;
extern int region;
extern int start;
extern int end;
char assignmentRegionSymbol[256];
extern struct symbol* lookup(char* symbol);
bool haveScannedProgramName = false;
extern char sequence[64][32];
extern int sequenceNumCount;
extern int offset;
%}

%%
[ \t\n]	;

\%\%[^\n]*\n	{	return COMMENT;		}

"Micro/Ex"	{	return COMPILER;	}

"Begin"		{	return BEGINNING;	}

"End"		{	return ENDING;		}

"Program"	{	return PROGRAM;		}

"declare"	{
				start = symbolNum;
				region = DECLARE_REGION; 	/*	set the region	*/
				return DECLARE;		
			}

"as"		{	return AS;	}

[1-9][0-9]*	{	yylval.symbolValue = atoi(yytext);	return NUM;		}

(0|[1-9][0-9]*)\.(0|[0-9]*[1-9])	{
	symbolTable[symbolNum].isArray = false;
	strcpy(symbolTable[symbolNum].symbolName, yytext);
	symbolTable[symbolNum].region = region;
	symbolTable[symbolNum].arraySize = -1;
	strcpy(symbolTable[symbolNum].type, "ConstantFloat");
	yylval.symbolPointer = &symbolTable[symbolNum];
	++symbolNum;
	return FLOAT_NUM;
}

"integer"	{	strcpy(symbolType, "Integer");	return INTEGER;		}

"float"		{	strcpy(symbolType, "Float");	return FLOAT;	}

"FOR"		{	
				sprintf(outputBuffer[outputLineCount], "\n\n");
				++outputLineCount;
				region = FOR_REGION;		/*	set the region	*/
				return FOR;
			}

"TO"		{	return TO;	}

"ENDFOR"	{	return ENDFOR;	}

"IF"		{	
				sprintf(outputBuffer[outputLineCount], "\n\n");
				++outputLineCount;
				region = IF_ELSE_REGION;
				return IF;
			}

"THEN"		{	return THEN;	}

"ELSE"		{	return ELSE;	}

"ENDIF"		{	return ENDIF;	}

"print"		{	
				offset = 0;
				sequenceNumCount = 0;
				return PRINT;
			}

[A-Za-z][A-Za-z0-9]*	{	
		if(!haveScannedProgramName){
			haveScannedProgramName = true;
			strcpy(programName, yytext);
			return PROGRAM_NAME;
		}else{
			if(region == DECLARE_REGION || region == FOR_REGION){
				strcpy(symbolTable[symbolNum].symbolName, yytext);
				symbolTable[symbolNum].region = region;
				++end;
			}else if(region == ASSIGNMENT_REGION || region == IF_ELSE_REGION){	
				yylval.symbolPointer = lookup(yytext);
			}
			return VAR_NAME;
		}
}

">"			|
"+"			|
"-"			|
"*"			|
"/"			|
"("			|
")"			|
"="			|
":"			|
";"			|
","			|
"["			|
"]"			{	return yytext[0];	}
%%

