--銀河百式
--Galaxy Hundred
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Look at opponent's Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.edcon)
	e2:SetTarget(s.edtg)
	e2:SetOperation(s.edop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_GALAXYEYES_P_DRAGON}
s.listed_series={SET_PHOTON,SET_GALAXY,SET_NUMBER}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return (c:IsSetCard(SET_PHOTON) or c:IsSetCard(SET_GALAXY)) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:Select(tp,1,1,nil)
	if #tg>0 then
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
function s.edconfilter(c,tp)
	return c:IsCode(CARD_GALAXYEYES_P_DRAGON) and c:IsFaceup() and c:IsControler(tp)
end
function s.edcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.edconfilter,1,nil,tp)
end
function s.edtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_EXTRA)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_NUMBER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.edop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	local rg=g:Filter(Card.IsAbleToRemove,nil,tp,POS_FACEUP)
	local sg=g:Filter(s.spfilter,nil,e,tp)
	local b1=#rg>0
	local b2=#sg>0
	if not ((b1 or b2) and Duel.SelectYesNo(tp,aux.Stringid(id,2))) then return Duel.ShuffleExtra(1-tp) end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,3)},
		{b2,aux.Stringid(id,4)})
	--Banish 1 monster
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tg=rg:Select(tp,1,1,nil)
		if #tg==0 then return end
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	--Special Summon 1 "Number"
	elseif op==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=sg:Select(tp,1,1,nil)
		if #tg==0 then return end
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.ShuffleExtra(1-tp)
end