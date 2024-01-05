# makefile fragment to define the macros java_default_version,
# java{,8,...,17}_architectures

java17_architectures = \
		alpha amd64 arm64 armel armhf i386 \
		ia64 loong64 m68k mipsel mips64el \
		powerpc ppc64 ppc64el \
		riscv64 s390x sh4 sparc64 x32
java11_architectures = $(java17_architectures) \
		mips
java8_architectures = $(java11_architectures)
java_architectures = $(java8_architectures)

java_default_architectures = $(java8_architectures)

java_unsupported_architectures = hppa hurd-i386 kfreebsd-amd64 kfreebsd-i386 hurd-i386 powerpcspe s390 sparc

java_dependency = $(strip $(1) [$(foreach a,$(filter-out $(java_default_architectures), $(java_unsupported_architectures)),!$(a))])


_java_host_arch := $(if $(DEB_HOST_ARCH),$(DEB_HOST_ARCH),$(shell dpkg-architecture -qDEB_HOST_ARCH))
ifneq (,$(filter $(_java_host_arch),$(java17_architectures)))
  java_default_version = 17
else ifneq (,$(filter $(_java_host_arch),$(java11_architectures)))
  java_default_version = 11
else ifneq (,$(filter $(_java_host_arch),$(java8_architectures)))
  java_default_version = 8
endif

# The minimum source/target compatibility level supported by the default JDK
# This variable can be used by build scripts invoking directly javac with
# the -source, -target or --release options.
ifneq (,$(filter $(_java_host_arch),$(java17_architectures)))
  java_compat_level = 7
else
  java_compat_level = 6
endif

# jvm_archdir is the directory for architecture specific files / libraries
# in <JAVA_HOME>/jre/lib/<jvm_archdir> or <JAVA_HOME>/lib/<jvm_archdir>
# jvm_archpath is the relative path of jvm_archdir in JAVA_HOME.

_java_host_cpu := $(if $(DEB_HOST_ARCH_CPU),$(DEB_HOST_ARCH_CPU),$(shell dpkg-architecture -qDEB_HOST_ARCH_CPU))
jvm_archdir_map = \
	alpha=alpha armel=arm armhf=arm arm64=aarch64 amd64=amd64 \
	i386=i386 loong64=loong64 m68k=m68k mips=mips mipsel=mipsel mips64=mips64 mips64el=mips64el \
	powerpc=ppc ppc64=ppc64 ppc64el=ppc64le riscv64=riscv64 \
	sparc64=sparc64 sh4=sh s390x=s390x ia64=ia64 x32=x32

jvm_archdir := \
	$(strip $(patsubst $(_java_host_cpu)=%, %, $(filter $(_java_host_cpu)=%, $(jvm_archdir_map))))

ifneq (,$(filter $(java_default_version), 8))
  jvm_archpath := jre/lib/$(jvm_archdir)
else
  jvm_archpath := lib/$(jvm_archdir)
endif

_jvm_osinclude = linux

jvm_includes = \
	-I/usr/lib/jvm/java-$(java_default_version)-openjdk-$(_java_host_arch)/include \
	-I/usr/lib/jvm/java-$(java_default_version)-openjdk-$(_java_host_arch)/include/$(_jvm_osinclude)
