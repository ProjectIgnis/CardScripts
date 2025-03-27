--Ｄ－ＨＥＲＯ ディナイアルガイ
--Destiny HERO - Denier
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--If normal or special summoned, place on top of your Deck, 1 of your "Destiny HERO" monsters that is banished, in GY, or Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Special summon itself from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,{id,1},EFFECT_COUNT_CODE_DUEL)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
	--Lists "Destiny HERO" archetype
s.listed_series={SET_DESTINY_HERO}
	--Specifically lists itself
s.listed_names={id}
	--Check for a "Destiny HERO" monster
function s.filter(c)
	return c:IsSetCard(SET_DESTINY_HERO) and c:IsMonster() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE|LOCATION_DECK))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,0,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED)
end
	--Place on top of your Deck, 1 of your "Destiny HERO" monsters that is banished, in GY, or Deck
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	if tc:IsLocation(LOCATION_DECK) then
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(tc)
	else
		Duel.HintSelection(g,true)
		Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
	if not tc:IsLocation(LOCATION_EXTRA) then
		Duel.ConfirmDecktop(tp,1)
	end
end
	--Check for a "Destiny HERO" monster
function s.spfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(SET_DESTINY_HERO) and not c:IsCode(id)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
	--Special summon itself from GY
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end