pkg_name=apache-tomcat
pkg_origin=billmeyer
pkg_version=8.5.3
pkg_maintainer="Bill Meyer <bill@chef.io>"
pkg_license=('Apache-2.0')
pkg_source=http://apache.mirrors.pair.com/tomcat/tomcat-8/v${pkg_version}/bin/${pkg_name}-${pkg_version}.tar.gz
pkg_shasum=d70eb2ef9d3c265cd6892bd21b7e56f36162e68fdf4323274cf24045f6d865fc
pkg_deps=(core/jdk8 core/curl core/less)
pkg_expose=(8080 8443)

#pkg_svc_run="JAVA_HOME=$(hab pkg path core/jdk8); tc/bin/catalina.sh run"
pkg_svc_user="root"

# There is no default implementation of this callback. You can use it to execute any 
# arbitrary commands before anything else happens.
do_begin() {
  build_line "do_begin() called"
  do_default_begin
}

# The default implementation is that the software specified in $pkg_source is downloaded, 
# checksum-verified, and placed in $HAB_CACHE_SRC_PATH/$pkg_filename, which resolves to a path 
# like /hab/cache/src/filename.tar.gz. You should override this behavior if you need to change 
# how your binary source is downloaded, if you are not downloading any source code at all, or 
# if your are cloning from git. If you do clone a repo from git, you must override do_verify() 
# to return 0.

do_download() {
  build_line "do_download() called"
  do_default_download

  # downloading from bitbucket with wget results in a 403.
  # So then we implement our own `do_download` with `curl`.
  pushd "$HAB_CACHE_SRC_PATH" > /dev/null
  if [[ -f $pkg_filename ]]; then
    build_line "Found previous file '${pkg_filename}', attempting to re-use"
    if verify_file "$pkg_filename $pkg_shasum"; then
      build_line "Using cached and verified '${pkg_filename}'"
      return 0
    else
      build_line "Clearing previous '${pkg_filename}' and re-attempting download"
      rm -fv "$pkg_filename"
    fi
  fi

  build_line "Downloading '${pkg_source}' to '${pkg_filename}' with curl"
  curl -L -O $pkg_source
  build_line "Downloaded '${pkg_filename}'";
  popd > /dev/null
}

# The default implementation tries to verify the checksum specified in the plan against the 
# computed checksum after downloading the source tarball to disk. If the specified checksum 
# doesn't match the computed checksum, then an error and a message specifying the mismatch 
# will be printed to stderr. You should not need to override this behavior unless your package
# does not download any files.

do_verify() {
  build_line "do_verify() called"
  do_default_verify
}

# The default implementation removes the HAB_CACHE_SRC_PATH/$pkg_dirname folder in case there
# was a previously-built version of your package installed on disk. This ensures you start 
# with a clean build environment.

do_clean() {
  build_line "do_clean() called"
  do_default_clean

}

# The default implementation extracts your tarball source file into HAB_CACHE_SRC_PATH. The 
# supported archives are: .tar, .tar.bz2, .tar.gz, .tar.xz, .rar, .zip, .Z, .7z. If the file 
# archive could not be found or was not supported, then a message will be printed to stderr 
# with additional information.

do_unpack() {
  build_line "do_unpack() called"
  #do_default_unpack

  local source_dir=$HAB_CACHE_SRC_PATH/${pkg_name}-${pkg_version}
  local unpack_file="$HAB_CACHE_SRC_PATH/$pkg_filename"

  mkdir "$source_dir"
  pushd "$source_dir" >/dev/null
  tar xz --strip-components=1 -f "$unpack_file"

  popd > /dev/null
  return 0
}

# There is no default implementation of this callback. At this point in the build process, 
# the tarball source has been downloaded, unpacked, and the build environment variables have
# been set, so you can use this callback to perform any actions before the package starts 
# building, such as exporting variables, adding symlinks, and so on.
do_prepare() {
  build_line "do_prepare() called"
  do_default_prepare
}

# The default implementation is to update the prefix path for the configure script to 
# use $pkg_prefix and then run make to compile the downloaded source. This means the 
# script in the default implementation does ./configure --prefix=$pkg_prefix && make. You 
# should override this behavior if you have additional configuration changes to make or 
# other software to build and install as part of building your package.
do_build() {
  build_line "do_build() called"
  #do_default_build
    return 0
}

# The default implementation is to run make install on the source files and place the compiled 
# binaries or libraries in HAB_CACHE_SRC_PATH/$pkg_dirname, which resolves to a path like 
# /hab/cache/src/packagename-version/. It uses this location because of do_build() using the 
# --prefix option when calling the configure script. You should override this behavior if you
# need to perform custom installation steps, such as copying files from HAB_CACHE_SRC_PATH 
# to specific directories in your package, or installing pre-built binaries into your package.
do_install() {
  build_line "do_install() called"
  #do_default_install

    build_line "Performing install"
    mkdir -p "${pkg_prefix}/tc"
    cp -vR ./* "${pkg_prefix}/tc"
}

# The default implementation is to strip any binaries in $pkg_prefix of their debugging 
# symbols. You should override this behavior if you want to change how the binaries are 
# stripped, which additional binaries located in subdirectories might also need to be stripped, 
# or whether you do not want the binaries stripped at all.
do_strip() {
  build_line "do_strip() called"
  do_default_strip
}

# There is no default implementation of this callback. This is called after the package 
# has been built and installed. You can use this callback to remove any temporary files 
# or perform other post-install clean-up actions.
do_end() {
  build_line "do_end() called"
  do_default_end
}
