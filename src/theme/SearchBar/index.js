import React, {useCallback, useMemo, useRef, useState} from 'react';
import {DocSearchButton, useDocSearchKeyboardEvents} from '@docsearch/react';
import Head from '@docusaurus/Head';
import Link from '@docusaurus/Link';
import {useHistory} from '@docusaurus/router';
import {isRegexpStringMatch, useSearchLinkCreator} from '@docusaurus/theme-common';
import {
  useAlgoliaContextualFacetFilters,
  useSearchResultUrlProcessor,
} from '@docusaurus/theme-search-algolia/client';
import Translate from '@docusaurus/Translate';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import {createPortal} from 'react-dom';
import translations from '@theme/SearchTranslations';
import aa from 'search-insights';
import {useEffect} from 'react';
import {getGoogleAnalyticsUserIdFromBrowserCookie} from '../../lib/google/google'

let DocSearchModal = null;

function Hit({ hit, children }) {
  const handleClick = () => {
    if (hit.queryID) {
      aa('clickedObjectIDsAfterSearch', {
        eventName: 'Search Result Clicked',
        index: hit.__autocomplete_indexName,
        queryID: hit.queryID, 
        objectIDs: [hit.objectID],
        positions: [hit.index+1], // algolia indexes from 1
      });
    }
  };
  return <Link onClick={handleClick} to={hit.url}>{children}</Link>;
}

function ResultsFooter({state, onClose}) {
  const generateSearchPageLink = useSearchLinkCreator();
  return (
    <Link to={generateSearchPageLink(state.query)} onClick={onClose}>
      <Translate
        id="theme.SearchBar.seeAll"
        values={{count: state.context.nbHits}}>
        {'See all {count} results'}
      </Translate>
    </Link>
  );
}

function mergeFacetFilters(f1, f2) {
  const normalize = (f) => (typeof f === 'string' ? [f] : f);
  return [...normalize(f1), ...normalize(f2)];
}

function DocSearch({contextualSearch, externalUrlRegex, ...props}) {
  const queryIDRef = useRef(null);

  const {siteMetadata} = useDocusaurusContext();
  const processSearchResultUrl = useSearchResultUrlProcessor();
  const contextualSearchFacetFilters = useAlgoliaContextualFacetFilters();
  const configFacetFilters = props.searchParameters?.facetFilters ?? [];
  const facetFilters = contextualSearch
    ? // Merge contextual search filters with config filters
      mergeFacetFilters(contextualSearchFacetFilters, configFacetFilters)
    : // ... or use config facetFilters
      configFacetFilters;
  // We add clickAnalyics here
  const searchParameters = {
    ...props.searchParameters,
    facetFilters,
    clickAnalytics: true,
  };
  const history = useHistory();
  const searchContainer = useRef(null);
  const searchButtonRef = useRef(null);
  const [isOpen, setIsOpen] = useState(false);
  const [initialQuery, setInitialQuery] = useState(undefined);
	
  useEffect(() => {
    if (typeof window !== "undefined") {
      const userToken = getGoogleAnalyticsUserIdFromBrowserCookie('_ga');
      aa('init', {
        appId: props.appId,
        apiKey: props.apiKey,
      });
      aa('setUserToken', userToken);
    }
  }, [props.appId, props.apiKey]);

  const importDocSearchModalIfNeeded = useCallback(() => {
    if (DocSearchModal) {
      return Promise.resolve();
    }
    return Promise.all([
      import('@docsearch/react/modal'),
      import('@docsearch/react/style'),
      import('./styles.css'),
    ]).then(([{DocSearchModal: Modal}]) => {
      DocSearchModal = Modal;
    });
  }, []);

  const onOpen = useCallback(() => {
    importDocSearchModalIfNeeded().then(() => {
      searchContainer.current = document.createElement('div');
      document.body.insertBefore(
        searchContainer.current,
        document.body.firstChild,
      );
      setIsOpen(true);
    });
  }, [importDocSearchModalIfNeeded, setIsOpen]);

  const onClose = useCallback(() => {
    setIsOpen(false);
    searchContainer.current?.remove();
  }, [setIsOpen]);

  const onInput = useCallback(
    (event) => {
      importDocSearchModalIfNeeded().then(() => {
        setIsOpen(true);
        setInitialQuery(event.key);
      });
    },
    [importDocSearchModalIfNeeded, setIsOpen, setInitialQuery],
  );

  const navigator = useRef({
    navigate({itemUrl}) {
      // Algolia results could contain URL's from other domains which cannot
      // be served through history and should navigate with window.location
      if (isRegexpStringMatch(externalUrlRegex, itemUrl)) {
        window.location.href = itemUrl;
      } else {
        history.push(itemUrl);
      }
    },
  }).current;

  const transformItems = useRef((items, state) => {  
    return props.transformItems
      ? props.transformItems(items)
      : items.map((item, index) => {
          return {
            ...item,
            url: processSearchResultUrl(item.url),
            index, // Adding the index property - needed for click metrics
            queryID: queryIDRef.current
          };
        });
  }).current;
  
  const resultsFooterComponent = useMemo(
    () =>
      // eslint-disable-next-line react/no-unstable-nested-components
      (footerProps) =>
        <ResultsFooter {...footerProps} onClose={onClose} />,
    [onClose],
  );

  const transformSearchClient = useCallback((searchClient) => {
    searchClient.addAlgoliaAgent('docusaurus', siteMetadata.docusaurusVersion);
    // Wrap the search function to intercept responses
    const originalSearch = searchClient.search;
    searchClient.search = async (requests) => {
      const response = await originalSearch(requests);
      // Extract queryID from the response
      if (response.results?.length > 0 && response.results[0].queryID) {
        queryIDRef.current = response.results[0].queryID;
      }
      return response;
    };
    return searchClient;
  }, [siteMetadata.docusaurusVersion]);

  useDocSearchKeyboardEvents({
    isOpen,
    onOpen,
    onClose,
    onInput,
    searchButtonRef,
  });
  return (
    <>
      <Head>
        {/* This hints the browser that the website will load data from Algolia,
        and allows it to preconnect to the DocSearch cluster. It makes the first
        query faster, especially on mobile. */}
        <link
          rel="preconnect"
          href={`https://${props.appId}-dsn.algolia.net`}
          crossOrigin="anonymous"
        />
      </Head>

      <DocSearchButton
        onTouchStart={importDocSearchModalIfNeeded}
        onFocus={importDocSearchModalIfNeeded}
        onMouseOver={importDocSearchModalIfNeeded}
        onClick={onOpen}
        ref={searchButtonRef}
        translations={translations.button}
      />

      {isOpen &&
        DocSearchModal &&
        searchContainer.current &&
        createPortal(
          <DocSearchModal
            onClose={onClose}
            initialScrollY={window.scrollY}
            initialQuery={initialQuery}
            navigator={navigator}
            transformItems={transformItems}
            hitComponent={Hit}
            transformSearchClient={transformSearchClient}
            {...(props.searchPagePath && {
              resultsFooterComponent,
            })}
            {...props}
            insights={true}
            searchParameters={searchParameters}
            placeholder={translations.placeholder}
            translations={translations.modal}
          />,
          searchContainer.current,
        )}
    </>
  );
}

export default function SearchBar() {
  const {siteConfig} = useDocusaurusContext();
  return <DocSearch {...siteConfig.themeConfig.algolia} />;
}
