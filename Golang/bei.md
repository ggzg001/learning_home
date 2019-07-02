1. 染色体是细胞核中载有遗传信息（基因）的物质，在显微镜下呈圆柱状或杆状，主要由DNA和蛋白质组成

2. 带有遗传讯息的DNA片段称为基因,s其他的DNA序列，有些直接以自身构造发挥作用，有些则参与调控遗传讯息的表 现。

3. 一条染色体上可以有成千上万个基因。细胞内所有染色体称为染色体组

4. 外显子：基因组[DNA](https://www.baidu.com/s?wd=DNA&tn=SE_PcZhidaonwhc_ngpagmjz&rsv_dl=gh_pc_zhidao)中出现在成熟[RNA](https://www.baidu.com/s?wd=RNA&tn=SE_PcZhidaonwhc_ngpagmjz&rsv_dl=gh_pc_zhidao)分子上的序列.外显子被内含子隔开,转录后经过加工被连接在一起,生成成熟的[RNA](https://www.baidu.com/s?wd=RNA&tn=SE_PcZhidaonwhc_ngpagmjz&rsv_dl=gh_pc_zhidao)分子.DNA 通过转录形成前体RNA，然后剪接成成熟的mRNA。

5. DNA测序：分析特定DNA片段的碱基序列

### 从DNA到蛋白质

1. 细胞通过RNA来制造蛋白

2. RNA分为rRNA(装配工厂)、tRNA(运输氨基酸)和mRNA(精确地指导哪种氨基酸被组装到多肽中)

3. 中心法则：信息从DNA传递至基因的一个RNA拷贝，然后RNA再指导氨基酸链的序列装配

4. DNA->RNA->蛋白质，两个过程分别叫做转录和翻译，合在一起就是表示表达。

5. DNA生成蛋白质是靠外显子，在基因中不是连续存在的，是被内含子分隔的，从DNA到mRNA的过程其实就是剪切内显子只保留外显子的过程。

    

   ### 转录组一级分析

   1. 原始数据质控：判断数据是否可用，然后把一些数据trim，再通过FastQc检测trim的数据是否可用，结果还是一个fastq文件。这一步会附带生成一些图片
   2. 基因组比对：把原始数据和真实的数据进行比对，看看哪些基因片段是人类目前已知的，得到对比结果bam文件
   3. 基因表达量鉴定：得到基因片段的某个点对不同基因的表达结果

   

   ### RNA突变检测

   RNA是单链的，比起双链的DNA更容易发生突变。RNA的突变检测是把RNA和正常的RNA进行比较

   

   ## ATCG

   基因是一篇文章，但是里面的汉字只有4个就是ATGC，文章长短不同和文字不同，造成文章的不同，结果造成生物的多样性。

   基因是DNA的片段，每个片段都含有不同的信息，DNA片段的不同信息就是通过ATGC的顺序不同来表示的。
   比如，某段DNA的碱基序列为：
   5ˊ-AACGTTACGTCC-3ˊ
   3ˊ-TTGCAATGCAGG-5ˊ
   另一段为：
   5ˊ-TACGAAATGTCT-3ˊ
   3ˊ-ATGCTTTACAGA-5ˊ
   就不同了

   

   ## fragements

   fragements就是打成的片段，测序就是测这些fragements，测出的结果就是reads

   ## reads

   测序平台产生的序列

   

   红框位置就是数据文件的头信息（#表示），主要有CHROM、POS、ID、REF、ALT、QUAL、FILTER、INFO、FORAMT、SAMPLE【前8列必须要有】

   - CHROM：变异位点从参考序列哪个**染色体**区段上找出来的

   - POS：异位点相对于参考基因组所在的最左端**位置** （属于1-坐标系统：从1开始计数）【如果是**InDel**的情况，那么这个数值对应**InDel的第一个碱基**位置】

     > 1-based coordinate system ：序列的第一个碱基设为数字1，如SAM,VCF,GFF,wiggle格式0-based coordinate system ：序列的第一个碱基设为数字0，如BAM, BCFv2, BED, PSL格式

   - ID：变异位点**名称**（对应dbSNP数据库中的ID；若没有，则默认用`.` 表示他是一个novel variant）

   - REF：**参考序列**该位置碱基类型及个数

   - ALT：该位置**变异**的碱基类型及个数【多个用逗号分隔；对于SNP是单个碱基的改变；对于InDel是碱基数量的改变】

   - QUAL：变异位点**质量**值（与测序数据一样也是用Phred格式表示）Phred值= -10 * log(1-P), P是变异位点存在的概率。值越大，此位点保持原状的概率越低，越可能发生变异。但是这个值随着数据量增大而变大，并非十分准确

   - FILTER：下一个位点是否要被**过滤**掉，如果显示PASS，说明下一个位点和参考序列一致，那么这个位点有更大可能性为变异位点

   - INFO：结合描述理解有关该位点的**额外信息** 【包含信息最多，形式为Tag=Value, 分号分隔】

   - FORMAT：变异位点**格式**

   - SMAPLE：使用的样本名称，由bam文件中@RG的SM标签决定

   

   ## 测序深度

   测序得到的总碱基数与待测基因组大小的比值，基因大小是2M，测序深度是10X, 那么获得的总数据量就是20M

   覆盖度：测序获得的序列占整个基因组的比例

   

   ## VCF格式

   **Variant Call Format，它是**存储变异位点的标准格式。

   VCF使用UTF-8编码，有两大部分：一部分是注释信息（以##开头），一部分是具体突变信息

   

   将测序的数据分为`双端测序`和`单端测序`双端测序的数据含有两个fastq格式的文件，单端测序的数据只有一个fastq格式的文件

   

   





