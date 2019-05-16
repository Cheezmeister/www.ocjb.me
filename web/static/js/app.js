const CLASS_TRACK_DETAILS = 'track'
const ID_NOW_PLAYING = 'nowplaying'
const ID_FAST_FORWARD = 'fast-forward'
const ID_TRACK_TITLE = 'track-title'
const ID_TRACK_ARTIST = 'track-artist'
const ID_SOURCE_GAME = 'source-game'
const ID_SOURCE_SYSTEM = 'source-system'
const ID_FIND_ANCHOR = 'find-anchor'

const trackList = document.getElementsByClassName(CLASS_TRACK_DETAILS)
const nowPlaying = document.getElementById(ID_NOW_PLAYING)
const fastForwardButton = document.getElementById(ID_FAST_FORWARD)
const nowPlayingSpan = document.getElementById(ID_TRACK_TITLE)
const trackArtistSpan = document.getElementById(ID_TRACK_ARTIST)
const sourceGameSpan = document.getElementById(ID_SOURCE_GAME)
const sourceSystemSpan = document.getElementById(ID_SOURCE_SYSTEM)
const zoomToTrackAnchor = document.getElementById(ID_FIND_ANCHOR)

let trackCount = document.getElementsByClassName(CLASS_TRACK_DETAILS).length
let currentTrackDetail;

const keyPressHandlers = {
  ' ': playOrPause,
  'n': playRandomTrack,
};

init()

function init() {
  nowPlaying.onended = playRandomTrack
  fastForwardButton.onclick = playRandomTrack
  nowPlaying.muted = window.location.search === '?quiet'
  document.addEventListener('keypress', onKeyPress)

  for (let trackDetail of trackList) {
    trackDetail.onclick = (e)=>trackClicked(trackDetail,e)
  }

  if (window.location.hash) {
    let [match, id] = window.location.hash.match(/#(track-\d+)/)
    if (id) {
      playTrack(document.getElementById(id))
      return
    }
  }
  playRandomTrack()
}

function onKeyPress(event) {
  const handler = keyPressHandlers[event.key]
  handler && handler(event) && event.preventDefault()
}

function playOrPause(e) {
  nowPlaying.paused ? nowPlaying.play() : nowPlaying.pause()
}

function trackClicked(trackDetail, event) {
  playTrack(trackDetail)
}

function playRandomTrack() {
  let trackIndex = Math.floor(Math.random() * trackCount)
  let trackDetail = document.getElementsByClassName('track')[trackIndex]
  playTrack(trackDetail)
}

function playTrack(trackDetail) {
  nowPlaying.pause()
  nowPlaying.innerHTML = ''
  let sources = trackDetail.querySelector('.srcs')
  for (let mirror of ['aplus', 'blu', 'ocrm']) {
    let source = document.createElement('source')
    source.src = sources.dataset[mirror]
    nowPlaying.appendChild(source)
    nowPlaying.src = source.src
  }
  nowPlaying.play()

  onNewTrackPlay(trackDetail)

}

function onNewTrackPlay(trackDetail) {

  zoomToTrackAnchor.href = `#${trackDetail.id}`
  nowPlayingSpan.innerHTML = trackDetail.dataset.title
  trackArtistSpan.innerHTML = trackDetail.dataset.artist
  sourceGameSpan.innerHTML = trackDetail.dataset.game
  sourceSystemSpan.innerHTML = trackDetail.dataset.system
  document.title = formatTitle(trackDetail.dataset.title)
  window.location.hash = `#${trackDetail.dataset.number}`

  if (currentTrackDetail) {
    currentTrackDetail.classList.remove('nowplaying')
  }
  currentTrackDetail = trackDetail
  trackDetail.classList.add('nowplaying')
}

function formatTitle(trackTitle) {
  return `${trackTitle} - OverClocked Jukebox`
}

