import { Box, Typography, TextField, Button } from '@mui/material'
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import { useMutation, useQuery } from '@tanstack/react-query';
import useWeb3Store from '../utils/web3store';
import { TOKEN_CONTRACT_ADDRESS, CONTRACT_ADDRESS } from '../constants';
import { useEffect, useState } from 'react';
import { textFieldClasses } from '@mui/material';


function Timer() {
    return (
        <Box sx={{
            position: "absolute",
            right: 10,
            top: 10
        }}>
            <AccessTimeIcon sx={{ fontSize: 50 }} />
        </Box>
    )
}
export default function Rewards() {
    const contract = useWeb3Store(state => state.contract);
    const tokenContract = useWeb3Store(state => state.tokenContract);
    const connectedAccount = useWeb3Store(state => state.connectedAccount);
    const [apr, setApr] = useState(0);
    const [totalRewards, setTotalRewards] = useState(1024);

    const [amountInvested, setamountInvested] = useState(0);
    const query = useQuery(["apr"], async () => {
        const amount = await contract.apr();
        const totalRewards = await contract.stakingReward(connectedAccount);
        return { amount, totalRewards }
    }, {
        onSuccess(data) {
            setApr(parseInt(JSON.parse(data.amount)));
            setTotalRewards(JSON.parse(data.totalRewards));
        },
        onError(error) {
            console.log(error);
        },
        enabled: !!contract
    })

    const claim = useMutation(async () => {
        const txn = await contract.withdrawRewards(TOKEN_CONTRACT_ADDRESS)
        await txn.wait();
        return txn.hash;
    })

    const compound = useMutation(async () => {
        const txn = await contract.compoundRewards()
        console.log("compounding rewards")
        await txn.wait();
        return txn.hash;
    }, {
        onSuccess: (data) => {
            console.log(data);
            query.refetch();
        },
        onError: (error) => {
            console.log(error);
        }
    })

    return (
        <Box sx={{ p: 5, ml: 3, flexGrow: 1, height: "100%" }}>
            <Box sx={{
                border: "1px solid white",
                height: "100%",
                width: 350,
                borderRadius: 5,
                p: 4,
                position: "relative",
                display: "flex",
                flexDirection: "column",
                justifyContent: "center"
            }}>
                <Box component="span" sx={{ display: "flex", alignItems: "flex-end", mb: 1 }}>
                    <Typography variant="h2" sx={{ lineHeight: 0.7, fontSize: 50 }}>{apr}%</Typography>
                    <Typography variant="h6" sx={{ ml: 2 }}>APY</Typography>
                </Box>
                <Box component="span" sx={{ display: "flex", alignItems: "flex-end", mt: 2 }}>
                    <Typography variant="h2" sx={{ lineHeight: 0.7, fontSize: 100 }}>{totalRewards}</Typography>
                    <Typography variant="h4" sx={{ ml: 2 }}>LMS</Typography>
                </Box>
                <Box sx={{ display: "flex", alignItems: "flex-end", mt: 2 }}>
                    <Button
                        variant="contained"
                        size="large"
                        onClick={() => claim.mutate()}
                        sx={{
                            bgcolor: "white",
                            color: "black",
                            borderRadius: 5,
                            py: 0.5,
                            fontWeight: "900"
                        }}>
                        Claim
                    </Button>
                    <Button
                        variant="contained"
                        size="large"
                        onClick={() => compound.mutate()}
                        sx={{
                            bgcolor: "white",
                            color: "black",
                            borderRadius: 5,
                            ml: 2,
                            py: 0.5,
                            fontWeight: "900"
                        }}>
                        Compound
                    </Button>
                </Box>
            </Box>
        </Box>
    );
}