# 🎯 Simple Loan System Example

## Step 1: Add a Debt
- **Person**: John
- **Amount**: $500
- **Type**: "I Owe" (you borrowed from John)
- **Description**: "Emergency loan"

**Result**: You see John in "I Owe" tab with $500 remaining

## Step 2: Make a Payment
- **Amount**: $100
- **Account**: Your Bank Account (optional)
- **Date**: Today

**What Happens**:
1. John's debt shows: $500 total, $100 paid, $400 remaining
2. Your bank account balance decreases by $100
3. Progress bar shows 20% paid

## Step 3: Make Another Payment
- **Amount**: $200
- **Account**: Your Bank Account

**What Happens**:
1. John's debt shows: $500 total, $300 paid, $200 remaining
2. Your bank account balance decreases by another $200
3. Progress bar shows 60% paid

## Step 4: Final Payment
- **Amount**: $200 (remaining amount)

**What Happens**:
1. John's debt shows: $500 total, $500 paid, $0 remaining
2. Your bank account balance decreases by $200
3. Progress bar shows 100% paid
4. Debt is marked as "Paid Off"

## 🔄 "Owed to Me" Example

**Scenario**: Sarah borrowed $300 from you

1. **Add debt**: Sarah, $300, "Owed to Me"
2. **Sarah pays you $100**: Your account balance increases by $100
3. **Sarah pays you $200**: Your account balance increases by $200
4. **Debt is fully paid**: Sarah's debt shows 100% paid

## 💡 Key Points:
- **"I Owe"**: You pay money OUT (account balance decreases)
- **"Owed to Me"**: You receive money IN (account balance increases)
- **All transactions stay in loan tab only**
- **Account balances update automatically**
- **Progress bars show payment status**
