<!--
  Definition of the installation.SLES.xml -> installation.SLES4SAP.xml transformation.
  For now it simply copies all XML tags to the target file.
-->

<xsl:stylesheet version="1.0"
  xmlns:n="http://www.suse.com/1.0/yast2ns"
  xmlns:config="http://www.suse.com/1.0/configns"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.suse.com/1.0/yast2ns"
  exclude-result-prefixes="n"
>

<!--
Work around for the text domain
textdomain="control"
-->

<xsl:output method="xml" indent="yes"/>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

  <!-- keep empty <![CDATA[]]>, see https://stackoverflow.com/a/1364900 -->
  <xsl:template match="n:optional_default_patterns">
      <xsl:element name="optional_default_patterns">
          <xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
          <xsl:value-of select="text()" disable-output-escaping="yes"/>
          <xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
      </xsl:element>
  </xsl:template>

  <xsl:template xml:space="preserve" match="n:system_role[n:id='minimal_role']">
        <system_role>
        <id>suma_role</id>

        <!-- the rest is overlaid over the feature sections and values. -->
        <partitioning>
           <proposal>
             <lvm config:type="boolean">true</lvm>
             <encrypt config:type="boolean">false</encrypt>
             <windows_delete_mode>all</windows_delete_mode>
             <linux_delete_mode>all</linux_delete_mode>
             <other_delete_mode>all</other_delete_mode>
             <lvm_vg_strategy>use_available</lvm_vg_strategy>
           </proposal>

           <volumes config:type="list">
             <!-- The root filesystem -->
             <volume>
               <mount_point>/</mount_point>
               <!-- Enforce Btrfs for root by not offering any other option -->
               <fs_type>btrfs</fs_type>
               <desired_size>100GiB</desired_size>
	       <!--               <min_size>40GiB</min_size> -->
               <min_size>40GiB</min_size>
	       <max_size>100GiB</max_size>
               <!-- Always use snapshots, no matter what -->
               <snapshots config:type="boolean">true</snapshots>
               <snapshots_configurable config:type="boolean">false</snapshots_configurable>

               <btrfs_default_subvolume>@</btrfs_default_subvolume>
               <subvolumes config:type="list">
                 <subvolume>
             	<path>home</path>
                 </subvolume>
                 <subvolume>
             	<path>opt</path>
                 </subvolume>
                 <subvolume>
             	<path>root</path>
                 </subvolume>
                 <subvolume>
             	<path>srv</path>
                 </subvolume>
                 <subvolume>
             	<path>tmp</path>
                 </subvolume>
                 <subvolume>
             	<path>usr/local</path>
                 </subvolume>
                 <!-- unified var subvolume - https://lists.opensuse.org/opensuse-packaging/2017-11/msg00017.html -->
                 <subvolume>
             	<path>var</path>
             	<copy_on_write config:type="boolean">false</copy_on_write>
                 </subvolume>
                 <!-- architecture specific subvolumes -->

                 <subvolume>
             	<path>boot/grub2/i386-pc</path>
             	<archs>i386,x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/x86_64-efi</path>
             	<archs>x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/powerpc-ieee1275</path>
             	<archs>ppc,!board_powernv</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/x86_64-efi</path>
             	<archs>x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/s390x-emu</path>
             	<archs>s390</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/arm64-efi</path>
             	<archs>aarch64</archs>
                 </subvolume>
               </subvolumes>
             </volume>

             <!-- The swap volume -->
             <volume>
               <mount_point>swap</mount_point>
               <fs_type>swap</fs_type>
               <desired_size>2GiB</desired_size>
               <min_size>2GiB</min_size>
               <max_size>2GiB</max_size>
             </volume>

<!-- separate /var/spacewalk: 100 GiB - unlimited -->
            <volume>
	    <mount_point>/var/spacewalk</mount_point>
                <fs_type>xfs</fs_type>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">300 GiB</desired_size>
                <min_size config:type="disksize">100 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">300 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">4</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>

<!-- separate /var/lib/pgsql: 50 GiB - unlimited -->
            <volume>
	    <mount_point>/var/lib/pgsql</mount_point>
                <fs_type>xfs</fs_type>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">60 GiB</desired_size>
                <min_size config:type="disksize">50 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">60 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">3</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>
<!-- separate /var/cache: 4 GB - unlimited -->
	     <volume>
	     <mount_point>/var/cache</mount_point>
                <fs_type>xfs</fs_type>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">10 GiB</desired_size>
                <min_size config:type="disksize">4 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">10 GiB</max_size_lvm>
                <weight config:type="integer">20</weight>

                <disable_order config:type="integer">1</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>

<!-- separate /srv: 40 GiB - unlimited -->
            <volume>
	    <mount_point>/srv</mount_point>
                <fs_type>xfs</fs_type>

		<proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">80 GiB</desired_size>
                <min_size config:type="disksize">40 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">80 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">2</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>
           </volumes>
        </partitioning>
        <software>
          <default_patterns>base suma_server</default_patterns>
          <!-- this is comment in the style sheet not commented into result -->
          <xsl:comment>
          the cdata trick produces an empty string in the data
	  instead of omitting the key entirely
          </xsl:comment>			  
	  <xsl:element name="optional_default_patterns">
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[]]&gt;</xsl:text>
          </xsl:element>
        </software>
        </system_role>
  

        <system_role>
        <id>suma_retail_role</id>

        <!-- the rest is overlaid over the feature sections and values. -->
        <partitioning>
           <proposal>
             <lvm config:type="boolean">true</lvm>
             <encrypt config:type="boolean">false</encrypt>
             <windows_delete_mode>all</windows_delete_mode>
             <linux_delete_mode>all</linux_delete_mode>
             <other_delete_mode>all</other_delete_mode>
             <lvm_vg_strategy>use_available</lvm_vg_strategy>
           </proposal>

           <volumes config:type="list">
             <!-- The root filesystem -->
             <volume>
               <mount_point>/</mount_point>
               <!-- Enforce Btrfs for root by not offering any other option -->
               <fs_type>btrfs</fs_type>
               <desired_size>100GiB</desired_size>
	       <!--               <min_size>40GiB</min_size> -->
               <min_size>4GiB</min_size>
               <max_size>100GiB</max_size>
               <!-- Always use snapshots, no matter what -->
               <snapshots config:type="boolean">true</snapshots>
               <snapshots_configurable config:type="boolean">false</snapshots_configurable>

               <btrfs_default_subvolume>@</btrfs_default_subvolume>
               <subvolumes config:type="list">
                 <subvolume>
             	<path>home</path>
                 </subvolume>
                 <subvolume>
             	<path>opt</path>
                 </subvolume>
                 <subvolume>
             	<path>root</path>
                 </subvolume>
                 <subvolume>
             	<path>srv</path>
                 </subvolume>
                 <subvolume>
             	<path>tmp</path>
                 </subvolume>
                 <subvolume>
             	<path>usr/local</path>
                 </subvolume>
                 <!-- unified var subvolume - https://lists.opensuse.org/opensuse-packaging/2017-11/msg00017.html -->
                 <subvolume>
             	<path>var</path>
             	<copy_on_write config:type="boolean">false</copy_on_write>
                 </subvolume>
                 <!-- architecture specific subvolumes -->

                 <subvolume>
             	<path>boot/grub2/i386-pc</path>
             	<archs>i386,x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/x86_64-efi</path>
             	<archs>x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/powerpc-ieee1275</path>
             	<archs>ppc,!board_powernv</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/x86_64-efi</path>
             	<archs>x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/s390x-emu</path>
             	<archs>s390</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/arm64-efi</path>
             	<archs>aarch64</archs>
                 </subvolume>
               </subvolumes>
             </volume>

             <!-- The swap volume -->
             <volume>
               <mount_point>swap</mount_point>
               <fs_type>swap</fs_type>
               <desired_size>2GiB</desired_size>
               <min_size>2GiB</min_size>
               <max_size>2GiB</max_size>
             </volume>

<!-- separate /var/spacewalk: 100 GiB - unlimited -->
            <volume>
	    <mount_point>/var/spacewalk</mount_point>
                <fs_type>xfs</fs_type>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">300 GiB</desired_size>
                <min_size config:type="disksize">100 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">300 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">4</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>

<!-- separate /var/lib/pgsql: 50 GiB - unlimited -->
            <volume>
	    <mount_point>/var/lib/pgsql</mount_point>
                <fs_type>xfs</fs_type>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">60 GiB</desired_size>
                <min_size config:type="disksize">50 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">60 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">3</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>
<!-- separate /var/cache: 4 GB - unlimited -->
            <volume>
	     <mount_point>/var/cache</mount_point>
                <fs_type>xfs</fs_type>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">10 GiB</desired_size>
                <min_size config:type="disksize">4 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">10 GiB</max_size_lvm>
                <weight config:type="integer">20</weight>

                <disable_order config:type="integer">1</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>

<!-- separate /srv: 200 GiB - unlimited -->
            <volume>
	    <mount_point>/srv</mount_point>
                <fs_type>xfs</fs_type>

		<proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">300 GiB</desired_size>
                <min_size config:type="disksize">200 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">300 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">2</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>
           </volumes>
        </partitioning>
        <software>
          <default_patterns>base suma_server suma_retail</default_patterns>
          <!-- this is comment in the style sheet not commented into result -->
          <xsl:comment>
          the cdata trick produces an empty string in the data
	  instead of omitting the key entirely
          </xsl:comment>			  
	  <xsl:element name="optional_default_patterns">
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[]]&gt;</xsl:text>
          </xsl:element>
        </software>
      </system_role>
      <system_role>
        <id>suma_multidisc_role</id>

        <!-- the rest is overlaid over the feature sections and values. -->
        <partitioning>
           <proposal>
             <lvm config:type="boolean">true</lvm>
             <encrypt config:type="boolean">false</encrypt>
             <windows_delete_mode>all</windows_delete_mode>
             <linux_delete_mode>all</linux_delete_mode>
             <other_delete_mode>all</other_delete_mode>
             <lvm_vg_strategy>use_available</lvm_vg_strategy>
             <separate_vgs config:type="boolean">true</separate_vgs>
             <multidisk_first config:type="boolean">true</multidisk_first>
             <delete_resize_configurable config:type="boolean">false</delete_resize_configurable>
             <allocate_volume_mode config:type="symbol">device</allocate_volume_mode>
           </proposal>

           <volumes config:type="list">
             <!-- The root filesystem -->
             <volume>
               <mount_point>/</mount_point>
               <!-- Enforce Btrfs for root by not offering any other option -->
               <fs_type>btrfs</fs_type>
               <desired_size>100GiB</desired_size>
	       <!--               <min_size>40GiB</min_size> -->
               <min_size>40GiB</min_size>
	       <max_size>100GiB</max_size>
               <!-- Always use snapshots, no matter what -->
               <snapshots config:type="boolean">true</snapshots>
               <snapshots_configurable config:type="boolean">false</snapshots_configurable>

               <btrfs_default_subvolume>@</btrfs_default_subvolume>
               <subvolumes config:type="list">
                 <subvolume>
             	<path>home</path>
                 </subvolume>
                 <subvolume>
             	<path>opt</path>
                 </subvolume>
                 <subvolume>
             	<path>root</path>
                 </subvolume>
                 <subvolume>
             	<path>srv</path>
                 </subvolume>
                 <subvolume>
             	<path>tmp</path>
                 </subvolume>
                 <subvolume>
             	<path>usr/local</path>
                 </subvolume>
                 <!-- unified var subvolume - https://lists.opensuse.org/opensuse-packaging/2017-11/msg00017.html -->
                 <subvolume>
             	<path>var</path>
             	<copy_on_write config:type="boolean">false</copy_on_write>
                 </subvolume>
                 <!-- architecture specific subvolumes -->

                 <subvolume>
             	<path>boot/grub2/i386-pc</path>
             	<archs>i386,x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/x86_64-efi</path>
             	<archs>x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/powerpc-ieee1275</path>
             	<archs>ppc,!board_powernv</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/x86_64-efi</path>
             	<archs>x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/s390x-emu</path>
             	<archs>s390</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/arm64-efi</path>
             	<archs>aarch64</archs>
                 </subvolume>
               </subvolumes>
             </volume>

             <!-- The swap volume -->
             <volume>
               <mount_point>swap</mount_point>
               <fs_type>swap</fs_type>
               <desired_size>2GiB</desired_size>
               <min_size>2GiB</min_size>
               <max_size>2GiB</max_size>
             </volume>

<!-- separate /var/spacewalk: 100 GiB - unlimited -->
            <volume>
	    <mount_point>/var/spacewalk</mount_point>
	        <fs_type>xfs</fs_type>
	        <separate_vg_name>spacewalk</separate_vg_name>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">300 GiB</desired_size>
                <min_size config:type="disksize">100 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">300 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">4</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>

<!-- separate /var/lib/pgsql: 50 GiB - unlimited -->
            <volume>
	    <mount_point>/var/lib/pgsql</mount_point>
                <fs_type>xfs</fs_type>
	        <separate_vg_name>pgsql</separate_vg_name>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">60 GiB</desired_size>
                <min_size config:type="disksize">50 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">60 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">3</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>
<!-- separate /var/cache: 4 GB - unlimited -->
	     <volume>
	     <mount_point>/var/cache</mount_point>
                <fs_type>xfs</fs_type>
	        <separate_vg_name>system_cache</separate_vg_name>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">10 GiB</desired_size>
                <min_size config:type="disksize">4 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">10 GiB</max_size_lvm>
                <weight config:type="integer">20</weight>

                <disable_order config:type="integer">1</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>

<!-- separate /srv: 40 GiB - unlimited -->
            <volume>
	    <mount_point>/srv</mount_point>
                <fs_type>xfs</fs_type>
	        <separate_vg_name>srv</separate_vg_name>

		<proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">80 GiB</desired_size>
                <min_size config:type="disksize">40 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">80 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">2</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>
           </volumes>
        </partitioning>
        <software>
          <default_patterns>base suma_server</default_patterns>
          <!-- this is comment in the style sheet not commented into result -->
          <xsl:comment>
          the cdata trick produces an empty string in the data
	  instead of omitting the key entirely
          </xsl:comment>			  
	  <xsl:element name="optional_default_patterns">
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[]]&gt;</xsl:text>
          </xsl:element>
        </software>
      </system_role>
  

      <system_role>
        <id>suma_retail_multidisc_role</id>

        <!-- the rest is overlaid over the feature sections and values. -->
        <partitioning>
           <proposal>
             <lvm config:type="boolean">true</lvm>
             <encrypt config:type="boolean">false</encrypt>
             <windows_delete_mode>all</windows_delete_mode>
             <linux_delete_mode>all</linux_delete_mode>
             <other_delete_mode>all</other_delete_mode>
             <lvm_vg_strategy>use_available</lvm_vg_strategy>
             <separate_vgs config:type="boolean">true</separate_vgs>
             <multidisk_first config:type="boolean">true</multidisk_first>
             <delete_resize_configurable config:type="boolean">false</delete_resize_configurable>
             <allocate_volume_mode config:type="symbol">device</allocate_volume_mode>
            </proposal>

           <volumes config:type="list">
             <!-- The root filesystem -->
             <volume>
               <mount_point>/</mount_point>
               <!-- Enforce Btrfs for root by not offering any other option -->
               <fs_type>btrfs</fs_type>
               <desired_size>100GiB</desired_size>
	       <!--               <min_size>40GiB</min_size> -->
               <min_size>4GiB</min_size>
               <max_size>100GiB</max_size>
               <!-- Always use snapshots, no matter what -->
               <snapshots config:type="boolean">true</snapshots>
               <snapshots_configurable config:type="boolean">false</snapshots_configurable>

               <btrfs_default_subvolume>@</btrfs_default_subvolume>
               <subvolumes config:type="list">
                 <subvolume>
             	<path>home</path>
                 </subvolume>
                 <subvolume>
             	<path>opt</path>
                 </subvolume>
                 <subvolume>
             	<path>root</path>
                 </subvolume>
                 <subvolume>
             	<path>srv</path>
                 </subvolume>
                 <subvolume>
             	<path>tmp</path>
                 </subvolume>
                 <subvolume>
             	<path>usr/local</path>
                 </subvolume>
                 <!-- unified var subvolume - https://lists.opensuse.org/opensuse-packaging/2017-11/msg00017.html -->
                 <subvolume>
             	<path>var</path>
             	<copy_on_write config:type="boolean">false</copy_on_write>
                 </subvolume>
                 <!-- architecture specific subvolumes -->

                 <subvolume>
             	<path>boot/grub2/i386-pc</path>
             	<archs>i386,x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/x86_64-efi</path>
             	<archs>x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/powerpc-ieee1275</path>
             	<archs>ppc,!board_powernv</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/x86_64-efi</path>
             	<archs>x86_64</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/s390x-emu</path>
             	<archs>s390</archs>
                 </subvolume>
                 <subvolume>
             	<path>boot/grub2/arm64-efi</path>
             	<archs>aarch64</archs>
                 </subvolume>
               </subvolumes>
             </volume>

             <!-- The swap volume -->
             <volume>
               <mount_point>swap</mount_point>
               <fs_type>swap</fs_type>
               <desired_size>2GiB</desired_size>
               <min_size>2GiB</min_size>
               <max_size>2GiB</max_size>
             </volume>

<!-- separate /var/spacewalk: 100 GiB - unlimited -->
            <volume>
	    <mount_point>/var/spacewalk</mount_point>
                <fs_type>xfs</fs_type>
	        <separate_vg_name>spacewalk</separate_vg_name>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">300 GiB</desired_size>
                <min_size config:type="disksize">100 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">300 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">4</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>

<!-- separate /var/lib/pgsql: 50 GiB - unlimited -->
            <volume>
	    <mount_point>/var/lib/pgsql</mount_point>
                <fs_type>xfs</fs_type>
	        <separate_vg_name>pgsql</separate_vg_name>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">60 GiB</desired_size>
                <min_size config:type="disksize">50 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">60 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">3</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>
<!-- separate /var/cache: 4 GB - unlimited -->
            <volume>
	     <mount_point>/var/cache</mount_point>
                <fs_type>xfs</fs_type>
	        <separate_vg_name>system_cache</separate_vg_name>

                <proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">10 GiB</desired_size>
                <min_size config:type="disksize">4 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">10 GiB</max_size_lvm>
                <weight config:type="integer">20</weight>

                <disable_order config:type="integer">1</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>

<!-- separate /srv: 200 GiB - unlimited -->
            <volume>
	    <mount_point>/srv</mount_point>
                <fs_type>xfs</fs_type>
	        <separate_vg_name>srv</separate_vg_name>

		<proposed_configurable config:type="boolean">true</proposed_configurable>
		<proposed config:type="boolean">true</proposed>

                <desired_size config:type="disksize">300 GiB</desired_size>
                <min_size config:type="disksize">200 GiB</min_size>
                <max_size config:type="disksize">unlimited</max_size>
                <max_size_lvm config:type="disksize">300 GiB</max_size_lvm>
                <weight config:type="integer">40</weight>

                <disable_order config:type="integer">2</disable_order>

                <!-- if this volume is disabled we want "/" to increase -->
                <fallback_for_desired_size>/</fallback_for_desired_size>
                <fallback_for_max_size>/</fallback_for_max_size>
                <fallback_for_max_size_lvm>/</fallback_for_max_size_lvm>
                <fallback_for_weight>/</fallback_for_weight>
             </volume>
           </volumes>
        </partitioning>
        <software>
          <default_patterns>base suma_server suma_retail</default_patterns>
          <!-- this is comment in the style sheet not commented into result -->
          <xsl:comment>
          the cdata trick produces an empty string in the data
	  instead of omitting the key entirely
          </xsl:comment>			  
	  <xsl:element name="optional_default_patterns">
            <xsl:text disable-output-escaping="yes">&lt;![CDATA[]]&gt;</xsl:text>
          </xsl:element>
        </software>
      </system_role>
      <xsl:copy>
        <xsl:apply-templates/>
      </xsl:copy>
   </xsl:template>

  <xsl:template xml:space="preserve" match="n:minimal_role">
      <suma_role>
          <!-- TRANSLATORS: a label for a system role -->
	      <label>SUSE Manager Server (sigle disk)</label>
      </suma_role>
      <suma_role_description>
	      <label>• Manager Server pattern
• LVM-based partition layout on a single disk</label>
      </suma_role_description>
      <suma_retail_role>
          <!-- TRANSLATORS: a label for a system role -->
	      <label>SUSE Manager for Retail Server (sigle disk)</label>
      </suma_retail_role>
      <suma_retail_role_description>
	      <label>• Retail Server Pattern
• Larger volume for terminal images</label>
      </suma_retail_role_description>
      <suma_multidisc_role>
          <!-- TRANSLATORS: a label for a system role -->
	      <label>SUSE Manager Server (multiple disks)</label>
      </suma_multidisc_role>
      <suma_multidisc_role_description>
	      <label>• Manager Server pattern
• LVM-based partition layout on up to 5 disks</label>
      </suma_multidisc_role_description>
      <suma_retail_multidisc_role>
          <!-- TRANSLATORS: a label for a system role -->
	      <label>SUSE Manager for Retail Server (multiple disks)</label>
      </suma_retail_multidisc_role>
      <suma_retail_multidisc_role_description>
	      <label>• Retail Server Pattern
• Larger volume for terminal images</label>
      </suma_retail_multidisc_role_description>
      <xsl:copy>
        <xsl:apply-templates/>
      </xsl:copy>
  </xsl:template>

  <!-- add a new "software/default_modules" section just after the "textdomain" -->
  <xsl:template xml:space="preserve" match="n:textdomain">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
    <software>
      <xsl:comment> the default preselected modules in offline installation </xsl:comment>
      <default_modules config:type="list">
        <default_module>sle-module-basesystem</default_module>
        <default_module>sle-module-python2</default_module>
        <default_module>sle-module-server-applications</default_module>
        <default_module>sle-module-web-scripting</default_module>
      </default_modules>
    </software>
  </xsl:template>

</xsl:stylesheet>
