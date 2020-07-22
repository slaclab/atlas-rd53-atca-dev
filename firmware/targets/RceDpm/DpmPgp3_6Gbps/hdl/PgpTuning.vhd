-------------------------------------------------------------------------------
-- File       : PgpTuning.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS RD53 DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;

entity PgpTuning is
   generic (
      TPD_G : time := 1 ns);
   port (
      txPreCursor     : out Slv5Array(1 downto 0);
      txPostCursor    : out Slv5Array(1 downto 0);
      txDiffCtrl      : out Slv4Array(1 downto 0);
      -- AXI-Lite Interface (axilClk domain)
      axilClk         : in  sl;
      axilRst         : in  sl;
      axilReadMaster  : in  AxiLiteReadMasterType;
      axilReadSlave   : out AxiLiteReadSlaveType;
      axilWriteMaster : in  AxiLiteWriteMasterType;
      axilWriteSlave  : out AxiLiteWriteSlaveType);
end PgpTuning;

architecture mapping of PgpTuning is

   type RegType is record
      txPreCursor    : Slv5Array(1 downto 0);
      txPostCursor   : Slv5Array(1 downto 0);
      txDiffCtrl     : Slv4Array(1 downto 0);
      axilReadSlave  : AxiLiteReadSlaveType;
      axilWriteSlave : AxiLiteWriteSlaveType;
   end record;

   constant REG_INIT_C : RegType := (
      txPreCursor    => (others => "00111"),
      txPostCursor   => (others => "00111"),
      txDiffCtrl     => (others => "1111"),
      axilReadSlave  => AXI_LITE_READ_SLAVE_INIT_C,
      axilWriteSlave => AXI_LITE_WRITE_SLAVE_INIT_C);

   signal r   : RegType := REG_INIT_C;
   signal rin : RegType;

begin

   comb : process (axilReadMaster, axilRst, axilWriteMaster, r) is
      variable v      : RegType;
      variable axilEp : AxiLiteEndPointType;
   begin
      -- Latch the current value
      v := r;

      -- Determine the transaction type
      axiSlaveWaitTxn(axilEp, axilWriteMaster, axilReadMaster, v.axilWriteSlave, v.axilReadSlave);

      -- Map the read registers
      for i in 1 downto 0 loop
         axiSlaveRegister(axilEp, toSlv((4*i)+(0*16*4), 8), 0, v.txPreCursor(i));  -- 0x00:0x2F
         axiSlaveRegister(axilEp, toSlv((4*i)+(1*16*4), 8), 0, v.txPostCursor(i));  -- 0x40:0x6F
         axiSlaveRegister(axilEp, toSlv((4*i)+(2*16*4), 8), 0, v.txDiffCtrl(i));  -- 0x80:0xAF
      end loop;

      -- Closeout the transaction
      axiSlaveDefault(axilEp, v.axilWriteSlave, v.axilReadSlave, AXI_RESP_DECERR_C);

      -- Outputs
      axilWriteSlave <= r.axilWriteSlave;
      axilReadSlave  <= r.axilReadSlave;
      txPreCursor    <= r.txPreCursor;
      txPostCursor   <= r.txPostCursor;
      txDiffCtrl     <= r.txDiffCtrl;

      -- Synchronous Reset
      if (axilRst = '1') then
         v := REG_INIT_C;
      end if;

      -- Register the variable for next clock cycle
      rin <= v;

   end process comb;

   seq : process (axilClk) is
   begin
      if (rising_edge(axilClk)) then
         r <= rin after TPD_G;
      end if;
   end process seq;

end mapping;
