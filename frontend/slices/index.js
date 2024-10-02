// store/reducers/index.js
import { combineReducers } from 'redux';
import nextGnoReducer from './nextGnoSlice';

const rootReducer = combineReducers({
  nextgno: nextGnoReducer,
});

export default rootReducer;

