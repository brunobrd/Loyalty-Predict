# %%
import pandas as pd
import sqlalchemy

con = sqlalchemy.create_engine("sqlite:///../../data/analytics/database.db")

#%%

df = pd.read_sql("abt_fiel", con)
df.head()
# %%
df_oot = df[df["dtRef"]==df["dtRef"].max()].reset_index(drop=True)
df_oot

# %%
target = "flFiel"
features = df.columns.to_list()[3:]

df_train_test = df[df["dtRef"]<df["dtRef"].max()].reset_index(drop=True)

y = df_train_test[target]
X = df_train_test[features]

from sklearn import model_selection

X_train, X_test, y_train, y_test = model_selection.train_test_split(
    X, y,
    test_size=0.2,
    random_state=42,
    stratify=y,
)

print(f"Base Treino: {y_train.shape[0]} Unid. | tx.Target {100*y_train.mean():.2f}%")
print(f"Base Test: {y_test.shape[0]} Unid.  | Tx.Target {100*y_test.mean():.2f}%")
# %%
s_nas = X_train.isna().mean
s_nas = s_nas[s_nas>0]
s_nas