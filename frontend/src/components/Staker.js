/* eslint-disable react-hooks/exhaustive-deps */
import { Box, Typography, TextField, Button } from '@mui/material'
import AccessTimeIcon from '@mui/icons-material/AccessTime';
import { useMutation, useQuery } from '@tanstack/react-query';
import useWeb3Store from '../utils/web3store';
import { TOKEN_CONTRACT_ADDRESS, CONTRACT_ADDRESS } from '../constants';
import { useEffect, useState } from 'react';
import BigNumber from 'bignumber.js';
import { useQueryClient } from '@tanstack/react-query';
import Countdown from "react-countdown"

export default function Staker() {
    const contract = useWeb3Store(state => state.contract);
    const tokenContract = useWeb3Store(state => state.tokenContract);
    const connectedAccount = useWeb3Store(state => state.connectedAccount);
    const queryClient = useQueryClient();
    const [values, setValues] = useState({ stake: 0, unstake: 0 });
    const [amountInvested, setamountInvested] = useState(0);
    const query = useQuery(["stake"], async () => {
        const amount = await contract.balances(connectedAccount);
        return amount
    }, {
        onSuccess: (data) => {
            setamountInvested(BigNumber(data["_hex"]).dividedBy(10 ** 18).toPrecision(5));
            // setamountInvested(data);
        },
        onError: (error) => {
            console.log(error);
        },
        enabled: !!contract && !!connectedAccount
    })
    const stake = useMutation(async () => {
        if (values.stake == 0) return;
        const approval = await tokenContract.approve(CONTRACT_ADDRESS, BigInt(values.stake * 1e18), {
            gasLimit: BigInt(1000000)
        }
        );
        approval.wait();
        const txn = await contract.stakeTokens(TOKEN_CONTRACT_ADDRESS, BigInt(values.stake * 1e18), {
            gasLimit: BigInt(1000000)
        });
        await txn.wait();
    }, {
        onSuccess: (data) => {
            query.refetch();
            queryClient.refetchQueries(["time"], { type: "active" });
        }
        , onError: (error) => {
            console.log(error);
        }
    })
    const unstake = useMutation(async () => {
        if (values.unstake == 0) return;
        const txn = await contract.unstakeTokens(TOKEN_CONTRACT_ADDRESS, BigInt(values.unstake * 1e18), {
            gasLimit: BigInt(1000000)
        })
        await txn.wait();
    }, {
        onSuccess: (data) => {
            query.refetch();
            queryClient.refetchQueries(["time"], { type: "active" });
        }
    })
    return (
        <Box sx={{ p: 5, ml: 3, flexGrow: 1, height: "100%" }}>
            <Box sx={{
                border: "1px solid white",
                height: "100%",
                width: 350,
                borderRadius: 5,
                p: 2,
                position: "relative"
            }}>

                <Box sx={{
                    position: "relative",
                    p: 2,
                }}>
                    <Typography variant="h2" sx={{ lineHeight: 0.8 }}>{amountInvested}<span style={{ fontSize: 24, marginLeft: 4 }}>LMS</span></Typography>
                    <Typography variant="body1">Amount Invested</Typography>
                    <Box sx={{ position: "relative", pt: 5, mt: 2 }}>
                        <TextField
                            id="filled-basic"
                            variant="standard"
                            color="secondary"
                            focused
                            sx={{
                                width: "100%",
                                fontSize: 70,
                            }}
                            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
                            value={values.stake}
                            onChange={(e) => setValues({ ...values, stake: e.target.value })}
                        />
                        <Button
                            variant="contained"
                            size="large"
                            onClick={() => stake.mutate()}
                            sx={{
                                bgcolor: "white",
                                color: "black",
                                borderRadius: 5,
                                position: "absolute",
                                right: 0,
                                py: 0.5,
                                bottom: 10,
                                fontWeight: "900"
                            }}>
                            Stake
                        </Button>
                    </Box>
                    <Box sx={{ position: "relative", pt: 5 }}>
                        <TextField
                            id="filled-basic"
                            variant="standard"
                            color="secondary"
                            focused
                            value={values.unstake}
                            inputProps={{ inputMode: 'numeric', pattern: '[0-9]*' }}
                            onChange={(e) => setValues({ ...values, unstake: e.target.value })}
                            sx={{
                                width: "100%",
                                fontSize: 70,
                            }} />
                        <Button
                            variant="contained"
                            size="large"
                            onClick={() => unstake.mutate()}
                            sx={{
                                bgcolor: "white",
                                color: "black",
                                borderRadius: 5,
                                position: "absolute",
                                right: 0,
                                py: 0.5,
                                bottom: 10,
                                fontWeight: "900"
                            }}>
                            Unstake
                        </Button>
                    </Box>
                </Box>
                <Timer />
            </Box>
        </Box>
    );
}

function Timer() {
    const [stakingTime, setStakingTime] = useState(0);
    const contract = useWeb3Store(state => state.contract);
    const connectedAccount = useWeb3Store(state => state.connectedAccount);
    const blockTimestamp = useWeb3Store(state => state.blockTimestamp);
    const query = useQuery(["time", "staking"], async () => {
        console.log("querying staking time");
        const amount = await contract.minimumStakingTime(connectedAccount);
        return amount
    }, {
        enabled: !!contract,
        onSuccess(data) {
            const difference = BigNumber(data["_hex"]).minus(blockTimestamp).toNumber();
            if (difference < 0) {
                console.log("staking time is less than 0")
                setStakingTime(0);
                return;
            }
            setStakingTime(difference);
        }
    })
    return (
        <div style={{
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            gap: "8px"
        }}>
            <AccessTimeIcon />
            {stakingTime ? (
                <Countdown date={Date.now() + stakingTime * 1000} />
            ) : <>00:00:00:00</>}
        </div>
    )
}