--クシャトリラ・プリペア
--Kashtira Preparations
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Special Summon 1 "Kshatri-La" monster from hand or that is banished
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Look at the opponent's hand and banish 1 card face-down
	local e3a=Effect.CreateEffect(c)
	e3a:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3a:SetCode(EVENT_CHAINING)
	e3a:SetRange(LOCATION_SZONE)
	e3a:SetOperation(s.chainreg)
	c:RegisterEffect(e3a)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCondition(s.rmvcond)
	e3:SetTarget(s.rmvtg)
	e3:SetOperation(s.rmvop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_KASHTIRA}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_KASHTIRA) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.chainreg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 then
		c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET)|RESET_CHAIN,0,1)
	end
end
function s.rmvcond(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and re:IsTrapEffect() and c:IsStatus(STATUS_EFFECT_ENABLED) and c:HasFlagEffect(id)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_KASHTIRA),tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil,tp,POS_FACEDOWN)>0 end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g==0 then return end
	Duel.ConfirmCards(tp,g)
	if g:IsExists(Card.IsAbleToRemove,1,nil,tp,POS_FACEDOWN) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local tc=g:FilterSelect(tp,Card.IsAbleToRemove,1,1,nil,tp,POS_FACEDOWN)
		if #tc>0 then
			Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
			Duel.ShuffleHand(1-tp)
		end
	end
end