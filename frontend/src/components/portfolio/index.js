import React, { useState} from 'react';
import { useHistory } from 'react-router-dom';
import styled from 'styled-components';
import {
  Header, DataView, IdentityBadge, Tabs, Timer
} from '@aragon/ui';

import { getPreference, storePreference } from '../../utils/storage';
import Exercise from './Exercise';

function Portfolio() {
  const storedOptionTab = getPreference('optionTab', '0');
  const storedShowExpired = getPreference('showExpired', '0');

  const addr = '0x99dE7B407C4d26909527001e2556Aa5D159F316d';


  const [tabSelected, setTabSelected] = useState(parseInt(storedOptionTab, 10));

  const history = useHistory();

  return (
    <div style={{ height: "75vh", marginTop: "75px" }}>
      <Header primary="Portfolio" />
      <div className="back">
      <Tabs
        items={['oTokens', 'Compound', 'Aave']}
        selected={tabSelected}
        onChange={(choice) => {
          setTabSelected(choice);
          storePreference('optionTab', choice.toString());
        }}
      />
      </div>
      <Exercise/>
      {tabSelected === 0 ? (
        <DataView
          fields={['Name', 'Options Contract', 'Expires in']}
          entries={[
            { name: 'jenil.eth', OptionsContract: '0x5ds9285321dsdg24vbs99de', expiry: Date.now() }
          ]}
          renderEntry={({ name, OptionsContract, expiry }) => [
            <>jenil.eth</>,
            <IdentityBadge entity={addr} shorten={false} />,
            <Timer end={new Date(expiry * 1000)} format='Mdh' />,
          ]}
        />
      ) : tabSelected === 1 ? (
        <DataView
        fields={['Name', 'Options Contract', 'Expires in']}
        entries={[
          { name: 'jenil.eth', OptionsContract: '0x5ds9285321dsdg24vbs99de', expiry: Date.now() }
        ]}
        renderEntry={({ name, OptionsContract, expiry }) => [
          <>jenil.eth</>,
          <IdentityBadge entity={addr} shorten={false} />,
          <Timer end={new Date(expiry * 1000)} format='Mdh' />,
        ]}
      />
      ) : ( 
        <DataView
        fields={['Name', 'Options Contract', 'Expires in']}
        entries={[
          { name: 'jenil.eth', OptionsContract: '0x5ds9285321dsdg24vbs99de', expiry: Date.now() }
        ]}
        renderEntry={({ name, OptionsContract, expiry }) => [
          <>jenil.eth</>,
          <IdentityBadge entity={addr} shorten={false} />,
          <Timer end={new Date(expiry * 1000)} format='Mdh' />,
        ]}
      />
          )}

    </div>
  );
}

const Container = styled.div`
{
  background: #000000;
  }
`;

export default Portfolio;

function OptionList({ entries, showExpired, goToToken }) {
const addr = '0x99dE7B407C4d26909527001e2556Aa5D159F316d';

  const [page, setPage] = useState(0)
  return (
    <DataView
    fields={['Name', 'Options Contract', 'Expires in']}
    entries={[
      { name: 'jenil.eth', OptionsContract: '0x5ds9285321dsdg24vbs99de', expiry: Date.now() }
    ]}
    renderEntry={({ name, OptionsContract, expiry }) => [
      <>jenil.eth</>,
      <IdentityBadge entity={addr} shorten={false} />,
      <Timer end={new Date(expiry * 1000)} format='Mdh' />,
    ]}
    />
  )
}