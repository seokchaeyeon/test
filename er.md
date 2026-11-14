## 문제 1의 DB

```mermaid
erDiagram
    UNIVERSITY ||--o{ SEEKER : graduate
    SEEKER }|--|{ COMPANY : apply
    SEEKER }o--|| COMPANY : hire

    SEEKER {
        string jumin_no PK
        string major
        float gpa
        int toeic
        string certificate
        int expected_salary
        string univ_name FK
    }

    COMPANY {
        string company_name PK
        string industry
        int required_seekers
        string apply_period
        int starting_salary
    }

    UNIVERSITY {
        string univ_name PK
        string address
        string description
        int employed_student_count
    }
