import { BigNumber } from "ethers";

// PRECISIONありのshareに変換
export const formatWithPrecision = (
    share: string,
    precision: BigNumber
): BigNumber => {
    return BigNumber.from(share).mul(precision);
};

// PRECISIONなしのshareに変換
export const formatWithoutPrecision = (
    share: BigNumber,
    precision: BigNumber
): string => {
    return share.div(precision).toString();
};

