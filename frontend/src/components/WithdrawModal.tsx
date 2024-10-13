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
  Input,
} from '@chakra-ui/react';

const WithdrawModal: React.FC<{ isOpen: boolean; onOpen: () => void; onClose: () => void }> = ({ isOpen, onOpen, onClose }) => {
  const [input1, setInput1] = useState('');
  const [input2, setInput2] = useState('');

  const handleWithdraw = () => {
    console.log('Input 1:', input1);
    console.log('Input 2:', input2);
    onClose();
  };

  return (
    <>
      <Modal isOpen={isOpen} onClose={onClose}>
        <ModalOverlay />
        <ModalContent>
          <ModalHeader>Withdraw</ModalHeader>
          <ModalCloseButton />
          <ModalBody>
            <Input
              mt={4}
              placeholder="Enter first amount"
              value={input1}
              onChange={(e) => setInput1(e.target.value)}
            />
            <Input
              mt={4}
              placeholder="Enter second amount"
              value={input2}
              onChange={(e) => setInput2(e.target.value)}
            />
          </ModalBody>

          <ModalFooter>
            <Button colorScheme="blue" mr={3} onClick={handleWithdraw}>
              Withdraw
            </Button>
            <Button variant="ghost" onClick={onClose}>Cancel</Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </>
  );
};

export default WithdrawModal;