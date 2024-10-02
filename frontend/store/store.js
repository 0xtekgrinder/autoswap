import { configureStore, combineReducers } from '@reduxjs/toolkit';
import storage from 'redux-persist/lib/storage'; // defaults to localStorage 
import { persistReducer, persistStore } from 'redux-persist';
import nextGnoSlice from '../slices/nextGnoSlice.js';

// Configure persist settings
const persistConfig = {
  key: 'root', // This key is used to save the persisted state under this key in storage
  storage, // Using localStorage as the storage engine
  blacklist: [], 
  whitelist: ['nextgno'], 
};

// Combine reducers
const combinedReducer = combineReducers({
  nextgno: nextGnoSlice.reducer,
});

// Persist the combined reducer
const persistedReducer = persistReducer(persistConfig, combinedReducer);

// Create the store with the persisted reducer
export const store = configureStore({
  reducer: persistedReducer,
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      immutableCheck: false,
      serializableCheck: false,
    }),
});

// Export the persistor
export const persistor = persistStore(store);
