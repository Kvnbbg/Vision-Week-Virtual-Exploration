INSERT INTO Orders (CustomerID, OrderDate)
SELECT Customers.CustomerID, '2024-05-08'  -- Replace with actual order date
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID
WHERE Orders.OrderID = 123  -- Ensures we only insert for the new order
