
require 'sequel'
require 'json'

db_name = ''
user = ''
pass = ''
host = ''
port = ''

DB = Sequel.postgres(db_name, user, pass, host, port)

# sample json from ganetti:
s_json = '{"disk_usage": 10368, "oper_vcpus": 2, "serial_no": 25, "ctime": 1299198743.413559, "hvparams": {"spice_password_file": "", "spice_use_tls": false, "spice_use_vdagent": true, "nic_type": "paravirtual", "vnc_bind_address": "0.0.0.0", "cdrom2_image_path": "", "usb_mouse": "", "spice_streaming_video": "", "use_chroot": false, "spice_tls_ciphers": "HIGH:-DES:-3DES:-EXPORT:-ADH", "migration_downtime": 40, "floppy_image_path": "", "security_model": "pool", "cdrom_image_path": "", "spice_ip_version": 0, "vhost_net": false, "cpu_mask": "all", "disk_cache": "default", "kernel_path": "/boot/guest/vmlinuz-x86_64-hardened-mod", "vnc_x509_path": "", "spice_jpeg_wan_compression": "", "vnc_tls": false, "cdrom_disk_type": "", "use_localtime": false, "security_domain": "", "serial_console": false, "spice_bind": "", "spice_zlib_glz_wan_compression": "", "kvm_flag": "", "vnc_password_file": "", "disk_type": "paravirtual", "vnc_x509_verify": false, "spice_image_compression": "", "spice_playback_compression": true, "kernel_args": "ro", "root_path": "/dev/vda2", "initrd_path": "", "acpi": true, "keymap": "", "boot_order": "disk", "mem_path": "", "reboot_behavior": "reboot"}, "oper_state": true, "disk_template": "drbd", "mtime": 1400533546.8665459, "nic.modes": ["bridged"], "oper_ram": 1024, "pnode": "gprod6.osuosl.bak", "nic.bridges": ["br113"], "status": "running", "custom_hvparams": {"kernel_path": "/boot/guest/vmlinuz-x86_64-hardened-mod"}, "tags": ["gwm:owner:27"], "snodes": ["gprod1.osuosl.bak"], "nic.macs": ["aa:00:00:75:4f:0a"], "nic.ips": [null], "network_port": 11377, "name": "alembic-java.osuosl.org", "custom_beparams": {"minmem": 1024, "maxmem": 1024}, "custom_nicparams": [{"link": "br113"}], "uuid": "b6e3dce0-93dc-44d8-9405-71cc64fd6bd3", "disk.sizes": [10240], "admin_state": "up", "nic.links": ["br113"], "os": "image+gentoo-hardened-cf", "beparams": {"auto_balance": true, "vcpus": 2, "spindle_use": 1, "memory": 1024, "minmem": 1024, "always_failover": false, "maxmem": 1024}}'

sample = JSON.parse(s_json)
# puts sample

sample.each do |k, v|
  case v.class.to_s
  when "Fixnum"
    type = "int"
  when "Float"
    type = 'float'
  when "Hash"
    type = 'json'
  when 'TrueClass'
    type = 'boolean'
  when 'Array'
    type = 'text[]'
  else
    type = v.class.to_s
  end

  puts k.to_s + " " + type.to_s
end
