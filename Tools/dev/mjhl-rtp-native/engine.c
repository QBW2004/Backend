/* Sampling-only implementation of mjhl.engine.js. No game rules or RNG changes.
 * Fixed storage avoids per-cell/line/cascade allocation. Build without fast-math. */
typedef unsigned int u32;
typedef unsigned long long u64;
static const int lengths[5]={9,12,12,12,9}, tops[5]={4,6,6,6,4}, visible[5]={4,5,5,5,4};
static const int pay[9][3]={{1,3,6},{1,3,6},{3,5,12},{3,5,12},{5,10,15},{6,15,30},{8,20,40},{10,25,50},{2,4,10}};
static const int mults[2][4]={{1,2,3,5},{2,4,6,10}};
static int input[123], total, enabled;
static double goldThreshold;
static unsigned char drawsTable[10000000], choices[512][9], choiceCount[512];
static u32 a,b,c,d;
static u64 draws;
/* n, normal sum, free sum, first hit, scatter trigger, cap, mean, M2,
 * six payout bands, paid+free spins, cascade rounds, total score, RNG draws */
static double stats[18];
static int grid[5][12];
static int spinWin,spinScatter,spinRounds,spinHit,spinCap;
static double probabilities[2][5][12], symbolQ[9], conditionalQ[3][9], expectedWays;
static u64 symbolCut[9], conditionalCut[3][9];
static int proposalMask,importanceMode,rawCovered;
static double importanceDensity;
int *config_ptr(void){return input;}
double *stats_ptr(void){return stats;}
static u32 random32(void){
    u32 v=b*5u,result=((v<<7)|(v>>25))*9u,t=b<<9;
    c^=a;d^=b;b^=c;a^=d;c^=t;d=(d<<11)|(d>>21);draws++;
    return result;
}
int configure(void){
    total=input[120];enabled=input[121];
    if(total<100||total>1000000||enabled<1||enabled>511||input[122]<0||input[122]>10000)return 1;
    goldThreshold=((double)input[122]/10000.0)*4294967296.0;
    for(int m=0;m<2;m++)for(int col=0;col<5;col++){
        int offset=(m*5+col)*total,pos=0;
        for(int s=0;s<12;s++){
            int w=input[(m*12+s)*5+col];
            if(w<0||w>total-pos)return 1;
            u64 before=((u64)pos*4294967296ull+(u32)total-1)/(u32)total;
            u64 after=((u64)(pos+w)*4294967296ull+(u32)total-1)/(u32)total;
            probabilities[m][col][s]=(double)(after-before)/4294967296.0;
            for(int k=0;k<w;k++)drawsTable[offset+pos++]=(unsigned char)s;
        }
        if(pos!=total)return 1;
    }
    for(int mask=0;mask<512;mask++){
        choiceCount[mask]=0;
        for(int s=1;s<=9;s++)if(mask&(1<<(s-1)))choices[mask][choiceCount[mask]++]=(unsigned char)s;
    }
    double masses[9],sum=0;proposalMask=0;
    for(int s=0;s<9;s++){
        masses[s]=100.0*probabilities[1][0][s]*(probabilities[1][1][s]+probabilities[1][1][9])*(probabilities[1][2][s]+probabilities[1][2][9]);
        sum+=masses[s];
        for(int col=0;col<3;col++){
            double p=probabilities[1][col][s],all=p+probabilities[1][col][9],cut=all>0?p/all*4294967296.0:0;
            conditionalCut[col][s]=(u64)cut;if((double)conditionalCut[col][s]<cut)conditionalCut[col][s]++;
            conditionalQ[col][s]=(double)conditionalCut[col][s]/4294967296.0;
        }
    }
    expectedWays=sum;double cumulative=0;u64 previous=0;
    for(int s=0;s<9;s++){
        cumulative+=masses[s];double cut=sum>0?cumulative/sum*4294967296.0:0;
        symbolCut[s]=(u64)cut;if((double)symbolCut[s]<cut)symbolCut[s]++;
        if(symbolCut[s]>4294967296ull)symbolCut[s]=4294967296ull;
        symbolQ[s]=(double)(symbolCut[s]-previous)/4294967296.0;previous=symbolCut[s];
        if(symbolQ[s]>0)proposalMask|=1<<s;
    }
    return 0;
}
void reset(u32 s0,u32 s1,u32 s2,u32 s3){
    a=s0;b=s1;c=s2;d=s3;draws=0;
    for(int i=0;i<18;i++)stats[i]=0;
}
static int drawCell(int col,int freeMode){
    int i=(int)(((u64)random32()*(u32)total)>>32);
    int symbol=drawsTable[(freeMode*5+col)*total+i];
    if(symbol<9){
        symbol++;
        if(freeMode&&col==2)return 100+symbol;
        if(col>=1&&col<=3&&(double)random32()<goldThreshold)return 100+symbol;
        return symbol;
    }
    return symbol==9?20:symbol==10?30:-2;
}
static int visibleMask(int col){
    int mask=0;
    for(int i=tops[col];i<tops[col]+visible[col];i++){
        int v=grid[col][i];
        if(v==20)return 511;
        if(v>=100)v-=100;
        if(v>=1&&v<=9)mask|=1<<(v-1);
    }
    return mask;
}
static void substitute(int freeMode){
    for(int col=0;col<5;col++){
        int mask=0;
        for(int i=0;i<lengths[col];i++){
            if(grid[col][i]!=-2)continue;
            if(!mask){
                mask=col==0?enabled&~(visibleMask(1)&visibleMask(2)):enabled&~visibleMask(0);
                if(col>=2&&mask){int strong=mask&~visibleMask(1);if(strong)mask=strong;}
                if(!mask)mask=enabled;
            }
            int pick=(int)(((u64)random32()*(u32)choiceCount[mask])>>32);
            grid[col][i]=choices[mask][pick]+((freeMode&&col==2)?100:0);
        }
    }
}
static int scatterCount(void){
    int n=0;
    for(int col=0;col<5;col++)for(int i=tops[col];i<tops[col]+visible[col];i++)n+=grid[col][i]==30;
    return n;
}
/* Q is a mixture of 9 symbols x 4x5x5 forced matching initial paths.
 * Q/P is summed over EVERY path that could have produced the raw grid.
 * Integer RNG bucket probabilities are used, including the nonuniform /5 buckets. */
static double proposalDensity(void){
    double density=0;
    for(int s=0;s<9;s++)if(symbolQ[s]>0){
        double product=symbolQ[s];
        for(int col=0;col<3;col++){
            double ratio=0;u64 prev=0;
            for(int j=0;j<visible[col];j++){
                u64 cut=((u64)(j+1)*4294967296ull+(u32)visible[col]-1)/(u32)visible[col];
                double qpos=(double)(cut-prev)/4294967296.0;prev=cut;
                int value=grid[col][tops[col]+j];if(value>=100)value-=100;
                if(value==s+1&&probabilities[1][col][s]>0)ratio+=qpos*conditionalQ[col][s]/probabilities[1][col][s];
                else if(value==20&&probabilities[1][col][9]>0)ratio+=qpos*(1-conditionalQ[col][s])/probabilities[1][col][9];
            }
            product*=ratio;
        }
        density+=product;
    }
    return density;
}
static int spin(int freeMode){
    const int cap=20000000;
    spinWin=spinScatter=spinRounds=spinHit=spinCap=0;
    int symbol=0,forced[3]={-1,-1,-1};
    if(importanceMode){
        u64 pick=random32();while(symbol<8&&pick>=symbolCut[symbol])symbol++;
        for(int col=0;col<3;col++)forced[col]=tops[col]+(int)(((u64)random32()*(u32)visible[col])>>32);
    }
    for(int col=0;col<5;col++)for(int i=0;i<lengths[col];i++){
        if(importanceMode&&col<3&&i==forced[col]){
            int v=(u64)random32()<conditionalCut[col][symbol]?symbol+1:20;
            if(v!=20&&(col==2||(col==1&&(double)random32()<goldThreshold)))v+=100;
            grid[col][i]=v;
        }else grid[col][i]=drawCell(col,freeMode);
    }
    rawCovered=(visibleMask(0)&visibleMask(1)&visibleMask(2)&proposalMask)!=0;
    importanceDensity=importanceMode?proposalDensity():0;
    substitute(freeMode);
    for(int k=0;;k++){
        int counts[5][10]={{0}},wild[5]={0},winning[5]={0},score=0,hit=0;
        for(int col=0;col<5;col++)for(int i=tops[col];i<tops[col]+visible[col];i++){
            int v=grid[col][i];if(v>=100)v-=100;
            if(v==20)wild[col]++;else if(v>=1&&v<=9)counts[col][v]++;
        }
        for(int s=1;s<=9;s++){
            int ways=1,allWild=1,run=0;
            for(int col=0;col<5;col++){
                int n=counts[col][s]+wild[col];if(!n)break;
                ways*=n;allWild*=wild[col];run++;
            }
            if(run<3||ways<=allWild)continue;
            score+=pay[s-1][run-3]*(ways-allWild)*mults[freeMode][k<3?k:3]*200;
            for(int col=0;col<run;col++)winning[col]|=1<<(s-1);
            hit=1;
        }
        if(score>cap-spinWin)score=cap-spinWin;
        spinRounds++;if(k==0)spinHit=hit;
        int sc=scatterCount();if(sc>spinScatter)spinScatter=sc;
        spinWin+=score;
        if(!hit)return 0;
        for(int col=0;col<5;col++){
            int next[12],kept=0;
            for(int i=0;i<lengths[col];i++){
                int v=grid[col][i],s=v>=100?v-100:v;
                int mark=i>=tops[col]&&i<tops[col]+visible[col]&&
                    ((s>=1&&s<=9&&(winning[col]&(1<<(s-1))))||(v==20&&winning[col]));
                if(mark){if(v>=100)v=20;else continue;}
                next[kept++]=v;
            }
            int removed=lengths[col]-kept;
            for(int i=0;i<removed;i++)grid[col][i]=drawCell(col,freeMode);
            for(int i=0;i<kept;i++)grid[col][removed+i]=next[i];
        }
        substitute(freeMode);
        if(spinWin>=cap){spinCap=1;spinRounds++;sc=scatterCount();if(sc>spinScatter)spinScatter=sc;return 0;}
        if(k+1>=10000)return 1;
    }
}
static int freeAward(int sc){return sc<3?0:10+2*(sc-3);}
int sample(int count){
    for(int i=0;i<count;i++){
        if(spin(0))return 1;
        u64 win=(u64)spinWin;int normal=spinWin,hit=spinHit,trig=spinScatter>=3,capped=spinCap;
        int granted=freeAward(spinScatter),used=0,rounds=spinRounds;
        while(used<granted){
            if(used>=10000||spin(1))return 1;
            used++;rounds+=spinRounds;if(rounds>100000)return 1;
            win+=(u64)spinWin;granted+=freeAward(spinScatter);capped|=spinCap;
        }
        double value=(double)win/4000.0,delta=value-stats[6];
        stats[0]++;stats[1]+=(double)normal/4000.0;stats[2]+=(double)(win-normal)/4000.0;
        stats[3]+=hit;stats[4]+=trig;stats[5]+=capped;
        stats[6]+=delta/stats[0];stats[7]+=delta*(value-stats[6]);
        int band=value==0?0:value<5?1:value<20?2:value<35?3:value<50?4:5;
        stats[8+band]++;stats[14]+=used+1;stats[15]+=rounds;stats[16]+=(double)win;
    }
    stats[17]=(double)draws;return 0;
}
/* Independent components for the branching-process expectation estimator.
 * stats: count, payout sum, grant sum, first-hit count, trigger count, cap count,
 * payout mean/M2, grants mean/M2, covariance numerator. */
int sample_spins(int count,int kind){
    if(kind<0||kind>2)return 1;
    for(int i=0;i<count;i++){
        double win=0,grants=0;
        if(kind!=2||expectedWays>0){
            importanceMode=kind==2;int error=spin(kind!=0);importanceMode=0;if(error)return 1;
            win=(double)spinWin/4000.0;grants=(double)freeAward(spinScatter);
            if(kind==1&&rawCovered)win=0;
            if(kind==2){if(importanceDensity<=0)return 1;win/=importanceDensity;grants=0;}
        }
        double dw=win-stats[6],dg=grants-stats[8];
        stats[0]++;stats[1]+=win;stats[2]+=grants;stats[3]+=spinHit;stats[4]+=spinScatter>=3;stats[5]+=spinCap;
        stats[6]+=dw/stats[0];stats[8]+=dg/stats[0];
        stats[7]+=dw*(win-stats[6]);stats[9]+=dg*(grants-stats[8]);stats[10]+=dw*(grants-stats[8]);
    }
    stats[17]=(double)draws;return 0;
}
