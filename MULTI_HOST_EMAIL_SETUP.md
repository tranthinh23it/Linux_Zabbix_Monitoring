# Setup Multiple Email Alerts for Different Hosts

Hướng dẫn cấu hình gửi email khác nhau cho từng host/máy trong Zabbix.

## Phương pháp: Dùng Custom Fields + Alert Action

### Bước 1: Thêm Custom Field cho Host

1. Vào **Configuration → Hosts**
2. Click vào host (ví dụ: `tranthinh`)
3. Scroll xuống phần **Custom fields**
4. Click **Add** để thêm field mới:
   - **Name**: `Owner Email`
   - **Value**: `tranhungthinh30702@gmail.com`
5. Click **Update**

### Bước 2: Thêm Custom Field cho Host Khác

Lặp lại Bước 1 cho host khác:
- Host: `server-2`
- Custom Field: `Owner Email` = `email-server2@gmail.com`

### Bước 3: Tạo Alert Action với Custom Field

1. Vào **Configuration → Actions**
2. Click **Create action**
3. **Name**: `Send Email to Host Owner`
4. **Conditions**:
   - Trigger severity ≥ Average
5. **Operations**:
   - **Send to users**: (để trống)
   - **Send to user groups**: (để trống)
   - **Default message**:
     ```
     Problem: {TRIGGER.NAME}
     Host: {HOST.NAME}
     Severity: {TRIGGER.SEVERITY}
     Time: {EVENT.TIME}
     
     Details: {TRIGGER.DESCRIPTION}
     ```
   - **Custom message**: (để trống)
6. **Recovery operations**:
   - Tương tự như Operations
7. Click **Add** → **Save**

### Bước 4: Cấu hình Media Type để Dùng Custom Field

1. Vào **Administration → Media types**
2. Click **Email**
3. Trong **Message templates**, thêm macro `{HOST.CUSTOM_FIELD.Owner Email}`
4. Ví dụ:
   ```
   To: {HOST.CUSTOM_FIELD.Owner Email}
   Subject: {TRIGGER.NAME}
   Body: {TRIGGER.DESCRIPTION}
   ```

### Bước 5: Cấu hình User Media

1. Vào **Administration → Users → Admin**
2. Tab **Media**
3. Click **Add**
4. **Type**: Email
5. **Send to**: `{HOST.CUSTOM_FIELD.Owner Email}`
6. **When active**: 1-7,00:00-24:00
7. **Use if severity**: Average and above
8. Click **Add** → **Update**

## Cách Khác: Dùng Host Groups

Nếu muốn đơn giản hơn, có thể dùng **Host Groups**:

1. Tạo Host Group cho từng team/owner:
   - Group: `Team A` → Email: `team-a@gmail.com`
   - Group: `Team B` → Email: `team-b@gmail.com`

2. Tạo Alert Action riêng cho mỗi group:
   - Action 1: Nếu host trong `Team A` → Gửi email `team-a@gmail.com`
   - Action 2: Nếu host trong `Team B` → Gửi email `team-b@gmail.com`

## Kiểm Tra

Sau khi setup:
1. Trigger alert trên host bất kỳ
2. Email sẽ được gửi đến địa chỉ trong Custom Field của host đó
3. Kiểm tra inbox của từng email

## Lưu Ý

- Custom Field name phải giống nhau trên tất cả host
- Macro `{HOST.CUSTOM_FIELD.Owner Email}` phải match với tên Custom Field
- Nếu host không có Custom Field, email sẽ không được gửi (hoặc gửi đến default)

## Script Tự Động (Optional)

Bạn có thể tạo script để thêm Custom Field cho nhiều host cùng lúc qua Zabbix API.
