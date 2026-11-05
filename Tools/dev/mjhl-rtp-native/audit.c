/* Test-only exports; never included in the shipped module. */
#include "engine.c"
int *audit_grid_ptr(void){return &grid[0][0];}
double audit_density(void){return proposalDensity();}
double audit_probability(int col,int s){return probabilities[1][col][s];}
double audit_symbol_q(int s){return symbolQ[s];}
double audit_conditional_q(int col,int s){return conditionalQ[col][s];}
