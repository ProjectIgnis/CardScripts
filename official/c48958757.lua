--剣闘獣クラウディウス
--Gladiator Beast Claudius
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 5 "Gladiator Beast" monsters
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_GLADIATOR_BEAST),5)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,function(e) return not e:GetHandler():IsLocation(LOCATION_EXTRA) end,nil,1)
	--Apply a "you can conduct your next Battle Phase twice" effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e,tp) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1) and not Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) end)
	e1:SetOperation(s.doublebattlephase)
	c:RegisterEffect(e1)
	--Activate the appropriate effect, depending on whose turn it is
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(function(e,tp,eg,ep,ev,re) return ep==1-tp and re:IsMonsterEffect() end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GLADIATOR_BEAST}
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.AND(Card.IsMonster,Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
end
function s.contactop(g,tp)
	local fdg=g:Filter(Card.IsFacedown,nil)
	local gyg=g:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #fdg>0 then Duel.ConfirmCards(1-tp,fdg) end
	if #gyg>0 then Duel.HintSelection(gyg) end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL)
end
function s.doublebattlephase(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,EFFECT_BP_TWICE) then return end
	local turn_ct=Duel.GetTurnCount()
	local ct=Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() and 2 or 1
	--You can conduct your next Battle Phase twice
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_BP_TWICE)
	e1:SetTargetRange(1,0)
	e1:SetValue(1)
	e1:SetCondition(function() return ct==1 or Duel.GetTurnCount()~=turn_ct end)
	e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,ct)
	Duel.RegisterEffect(e1,tp)
end
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsCanBeSpecialSummoned(e,100,tp,false,false)
end
function s.extraspfilter(c,e,tp)
	return c:IsLevelBelow(11) and c:IsSetCard(SET_GLADIATOR_BEAST) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,100,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsTurnPlayer(tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	local b2=Duel.IsTurnPlayer(1-tp)
		and Duel.IsExistingMatchingCard(s.extraspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=b1 and 1 or 2
	local sum_loc=b1 and LOCATION_DECK or LOCATION_EXTRA
	e:SetLabel(op,sum_loc)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,sum_loc)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local op,sum_loc=e:GetLabel()
	if op==1 and Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local spfilter=op==1 and s.deckspfilter or s.extraspfilter
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,spfilter,tp,sum_loc,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,100,tp,tp,op==2,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD_DISABLE,0,0)
	end
end