

cpu usage
==========

echo $((100 - $(vmstat 1 2 | tail -1 | awk '{print $15}')))%

ram usage
=================

free | awk '/Mem:/ {printf("%.0f%\n", ($3/$2)*100)}'


disk usage
================

df -h / | awk 'NR==2 {print $5}'


network usage
==============
sudo apt install ifstat

ifstat (copy few line)



