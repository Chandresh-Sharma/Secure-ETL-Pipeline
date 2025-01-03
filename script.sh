#!/bin/bash

# Define variables
SERVER_IP="<server_ip>"         # IP of the server from which to extract data
REMOTE_USER="username"          # Username for SCP transfer
REMOTE_HOST="<remote_host>"     # IP or hostname of the remote server
REMOTE_PATH="/path/to/remote/storage"  # Path where the data will be stored on the remote server
PASSWORD="YourSecretPassword"   # AES-256 encryption password
TEMP_DIR="/tmp"                 # Temporary directory for processing

# Step 1: Extract data from server via Netcat
echo "Step 1: Extracting data from server..."
nc $SERVER_IP 12345 > $TEMP_DIR/extracted_data.txt

# Check if extraction was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to extract data from the server."
  exit 1
fi

# Step 2: Transform the data by masking sensitive information (e.g., SSNs) using sed
echo "Step 2: Transforming data..."
sed -E 's/\b\d{3}-\d{2}-\d{4}\b/XXX-XX-XXXX/g' $TEMP_DIR/extracted_data.txt > $TEMP_DIR/transformed_data.txt

# Check if transformation was successful
if [ $? -ne 0 ]; then
  echo "Error: Data transformation failed."
  exit 1
fi

# Step 3: Encrypt the transformed data using OpenSSL with AES-256
echo "Step 3: Encrypting data..."
openssl enc -aes-256-cbc -salt -in $TEMP_DIR/transformed_data.txt -out $TEMP_DIR/transformed_data.enc -pass pass:$PASSWORD

# Check if encryption was successful
if [ $? -ne 0 ]; then
  echo "Error: Data encryption failed."
  exit 1
fi

# Step 4: Securely transfer the encrypted file to remote storage via SCP
echo "Step 4: Transferring encrypted data..."
scp $TEMP_DIR/transformed_data.enc $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH

# Check if the transfer was successful
if [ $? -ne 0 ]; then
  echo "Error: Data transfer failed."
  exit 1
fi

# Step 5: Clean up temporary files
echo "Step 5: Cleaning up temporary files..."
rm -f $TEMP_DIR/extracted_data.txt $TEMP_DIR/transformed_data.txt $TEMP_DIR/transformed_data.enc

echo "ETL process completed successfully!"
