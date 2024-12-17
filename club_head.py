import psycopg2  # Import psycopg2 for PostgreSQL
import streamlit as st
import pandas as pd

# Establish the PostgreSQL connection
mydb = psycopg2.connect(
    host="localhost",  # Database host
    user="postgres",  # Database username (default is 'postgres')
    password="GaganPOSTGRE8+",  # Database password
    dbname="financem",
    port="5432"  # Database name
)
mycursor = mydb.cursor()
print("Connection Established")

def app():
    mycursor.execute("SELECT * FROM domain")
    result = mycursor.fetchall()
    domain_list = [item[0] for item in result]
    event_id = st.sidebar.text_input("Enter Event ID")

    if st.sidebar.button("Enter"):
        st.title("Welcome to Club Financials")
        tab1, tab2 = st.tabs(["Financial Overview", "Event Details"])
        with tab1:
            st.header("Financial Overview")
            sql = "SELECT * FROM transactions WHERE event_id = %s"
            mycursor.execute(sql, (event_id,))
            result2 = mycursor.fetchall()
            trans_id = [item[0] for item in result2]
            types = [item[1] for item in result2]
            dates = [item[2] for item in result2]
            modes = [item[3] for item in result2]
            amounts = [item[4] for item in result2]
            remarks = [item[5] for item in result2]

            data1 = pd.DataFrame({
                'Transaction ID': trans_id,
                'Type': types,
                'Date': dates,
                'Mode': modes,
                'Amount': amounts,
                'Remarks': remarks,
            })
            st.table(data1)

        with tab2:
            st.header("Event Details")
            sql = "SELECT event_name, event_date, budget FROM event WHERE event_id = %s"
            mycursor.execute(sql, (event_id,))
            event_details = mycursor.fetchone()
            st.write(f"Event Name: {event_details[0]}")
            st.write(f"Event Date: {event_details[1]}")
            st.write(f"Event Budget: {event_details[2]}")

if __name__ == "__main__":
    app()
