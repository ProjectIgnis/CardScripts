--ネフティスの護り手
--Defender of Nephthys
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 card in your hand, and if you do, Special Summon 1 Level 4 or lower "Nephthys" monster from your hand, except "Defender of Nephthys"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Register when this card is destroyed
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetCode(EVENT_DESTROYED)
	e2a:SetOperation(function(e,tp) local ct=(Duel.IsTurnPlayer(tp) and Duel.IsPhase(PHASE_STANDBY)) and 2 or 1 e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,0,ct,ct) end)
	c:RegisterEffect(e2a)
	--Destroy 1 "Nephthys" monster in your Deck, except "Defender of Nephthys"
	local e2b=Effect.CreateEffect(c)
	e2b:SetDescription(aux.Stringid(id,1))
	e2b:SetCategory(CATEGORY_DESTROY)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2b:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2b:SetRange(LOCATION_GRAVE)
	e2b:SetCountLimit(1,{id,1})
	e2b:SetCondition(function(e,tp) local c=e:GetHandler() return Duel.IsTurnPlayer(tp) and c:IsReason(REASON_EFFECT) and c:HasFlagEffect(id) and (c:GetFlagEffectLabel(id)==1 or c:GetTurnID()~=Duel.GetTurnCount()) end)
	e2b:SetTarget(s.destg)
	e2b:SetOperation(s.desop)
	c:RegisterEffect(e2b)
end
s.listed_series={SET_NEPHTHYS}
s.listed_names={id}
function s.handdesfilter(c,e,tp,res_chk)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp) or res_chk
end
function s.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(SET_NEPHTHYS) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.handdesfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local res_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsExistingMatchingCard(s.handdesfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.handdesfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,res_chk)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.deckdesfilter(c)
	return c:IsSetCard(SET_NEPHTHYS) and c:IsMonster() and not c:IsCode(id)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.deckdesfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_DECK)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.deckdesfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
