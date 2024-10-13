import React, { useState } from 'react';
import {
  Modal,
  ModalOverlay,
  ModalContent,
  ModalHeader,
  ModalFooter,
  ModalBody,
  ModalCloseButton,
  Button,
  Stack,
  Input,
} from '@chakra-ui/react';

const DepositModal: React.FC<{ isOpen: boolean; onOpen: () => void; onClose: () => void }> = ({ isOpen, onOpen, onClose }) => {
  const [mode, setMode] = useState<'single' | 'double'>('single');
  const [singleInput, setSingleInput] = useState('');
  const [doubleInput1, setDoubleInput1] = useState('');
  const [doubleInput2, setDoubleInput2] = useState('');

  const handleDeposit = () => {
    if (mode === 'single') {
      console.log('Single Input:', singleInput);
    } else {
      console.log('Double Input 1:', doubleInput1);
      console.log('Double Input 2:', doubleInput2);
    }
    onClose();
  };

  return (
    <>
      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>Deposit</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            <Stack direction="row" spacing={4} mb={4}>
              <Button
                colorScheme={mode === 'single' ? 'blue' : 'gray'}
                onClick={() => setMode('single')}
              >
                Single Input
              </Button>
              <Button
                colorScheme={mode === 'double' ? 'blue' : 'gray'}
                onClick={() => setMode('double')}
              >
                Double Input
              </Button>
            </Stack>

            {mode === 'single' ? (
              <Input
                mt={4}
                placeholder="Enter amount"
                value={singleInput}
                onChange={(e) => setSingleInput(e.target.value)}
              />
            ) : (
              <>
                <Input
                  mt={4}
                  placeholder="Enter first amount"
                  value={doubleInput1}
                  onChange={(e) => setDoubleInput1(e.target.value)}
                />
                <Input
                  mt={4}
                  placeholder="Enter second amount"
                  value={doubleInput2}
                  onChange={(e) => setDoubleInput2(e.target.value)}
                />
              </>
            )}
          </ModalBody>

          <ModalFooter>
            <Button colorScheme="blue" mr={3} onClick={handleDeposit}>
              Deposit
            </Button>
            <Button variant="ghost" onClick={onClose}>Cancel</Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
};

export default DepositModal;