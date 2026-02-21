PART_NAME=firmware
REQUIRE_IMAGE_METADATA=1

RAMFS_COPY_BIN='fw_printenv fw_setenv head'
RAMFS_COPY_DATA='/etc/fw_env.config /var/lock/fw_printenv.lock'

jrouter_initial_setup() {
	[ "$(rootfs_type)" = "tmpfs" ] || return 0
	fw_setenv --script - << 'EOF'
mtdparts=mtdparts=nand0:0xE100000@0x1700000(rootfs)
bootcmd=ubi part rootfs; ubi read 0x44000000 kernel; bootm 0x44000000
EOF
	fw_setenv bootargs
}

platform_check_image() {
	return 0;
}

platform_pre_upgrade() {
	case "$(board_name)" in
	jrouter,6x11)
		jrouter_initial_setup
		;;
	esac
}

platform_do_upgrade() {
	case "$(board_name)" in
	8devices,kiwi-dvk)
		CI_KERNPART="0:HLOS"
		CI_ROOTPART="rootfs"
		emmc_do_upgrade "$1"
		;;
	jrouter,6x11)
		CI_UBIPART="rootfs"
		nand_do_upgrade "$1"
		;;
	*)
		default_do_upgrade "$1"
		;;
	esac
}

platform_copy_config() {
	case "$(board_name)" in
	8devices,kiwi-dvk)
		emmc_copy_config
		;;
	esac
}
