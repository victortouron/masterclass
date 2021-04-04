db = :bank

Bank.Supervisor.start_link(42)
{:ok, macron_account} = Bank.Server.create(db, %{'lastname' => 'Macron', 'firstname' => 'Emmanuel'})
{:ok, melanchon_account} = Bank.Server.create(db, %{'lastname' => 'Melanchon', 'firstname' => 'Jean-Luc'})
Bank.Server.add(db, {macron_account, 1000000})
Bank.Server.retrieve(db, {macron_account, 500000})
Bank.Server.add(db, {melanchon_account, 20})
Bank.Server.retrieve(db, {melanchon_account, 1})
IO.inspect macron_account
IO.inspect melanchon_account
IO.inspect Bank.Server.read(db, macron_account)
IO.inspect Bank.Server.read(db, melanchon_account)

# Bank.Server.create(:bank, %{'lastname' => "Macron", 'firstname' => "Emmanuel"})
# Bank.Server.create(:bank, %{'lastname' => "Melanchon", 'firstname' => "Jean-Luc"})
