%{

%}



ID		[a-zA-Z][0-9a-zA-Z]*
invalidInt	0[0-9]+
Int		[0-9]*
invalidFP	(0|[1-9][0-9]*)\.[0-9]*[0]+
FP		(0|[1-9][0-9]*)\.([0-9]*[1-9])?
invalidExp	(0|[1-9][0-9]*)\.([0-9]*[0]+[eE][0-9]*|[0-9]*[eE]-?[0]+[0-9]+)
Exp		(0|[1-9][0-9]*)\.([0-9]*[1-9])?[eE](0|-?[1-9][0-9]*)	
Comment		%%.*\n
String		\"[^"]*\"	



%%

[bB][eE][gG][iI][nN] 				{	return 1;}
[eE][nN][dD]					{	return 2;}	
[rR][eE][aA][dD]				{	return 3;}
[wW][eR][iI][tT][eE]				{	return 4;}



{Comment}					{		 }
{invalidInt}					{	return -1;}
{ID}						{	return 5;}
{invalidFP}					{	return -1;}
{FP}						{	return 7;}
{invalidExp}					{	return -1;}
{Exp}						{	return 8;}
{Int}						{	return 6;}
{String}					{	return 9;}


"("						{	return 10;}
")"						{	return 11;}
";"						{	return 12;}
","						{	return 13;}
":="						{	return 14;}
"+"						{	return 15;}
"-"						{	return 16;}
"*"						{	return 17;}
"/"						{	return 18;}
"!="						{	return 19;}
">"						{	return 20;}
"<"						{	return 21;}
">="						{	return 22;}
"<="						{	return 23;}
"=="						{	return 24;}
[iI][fF]					{	return 25;}
[tT][hH][eE][nN]				{	return 26;}
[eE][lL][sS][eE]				{	return 27;}
[eE][nN][dD][iI][fF]				{	return 28;}
[fF][oO][rR]					{	return 29;}
[tT][oO]					{	return 30;}
[eE][nN][dD][fF][oO][rR]			{	return 31;}
[wW][hH][iI][lL][eE]				{	return 32;}
[eE][nN][dD][wW][hH][iI][lL][eE]		{	return 33;}
[dD][eE][cC][lL][aA][rR][eE]			{	return 34;}
[aA][sS]					{	return 35;}
[iI][nN][tT][eE][gG][eE][eR]			{	return 36;}
[rR][eE][aA][lL]				{	return 37;}



[ \t\n]	;

.		{	return -1;}

%%




main()
{
	int tokenNumber;
	while(1){
		tokenNumber = yylex();
		if(tokenNumber == -1)
		{
			printf("Lexical error, terminated\n");
			exit(1);
		}else if(tokenNumber == 0)
		{
			printf("Token number is 38, value is \"EOF\"\n");
			exit(1);
		}else{
			printf("Token number is %d, value is %s\n", tokenNumber, yytext);
		}
	};

}
