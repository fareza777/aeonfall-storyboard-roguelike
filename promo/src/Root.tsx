import React from 'react';
import {
  AbsoluteFill,
  Composition,
  Easing,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from 'remotion';
import {Audio} from '@remotion/media';

const W = 1920;
const H = 1080;
const FPS = 30;
const DURATION = 1500;

const colors = {
  ink: '#07070c',
  ink2: '#0e1018',
  bone: '#f2ede3',
  dim: '#a9afc0',
  gold: '#e8b04b',
  goldSoft: '#f2d79a',
  ember: '#ff7a34',
  frost: '#62cbea',
  volt: '#b47cf5',
  lumen: '#ffd86b',
};

const art = (name: string) => staticFile(`art/${name}`);

const fonts = `
  @font-face { font-family: Cinzel; src: url(${staticFile('fonts/Cinzel.ttf')}) format('truetype'); font-weight: 100 900; }
  @font-face { font-family: Inter; src: url(${staticFile('fonts/Inter.ttf')}) format('truetype'); font-weight: 100 900; }
  * { box-sizing: border-box; }
`;

const sceneOpacity = (frame: number, from: number, duration: number) =>
  interpolate(frame - from, [0, 18, duration - 24, duration], [0, 1, 1, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
    easing: Easing.inOut(Easing.cubic),
  });

const zoom = (frame: number, from: number, duration: number, start = 1.04, end = 1) =>
  interpolate(frame - from, [0, duration], [start, end], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

function Background({source, dark = 0.42, position = 'center'}: {source: string; dark?: number; position?: string}) {
  const frame = useCurrentFrame();
  const {durationInFrames} = useVideoConfig();
  return (
    <AbsoluteFill style={{overflow: 'hidden', backgroundColor: colors.ink}}>
      <Img
        src={art(source)}
        style={{
          width: '100%',
          height: '100%',
          objectFit: 'cover',
          objectPosition: position,
          transform: `scale(${zoom(frame, 0, durationInFrames)})`,
          filter: 'saturate(1.08) contrast(1.03)',
        }}
      />
      <AbsoluteFill style={{background: `linear-gradient(90deg, rgba(7,7,12,${Math.min(0.9, dark + 0.18)}) 0%, rgba(7,7,12,${dark}) 50%, rgba(7,7,12,${Math.min(0.88, dark + 0.18)}) 100%)`}} />
      <AbsoluteFill style={{background: 'radial-gradient(circle at 50% 52%, transparent 0%, rgba(7,7,12,.42) 86%)'}} />
    </AbsoluteFill>
  );
}

function Kicker({children, color = colors.gold}: {children: React.ReactNode; color?: string}) {
  return <div style={{fontFamily: 'Inter', color, fontSize: 22, fontWeight: 750, letterSpacing: 5, textTransform: 'uppercase'}}>{children}</div>;
}

function Headline({children, size = 76, color = colors.bone}: {children: React.ReactNode; size?: number; color?: string}) {
  return <div style={{fontFamily: 'Cinzel', color, fontSize: size, lineHeight: 1.05, letterSpacing: 1.5, textShadow: '0 8px 30px rgba(0,0,0,.65)'}}>{children}</div>;
}

function Body({children, width = 690}: {children: React.ReactNode; width?: number}) {
  return <div style={{fontFamily: 'Inter', color: colors.dim, fontSize: 27, lineHeight: 1.45, maxWidth: width, textShadow: '0 4px 18px rgba(0,0,0,.9)'}}>{children}</div>;
}

function Rule({color = colors.gold, width = 190}: {color?: string; width?: number}) {
  return <div style={{height: 2, width, background: `linear-gradient(90deg, ${color}, transparent)`, margin: '25px 0'}} />;
}

function CornerFrame({children, color = colors.gold}: {children: React.ReactNode; color?: string}) {
  return <div style={{position: 'relative', border: `1px solid ${color}99`, background: 'linear-gradient(135deg, rgba(28,33,49,.9), rgba(7,9,15,.84))', boxShadow: `0 22px 65px ${color}22`, padding: 24}}>{children}</div>;
}

function Scene({from, duration, children}: {from: number; duration: number; children: React.ReactNode}) {
  const frame = useCurrentFrame();
  return <AbsoluteFill style={{opacity: sceneOpacity(frame, from, duration), pointerEvents: 'none'}}>{children}</AbsoluteFill>;
}

function PageParticles() {
  const frame = useCurrentFrame();
  return <AbsoluteFill style={{overflow: 'hidden', pointerEvents: 'none'}}>{Array.from({length: 18}).map((_, i) => {
    const x = (i * 173) % W;
    const y = (i * 79) % H;
    const drift = Math.sin((frame + i * 21) / 36) * 26;
    const rise = ((frame * (0.7 + (i % 4) * 0.18) + i * 71) % 1200) - 120;
    return <div key={i} style={{position: 'absolute', left: x + drift, top: rise + y * .24, width: 9 + (i % 3) * 3, height: 13 + (i % 4) * 3, background: i % 3 === 0 ? colors.gold : colors.goldSoft, opacity: .22 + (i % 4) * .08, transform: `rotate(${i * 23 + frame * .8}deg)`, boxShadow: `0 0 14px ${colors.gold}`}} />;
  })}</AbsoluteFill>;
}

function SceneOne() {
  const frame = useCurrentFrame();
  const {durationInFrames} = useVideoConfig();
  const pulse = 1 + Math.sin(frame / 18) * .015;
  return <Scene from={0} duration={180}>
    <Background source="brand_splash.webp" dark={.52} />
    <PageParticles />
    <AbsoluteFill style={{justifyContent: 'center', alignItems: 'center', textAlign: 'center', transform: `scale(${pulse})`}}>
      <Kicker>F7 Developer presents</Kicker>
      <div style={{height: 26}} />
      <Headline size={118}>AEONFALL</Headline>
      <Rule width={320} />
      <div style={{fontFamily: 'Inter', color: colors.goldSoft, fontSize: 26, letterSpacing: 8}}>STORYBOARD RPG</div>
      <div style={{height: 26}} />
      <Body width={760}>Every fall rewrites the tale.</Body>
    </AbsoluteFill>
    <div style={{position: 'absolute', left: 90, bottom: 70, fontFamily: 'Inter', color: colors.dim, fontSize: 19, letterSpacing: 3}}>A NARRATIVE DECKBUILDING ROGUELITE</div>
    <div style={{position: 'absolute', right: 90, bottom: 70, fontFamily: 'Inter', color: colors.goldSoft, fontSize: 19, letterSpacing: 3}}>{String(Math.floor((frame / Math.max(1, durationInFrames)) * 100)).padStart(2, '0')} / THE NEXT DRAFT</div>
  </Scene>;
}

function SceneTwo() {
  return <Scene from={180} duration={180}>
    <Background source="brand_title_bg.webp" dark={.38} />
    <PageParticles />
    <AbsoluteFill style={{justifyContent: 'center', paddingLeft: 150}}>
      <Kicker color={colors.ember}>THE WORLD IS DRAWN IN LAYERS</Kicker>
      <div style={{height: 18}} />
      <Headline size={82}>Aevum is falling.</Headline>
      <Rule color={colors.ember} />
      <Body>Three acts. Branching routes. A story that remembers what you leave behind.</Body>
    </AbsoluteFill>
    <div style={{position: 'absolute', right: 155, bottom: 150, width: 330, height: 330, border: `1px solid ${colors.gold}66`, borderRadius: '50%', boxShadow: `0 0 90px ${colors.gold}22`}} />
  </Scene>;
}

function VesselCard({source, title, color, left, top, scale = 1}: {source: string; title: string; color: string; left: number; top: number; scale?: number}) {
  return <div style={{position: 'absolute', left, top, width: 350, transform: `scale(${scale})`, transformOrigin: 'center', border: `2px solid ${color}`, borderRadius: 18, overflow: 'hidden', background: colors.ink2, boxShadow: `0 24px 70px ${color}30`}}>
    <Img src={art(source)} style={{width: '100%', height: 390, objectFit: 'cover'}} />
    <div style={{padding: '18px 20px 21px'}}><Kicker color={color}>{title}</Kicker><div style={{fontFamily: 'Inter', color: colors.dim, fontSize: 18, marginTop: 8}}>A different way through the fall.</div></div>
  </div>;
}

function SceneThree() {
  const frame = useCurrentFrame();
  return <Scene from={360} duration={180}>
    <Background source="brand_hub_bg.webp" dark={.75} />
    <AbsoluteFill style={{padding: '76px 115px'}}>
      <Kicker color={colors.volt}>CHOOSE A VESSEL</Kicker>
      <div style={{height: 14}} />
      <Headline size={68}>Shape the deck.</Headline>
      <Body width={620}>Six Vessels. Distinct rhythms. One run that only you could have written.</Body>
    </AbsoluteFill>
    <VesselCard source="vessel_ashcaller.webp" title="ASHCALLER" color={colors.ember} left={940} top={155} scale={1 + Math.min(0.04, Math.max(0, frame - 360) / 4500)} />
    <VesselCard source="vessel_saintcoralis.webp" title="SAINT CORALIS" color={colors.frost} left={1310} top={325} scale={.82} />
    <VesselCard source="vessel_umbralnyx.webp" title="UMBRAL NYX" color={colors.volt} left={645} top={470} scale={.68} />
  </Scene>;
}

function RouteNode({x, y, color, label}: {x: number; y: number; color: string; label: string}) {
  return <div style={{position: 'absolute', left: x, top: y, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 9}}><div style={{width: 32, height: 32, borderRadius: '50%', background: `${color}44`, border: `2px solid ${color}`, boxShadow: `0 0 24px ${color}88`}} /><div style={{fontFamily: 'Inter', color: colors.dim, fontSize: 16, letterSpacing: 2}}>{label}</div></div>;
}

function SceneFour() {
  return <Scene from={540} duration={210}>
    <Background source="biome_gloamwood.webp" dark={.72} />
    <AbsoluteFill style={{padding: '80px 120px'}}>
      <Kicker color={colors.frost}>EVERY ROUTE IS A DIFFERENT DRAFT</Kicker>
      <div style={{height: 12}} />
      <Headline size={62}>Read the map.</Headline>
      <Body width={570}>Find a fight. Risk an event. Rest before the page turns again.</Body>
    </AbsoluteFill>
    <svg width={W} height={H} style={{position: 'absolute', inset: 0}} viewBox={`0 0 ${W} ${H}`}>
      <path d="M 1060 890 C 1110 760 1120 655 1220 555 C 1300 474 1315 390 1380 270" stroke={`${colors.gold}99`} strokeWidth="4" fill="none" strokeDasharray="12 13" />
      <path d="M 1110 770 C 1200 750 1330 730 1440 640 C 1510 580 1540 520 1600 450" stroke={`${colors.volt}88`} strokeWidth="3" fill="none" strokeDasharray="9 14" />
    </svg>
    <RouteNode x={1025} y={850} color={colors.gold} label="START" />
    <RouteNode x={1080} y={660} color={colors.ember} label="BATTLE" />
    <RouteNode x={1190} y={505} color={colors.frost} label="EVENT" />
    <RouteNode x={1355} y={220} color={colors.lumen} label="BOSS" />
    <RouteNode x={1450} y={590} color={colors.volt} label="REST" />
  </Scene>;
}

function CardTile({source, title, color, left, top, delay}: {source: string; title: string; color: string; left: number; top: number; delay: number}) {
  const frame = useCurrentFrame();
  const scale = spring({frame: Math.max(0, frame - delay), fps: FPS, config: {damping: 16, stiffness: 110, mass: .7}});
  return <div style={{position: 'absolute', left, top, width: 270, height: 390, transform: `scale(${Math.min(1, scale)})`, transformOrigin: 'bottom center', borderRadius: 16, overflow: 'hidden', border: `3px solid ${color}`, background: colors.ink2, boxShadow: `0 18px 45px ${color}38`}}>
    <Img src={art(source)} style={{width: '100%', height: 205, objectFit: 'cover'}} />
    <div style={{height: 54, padding: '14px 12px 0', background: `${color}20`, fontFamily: 'Cinzel', color: colors.bone, fontSize: 21, letterSpacing: 1}}>{title}</div>
    <div style={{padding: '18px 14px', fontFamily: 'Inter', color: colors.dim, fontSize: 19, lineHeight: 1.35}}>Deal damage.<br />Shape the next turn.</div>
  </div>;
}

function SceneFive() {
  const frame = useCurrentFrame();
  const turn = Math.min(100, Math.floor(((frame - 750) / 210) * 100));
  return <Scene from={750} duration={240}>
    <Background source="biome_emberreach.webp" dark={.72} />
    <AbsoluteFill style={{padding: '68px 100px'}}>
      <Kicker color={colors.ember}>PLAY THE FRAME</Kicker>
      <div style={{height: 12}} />
      <Headline size={64}>Read the enemy.</Headline>
      <Body width={660}>Every card is a sentence. Every turn is an edit.</Body>
    </AbsoluteFill>
    <CornerFrame color={colors.ember}>
      <div style={{position: 'absolute', left: 950, top: 160, width: 355, height: 355, borderRadius: 20, overflow: 'hidden', border: `2px solid ${colors.ember}`}}><Img src={art('enemy_emberling.webp')} style={{width: '100%', height: '100%', objectFit: 'cover'}} /></div>
      <div style={{position: 'absolute', left: 960, top: 535, fontFamily: 'Cinzel', color: colors.bone, fontSize: 30}}>EMBERLING</div>
      <div style={{position: 'absolute', left: 960, top: 590, width: 330, height: 20, background: '#2a0e10', border: `1px solid ${colors.ember}`, borderRadius: 20, overflow: 'hidden'}}><div style={{width: `${100 - turn * .38}%`, height: '100%', background: colors.ember}} /></div>
      <CardTile source="card_ember_ashblade.webp" title="ASHBLADE" color={colors.ember} left={1200} top={610} delay={18} />
      <CardTile source="card_frost_lance.webp" title="FROST LANCE" color={colors.frost} left={1495} top={650} delay={32} />
      <CardTile source="card_lumen_ray.webp" title="LUMEN RAY" color={colors.lumen} left={1790} top={690} delay={46} />
    </CornerFrame>
    <div style={{position: 'absolute', left: 952, top: 90, color: colors.ember, fontFamily: 'Inter', fontSize: 24, letterSpacing: 4}}>TURN 01 · BATTLE</div>
  </Scene>;
}

function SceneSix() {
  const frame = useCurrentFrame();
  const glow = .65 + Math.sin(frame / 16) * .16;
  return <Scene from={990} duration={180}>
    <Background source="event_authors_study.webp" dark={.62} />
    <AbsoluteFill style={{padding: '84px 125px'}}>
      <Kicker color={colors.lumen}>PAINT AN AURA</Kicker>
      <div style={{height: 15}} />
      <Headline size={68}>Trigger a reaction.</Headline>
      <Body width={640}>Ember. Frost. Volt. Umbra. Lumen. Combine elements to make the impossible happen.</Body>
    </AbsoluteFill>
    <div style={{position: 'absolute', left: 1120, top: 210, width: 430, height: 430, borderRadius: '50%', border: `4px solid ${colors.gold}`, boxShadow: `0 0 85px rgba(232,176,75,${glow})`, display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
      <div style={{fontFamily: 'Cinzel', fontSize: 36, color: colors.bone, letterSpacing: 2, textAlign: 'center'}}>VAPORIZE<br /><span style={{fontFamily: 'Inter', color: colors.goldSoft, fontSize: 21, letterSpacing: 4}}>DOUBLE THE HIT</span></div>
    </div>
    <div style={{position: 'absolute', right: 150, bottom: 150, display: 'flex', gap: 22}}>{[['EMBER', colors.ember], ['FROST', colors.frost], ['VOLT', colors.volt]].map(([label, color]) => <div key={label} style={{padding: '14px 22px', border: `2px solid ${color}`, borderRadius: 99, color, fontFamily: 'Inter', letterSpacing: 2, fontSize: 20}}>{label}</div>)}</div>
  </Scene>;
}

function SceneSeven() {
  const frame = useCurrentFrame();
  return <Scene from={1170} duration={180}>
    <Background source="brand_victory.webp" dark={.57} />
    <PageParticles />
    <AbsoluteFill style={{justifyContent: 'center', paddingLeft: 150}}>
      <Kicker color={colors.gold}>THE PAGE TURNS</Kicker>
      <div style={{height: 16}} />
      <Headline size={78}>One run. Twelve endings.</Headline>
      <Rule />
      <Body width={650}>Chronicles, companions, relics, and choices turn a victory into a question.</Body>
      <div style={{marginTop: 34, display: 'flex', gap: 14}}>{['MERCY', 'CRUELTY', 'COMPANIONS'].map((x, i) => <div key={x} style={{padding: '11px 16px', border: `1px solid ${[colors.frost, colors.ember, colors.volt][i]}99`, color: [colors.frost, colors.ember, colors.volt][i], fontFamily: 'Inter', letterSpacing: 2, fontSize: 17}}>{x}</div>)}</div>
    </AbsoluteFill>
    <div style={{position: 'absolute', right: 170, bottom: 140, width: 390, height: 520, transform: `rotate(${interpolate(frame, [1170, 1350], [-5, 4], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})}deg)`, border: `2px solid ${colors.gold}`, borderRadius: 18, overflow: 'hidden', boxShadow: `0 28px 70px ${colors.gold}33`}}><Img src={art('chron_unwritten_name.webp')} style={{width: '100%', height: '100%', objectFit: 'cover'}} /></div>
  </Scene>;
}

function SceneEight() {
  return <Scene from={1350} duration={150}>
    <Background source="brand_title_bg.webp" dark={.62} />
    <PageParticles />
    <AbsoluteFill style={{alignItems: 'center', justifyContent: 'center', textAlign: 'center'}}>
      <Kicker color={colors.gold}>AEONFALL: STORYBOARD RPG</Kicker>
      <div style={{height: 17}} />
      <Headline size={96}>Write the next draft.</Headline>
      <Rule width={270} />
      <Body width={770}>A narrative deckbuilding roguelite built for one more run.</Body>
      <div style={{marginTop: 38, padding: '16px 28px', border: `1px solid ${colors.gold}`, color: colors.goldSoft, fontFamily: 'Inter', letterSpacing: 4, fontSize: 20}}>DOWNLOAD · PLAY · BEGIN AGAIN</div>
    </AbsoluteFill>
    <div style={{position: 'absolute', left: 90, bottom: 70, fontFamily: 'Inter', color: colors.dim, fontSize: 17, letterSpacing: 3}}>F7 DEVELOPER</div>
  </Scene>;
}

function PromoVideo() {
  return <AbsoluteFill style={{backgroundColor: colors.ink}}>
    <style>{fonts}</style>
    <Audio src={staticFile('audio/vo_trailer.mp3')} volume={1} />
    <Audio src={staticFile('audio/mus_title.mp3')} volume={(frame) => interpolate(frame, [0, 70, 1350, 1490], [0, .12, .12, 0], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})} loop />
    <SceneOne />
    <SceneTwo />
    <SceneThree />
    <SceneFour />
    <SceneFive />
    <SceneSix />
    <SceneSeven />
    <SceneEight />
  </AbsoluteFill>;
}

export const Root = () => <>
  <Composition id="AeonfallPromo" component={PromoVideo} durationInFrames={DURATION} fps={FPS} width={W} height={H} />
</>;
