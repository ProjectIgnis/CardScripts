--フォアグラシャ・ド・ヌーベルズ
--Foie Glasya de Nouvelles
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Register that it was Special Summoned by the effect of a "Nouvelles" monster
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(function(e) e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TEMP_REMOVE,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2)) end)
	c:RegisterEffect(e0)
	--Shuffle cards from the GY into the Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	--Special Summon 1 Level 5 or 6 "Nouvelles" Ritual Monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCondition(function(_,_,eg) return eg:IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) end)
	c:RegisterEffect(e3)
end
s.listed_series={SET_RECIPE,SET_NOUVELLES}
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	if not (re and re:IsMonsterEffect()) then return false end
	local rc=re:GetHandler()
	local trig_loc,trig_setcodes=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SETCODES)
	if not Duel.IsChainSolving() or (rc:IsRelateToEffect(re) and rc:IsFaceup() and rc:IsLocation(trig_loc)) then
		return rc:IsSetCard(SET_NOUVELLES)
	end
	for _,set in ipairs(trig_setcodes) do
		if (SET_NOUVELLES&0xfff)==(set&0xfff) and (SET_NOUVELLES&set)==SET_NOUVELLES then return true end
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToDeck() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e)
	if #sg==0 then return end
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
function s.cfilter(c,tp)
	return c:IsReleasableByEffect() and (s.selfnouvfilter(c,tp) or c:IsAttackPos())
end
function s.selfnouvfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(SET_NOUVELLES)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NOUVELLES) and c:IsRitualMonster() and c:IsLevel(5,6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and sg:IsExists(s.atkposchk,1,nil,sg,tp)
end
function s.atkposchk(c,sg,tp)
	return c:IsAttackPos() and sg:IsExists(s.selfnouvfilter,1,c,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if chk==0 then return #g>=2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
		and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	if #g<2 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_RELEASE)
	if Duel.Release(rg,REASON_EFFECT)==2 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,true,POS_FACEUP)
		end
	end
end