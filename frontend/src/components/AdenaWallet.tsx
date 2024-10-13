import { Button } from '@chakra-ui/react';
import { useEffect, useState } from 'react';

const AdenaWallet = () => {

    const [account, setAccount] = useState<string>("");

    useEffect(() => {
      integrateWallet();
    }, []);

    const integrateWallet = async () => {
      // Look for the adena object
      if (!window.adena) {
        // Open adena.app in a new tab if the adena object is not found
        window.open("https://adena.app/", "_blank");
      } else {
        // Add connection
        const connection = await adena.AddEstablish("GnoALM");
        console.log("connection, ", JSON.stringify(connection))

        const account = await adena.GetAccount()
        console.log("account, ", JSON.stringify(account))
        setAccount(account.data.address)
      }
    };


    const formatAccount = (account: string) => {
        if (account.length <= 10) return account;
        return `${account.slice(0, 4)}...${account.slice(-3)}`;
      };


  return (
    <div>
        <Button onClick={integrateWallet}>{account == "" ? "Connect Wallet" : formatAccount(account)}</Button>
    </div>
  );
};

export default AdenaWallet;