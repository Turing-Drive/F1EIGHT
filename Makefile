.PHONY: default prepare build launch clean
SHELL := /bin/bash

default:
	@echo 'make prepare'
	@echo '    Install required dependencies for this project.'
	@echo
	@echo 'make build'
	@echo '    Build this project.'
	@echo
	@echo 'make clean'
	@echo '    Clean up built binaries.'

pull:
	git submodule update --init --recursive

prepare:
	source /opt/ros/humble/setup.sh && \
	rosdep update --rosdistro=humble && \
	rosdep install -y --from-paths src --ignore-src -r

build:
	source /opt/ros/humble/setup.bash && \
	colcon build \
		--merge-install \
		--symlink-install \
		--cmake-args -DCMAKE_BUILD_TYPE=Release \

build_cross:
	$(MAKE) -C docker build
	docker run \
		-it --rm \
		--net=host \
		--runtime nvidia \
		-e DISPLAY=$$DISPLAY \
		-v /tmp/.X11-unix/:/tmp/.X11-unix \
		-v $$PWD:/home/jetson/host_repo \
		f1eighth \
		./build.sh /home/jetson/host_repo /home/jetson/F1EIGHTH


launch:
	source install/setup.bash && \
	ros2 launch launch/f1eighth.launch.yaml

clean:
	@while true; do \
		read -p 'Are you sure to clean up? (yes/no) ' yn; \
		case $$yn in \
			yes ) rm -rf build install log; break;; \
			no ) break;; \
			* ) echo 'Please enter yes or no.';; \
		esac \
	done
