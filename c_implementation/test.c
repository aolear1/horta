#include <stdio.h>
#include <math.h>

void check_pix(int x,int y)
{
    printf("(%d,%d),\n",x,y);
}

/*Regular Bresenham’s circle drawing*/
void run_circle(  int radius,   int centre_y,   int centre_x)
{
    int offset_y = 0;
    int offset_x = radius;
    int crit = 1 - radius;

    while(offset_y <= offset_x)
    {
            check_pix(centre_x + offset_x, centre_y + offset_y);
            check_pix(centre_x + offset_y, centre_y + offset_x);
            check_pix(centre_x - offset_y, centre_y + offset_x);
            check_pix(centre_x - offset_x, centre_y + offset_y);
            check_pix(centre_x - offset_x, centre_y - offset_y);
            check_pix(centre_x - offset_y, centre_y - offset_x);
            check_pix(centre_x + offset_y, centre_y - offset_x);
            check_pix(centre_x + offset_x, centre_y - offset_y);

            offset_y = offset_y + 1;

            if (crit <= 0)
            {
                crit = crit + (2 * offset_y) + 1;
            } else
            {
                offset_x = offset_x - 1;
                crit = crit + (2 * (offset_y - offset_x)) + 1;
            }

            //printf("%d \n", crit);
    }
}

/*TORTA*/
void run_triangbruh(int diameter, int centre_y, int centre_x)
{
    //create vals

    int c_x = centre_x;
    int c_y = centre_y;

    /*Center coordinates for the first circle (top-right)*/
    int c_x1 = (int)round((double)c_x + diameter/2.0);
    int c_y1 = (int)round((double)c_y + diameter * sqrt(3)/6.0);

    /*Center coordinates for the second circle (top left)*/
    int c_x2 = (int)round((double)c_x - diameter/2.0);
    int c_y2 = (int)round((double)c_y + diameter * sqrt(3)/6.0);

    /*Center coordinates for the third circle (bottom)*/
    int c_x3 = c_x;
    int c_y3 = (int)round((double)c_y - diameter * sqrt(3)/3.0);

    printf("c_x1 = %d, c_y1 = %d \n c_x2 = %d, c_y2 = %d\n c_x3 = %d, c_y3 = %d\n",c_x1,c_y1,c_x2,c_y2,c_x3,c_y3);

    int offset_y = 0;
    int offset_x = diameter;
    int crit = 1 - diameter;

    while(offset_y <= offset_x)
    {

            /*OCTANT 5: circle 1*/
            check_pix(c_x1 - offset_x, c_y1 - offset_y);

            if (offset_y  < (diameter / 2.0)) {
                /*OCTANT 2 and 3: circle 3*/
                check_pix(c_x3 + offset_y, c_y3 + offset_x);
                check_pix(c_x3 - offset_y, c_y3 + offset_x);
            } else {
                /*OCTANT 6 and 7: circle 1 and 2 respectivly*/
                check_pix(c_x1 - offset_y, c_y1 - offset_x);
                check_pix(c_x2 + offset_y, c_y2 - offset_x);
            }

            /*OCTANT 8: circle 2*/
            check_pix(c_x2 + offset_x, c_y2 - offset_y);

            /*CRIT CALC*/
            offset_y = offset_y + 1;

            if (crit <= 0)
            {
                crit = crit + (2 * offset_y) + 1;
            } else
            {
                offset_x = offset_x - 1;
                crit = crit + (2 * (offset_y - offset_x)) + 1;
            }
	printf("CRIT: %d, OFF_Y, %d OFF_X %d\n", crit, offset_y, offset_x);
    }

}
