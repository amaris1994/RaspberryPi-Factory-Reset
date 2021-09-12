#!/bin/bash


usage()
{
cat << EOF
usage: $0 options
This script is run to create a Pi OS image with factory reset utility
OPTIONS:
   -i     The source image.
          This should be an unzipped filesystem image with 2 partitions:
          /boot : following rPi standards, such as having a /boot/cmdline.txt
          / : should be the filesystem that is booted

          generally its best to put this file in the current working directory

   -l     A lite image
          this should be an unzipped img containing 2 partitions
          usually this will be the lite image corresponding to a desktop
          image
          the script will use this image to create the recovery partition
          the lite image is usally much smaller than the rootfs partition on
          the source image to slim down the resulting recovery image size

   -s     process in steps, outputting useful information and waiting for
          user to confirm before proceeding

   -c     just do cleaup and exit.
          requires i option to find disks to cleanup

EOF
}

OPT_USE_LITE=""   # is a lite image is provided?


OPTION_CLEANUP_PRE=""       # before starting, cleanup any previous runs
OPTION_CLEANUP_POST=""      # after complete, cleanup loopback and mounts
OPTION_BASE=""              # path to the base image
OPTION_LITE=""              # path to the lite image
OPTION_STEPS=""             # pause after each step
OPTION_DO_MAIN=""           # unset this to not do the main section

# these are used to override different sections
# mostly for debugging/development
OPT_DO_CHECKS=""            # whether to do file and package checks
OPT_GET_PART_FOR_ORIG=""   
OPT_GET_PART_FOR_LITE=""    # get the lite image partition sizes
OPT_MAKE_UUIDS=""
OPT_MOUNT_ORIG=""
OPT_MOUNT_COPY=""
OPT_COPY_TO_COPY=""
OPT_FIX_ROOTFS_FSTAB=""
OPT_FIX_RESIZE_SCRIPT=""
OPT_MAKE_RECOVERY_ZIP=""
OPT_MOUNT_LITE=""
OPT_GET_RECOVERY_SIZES=""
OPT_MOUNT_RESTORE=""
OPT_COPY_TO_RESTORE=""

OPT_FIX_CMDLINE_TXT=""
OPT_MAKE_RESTORE_SCRIPT=""
OPT_MAKE_RECOVERY_SCRIPT=""

while getopts “arhcsi:l:p:ve” OPTION
do
     case $OPTION in
         h)
           # echo "in help"
           usage
           exit 1
        ;;
         a)
            
            OPTION_CLEANUP_PRE=1
            OPT_DO_CHECKS="1"
            OPT_GET_PART_FOR_ORIG="1"
            OPT_MAKE_UUIDS="1"
            OPT_MOUNT_ORIG="1"
            OPT_MOUNT_COPY="1"
            OPT_COPY_TO_COPY="1"
            OPT_FIX_ROOTFS_FSTAB="1"
            OPT_FIX_RESIZE_SCRIPT="1"
            OPT_MAKE_RECOVERY_ZIP="1"
            OPT_GET_RECOVERY_SIZES="1"
            OPT_MOUNT_RESTORE="1"
            OPT_COPY_TO_RESTORE="1"

            OPT_FIX_CMDLINE_TXT="1"
            OPT_MAKE_RESTORE_SCRIPT="1"
            OPT_MAKE_RECOVERY_SCRIPT="1"

            #
            OPT_GET_PART_FOR_LITE="1"
            OPT_MOUNT_LITE="1"

            OPTION_CLEANUP_POST="1"

          ;;
         c)
             # vvv=$OPTARG
             OPTION_CLEANUP_PRE=1
             OPTION_DO_MAIN=""
             OPTION_CLEANUP_POST=""
          ;;
         e)
             # vvv=$OPTARG
             OPTION_CLEANUP_POST=0
          ;;
         s)
             # vvv=$OPTARG
             OPTION_STEPS=1
          ;;
         i)
             # vvv=$OPTARG
             # echo "processing i option"
             OPTION_BASE=${OPTARG}
          ;;
         l)
            # vvv=$OPTARG
            # echo "processing l option"
            OPTION_LITE=${OPTARG}
            OPT_USE_LITE=1
            OPT_GET_PART_FOR_LITE="1"
            OPT_MOUNT_LITE="1"
         ;;
         ?)
            # echo "in usage"
            usage
            exit
          ;;
     esac
done

shift $((OPTIND-1))
