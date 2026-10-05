import sys
import unittest
from copy import deepcopy
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'tools'))
from pe_hops import word32,packets_for,bind_message,messages_for,copy_candidates,collective_dsr


def observations():
    return [dict(row=1,cycle=10,ident='9007199254740993',pe='0,0',xy=[4,1],ramp=True,word=0x41300000,color=4,control=False),
            dict(row=2,cycle=56,ident='9007199254740993',pe='0,1',xy=[4,2],ramp=False,word=0x41300000,color=4,control=False)]


class HopBinding(unittest.TestCase):
    def test_descriptor_and_chronology_exclude_an_identical_host_copy(self):
        message=messages_for(packets_for(observations())[0])[0]
        def instruction(dsr,cycle,pe='0,0'):
            return dict(pe=pe,name='IMOV32.NF',count=1,ut=3,assembly=f'imov32.nf [dds{dsr}] = [s1ds{dsr}]',
                execute=[dict(index=0,cycle=cycle,dest=0x41300000,src1=0x41300000)])
        host=instruction(0,1);send=instruction(1,7);late=instruction(1,11)
        self.assertEqual(copy_candidates([host,send,late],message,'send',1),[send])
        early=instruction(1,55,'0,1');receive=instruction(1,59,'0,1')
        self.assertEqual(copy_candidates([early,receive],message,'receive',1),[receive])
        source='const mpi_x = @import_module("<collectives_2d/pe>", .{ .dest_dsr_ids = [1]u16{1}, .src1_dsr_ids = [1]u16{1} });'
        self.assertEqual(collective_dsr(source,'mpi_x'),1)
        with self.assertRaises(ValueError):collective_dsr(source,'mpi_y')

    def test_both_halves_and_valid_unsigned_ranges(self):
        self.assertEqual(word32(0xc010,0),0xc0100000)
        self.assertEqual(word32(0x3f80,1),0x3f800001)
        for args in [(None,0),(0,65536),(-1,0)]:
            with self.assertRaises(ValueError):word32(*args)

    def test_complete_words_identity_geometry_and_time_are_required(self):
        packets,unknown=packets_for(observations())
        self.assertEqual(unknown,[]);self.assertEqual(packets[0]['interval'],46)
        self.assertEqual(packets[0]['ident'],'9007199254740993')
        for key,value in [('word',0x41300001),('xy',[5,2]),('cycle',9),('ident','other'),('color',5),('control',True)]:
            obs=observations();obs[1][key]=value
            p,u=packets_for(obs);self.assertEqual(p,[]);self.assertEqual(len(u),2)
        obs=observations();obs.append(deepcopy(obs[1]))
        self.assertEqual(packets_for(obs)[0],[])

    def test_value_equality_alone_cannot_select_a_message(self):
        ps,_=packets_for(observations());messages=messages_for(ps)
        self.assertIs(bind_message(messages,'0,0','0,1',[11.0],4),messages[0])
        for vals in [[12.0],[11.0,11.0]]:
            with self.assertRaises(ValueError):bind_message(messages,'0,0','0,1',vals,4)
        with self.assertRaises(ValueError):bind_message(messages*2,'0,0','0,1',[11.0],4)


if __name__=='__main__':unittest.main()
