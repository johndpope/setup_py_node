#!/bin/sh
sudo apt-get -y update

#install OS requirement
sudo apt install -y gcc htop traceroute

#create mounting point
mkdir /home/ubuntu/sharedata
#install nfs client
sudo apt-get install -y nfs-common
#configure nfs
sudo sh -c 'echo "10.0.0.3:/home/ubuntu/sharedata /home/ubuntu/sharedata nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0" >> /etc/fstab'
sudo mount -a

#download anaconda
wget https://repo.continuum.io/archive/Anaconda2-5.0.0.1-Linux-x86_64.sh -P /home/ubuntu
#install Anaconda2 locally/remotely
#bash /home/ubuntu/Anaconda2-5.0.0.1-Linux-x86_64.sh -b -p /home/ubuntu/sharedata/anaconda2
bash /home/ubuntu/Anaconda2-5.0.0.1-Linux-x86_64.sh -b -p /home/ubuntu/anaconda2

#export PATH

echo 'export OS_TENANT_NAME="f50b2aeb-f768-42e4-bf99-06e5379a9d7b"' >> /home/ubuntu/.bashrc
echo 'export OS_USERNAME="32dfab87-17bc-4cff-8e90-749474bf78d1"' >> /home/ubuntu/.bashrc
echo 'export OS_PASSWORD="Fcr9SbdiaDtepSShFzteTxwypWLtKOMBSlcz4SpKzyz58EK2"' >> /home/ubuntu/.bashrc
echo 'export OS_AUTH_URL="https://auth.vexxhost.net/v2.0/"' >> /home/ubuntu/.bashrc
echo 'export OS_REGION_NAME="ca-ymq-1"' >> /home/ubuntu/.bashrc

# added by Anaconda2 4.2.0 installer
echo 'export PATH="/home/ubuntu/anaconda2/bin:$PATH"' >> /home/ubuntu/.bashrc
echo 'export PYTHONPATH="/rndModule:$PYTHONPATH"' >> /home/ubuntu/.bashrc

#create symlink for rndModule in root /
sudo ln -s /home/ubuntu/sharedata/rndModule /rndModule
################################################################################
export PATH="/home/ubuntu/anaconda2/bin:$PATH"
jupyter notebook --generate-config

#configure jupyter notebook
echo "c.NotebookApp.password = u''" >> /home/ubuntu/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.token = ''" >> /home/ubuntu/.jupyter/jupyter_notebook_config.py
echo "c = get_config()" >> /home/ubuntu/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.ip = '*'" >> /home/ubuntu/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.open_browser = False" >> /home/ubuntu/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.port = 9999" >> /home/ubuntu/.jupyter/jupyter_notebook_config.py
echo "c.NotebookApp.notebook_dir='/home/ubuntu/sharedata'" >> /home/ubuntu/.jupyter/jupyter_notebook_config.py


################################################################################

# yes w | pip install --ignore-installed --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.3.0-cp27-none-linux_x86_64.whl
#
# yes w | pip install keras
# yes w | pip install fuzzywuzzy[speedup]
# yes w | pip install tqdm==4.19.1
# yes w | pip install python-openstackclient
# yes w | pip install python-swiftclient
# yes w | pip install slacker
# yes w | pip install parmap
# yes w | pip install netifaces
# yes w | pip install pysal==1.12.0
# yes w| pip install python-novaclient
# yes w| pip install python-swiftclient
# #database connectors
# yes w| pip install redis==2.10.6 pymongo==3.5.1

#conda install modules
conda install -y -c conda-forge xgboost keras
conda install -y -c pytorch torchvision -c soumith
#pip install modules
pip install -r /home/ubuntu/pip/requirements.txt

################################################
# install and config jupyter extension
yes w |pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install --user

################################################
# nbextension config
echo '{
  "load_extensions": {
    "nbextensions_configurator/config_menu/main": true,
    "snippets_menu/main": true,
    "codefolding/main": true,
    "highlighter/highlighter": true,
    "ruler/main": true,
    "runtools/main": false,
    "contrib_nbextensions_help_item/main": false,
    "toggle_all_line_numbers/main": true,
    "scratchpad/main": true,
    "execute_time/ExecuteTime": true,
    "splitcell/splitcell": true,
    "table_beautifier/main": true,
    "help_panel/help_panel": true,
    "autosavetime/main": true,
    "comment-uncomment/main": true,
    "code_prettify/2to3": true,
    "hide_input_all/main": true,
    "collapsible_headings/main": true,
    "datestamper/main": true,
    "varInspector/main": true,
    "move_selected_cells/main": true,
    "code_prettify/code_prettify": true
  },
  "snippets": {
    "insert_as_new_cell": false
  }
}'> /home/ubuntu/.jupyter/nbconfig/notebook.json


# install and config ipython widgets
pip install ipywidgets
jupyter nbextension enable --py widgetsnbextension

################################################
#create jupyter service

sudo sh -c """echo '[Unit]
Description=Jupyter Notebook Server

[Service]
Type=simple
Environment="PATH=/home/ubuntu/anaconda2/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"
ExecStart=/home/ubuntu/anaconda2/bin/jupyter-notebook
User=ubuntu
Group=ubuntu
WorkingDirectory=/home/ubuntu
Restart=always

[Install]
WantedBy=multi-user.target' > /etc/systemd/system/jupyter.service"""

sudo systemctl daemon-reload
sudo systemctl enable jupyter

#start jupyter notebook Server
sudo service jupyter start
