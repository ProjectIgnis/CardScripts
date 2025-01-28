--剣闘獣ダレイオス
--Gladiator Beast Dareios
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters, including a "Gladiator Beast" monster
	Link.AddProcedure(c,nil,2,2,s.lcheck)
	--Special Summon 1 Level 4 or lower "Gladiator Beast" monster from your hand or GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--"Gladiator Beast" monsters you control cannot be destroyed by battle or card effects during your opponent's Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(function(e) return Duel.IsBattlePhase() and Duel.IsTurnPlayer(1-e:GetHandlerPlayer()) end)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_GLADIATOR_BEAST))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
end
s.listed_series={SET_GLADIATOR_BEAST}
function s.lcheck(g,lc,sumtype,tp)
	return g:IsExists(Card.IsSetCard,1,nil,SET_GLADIATOR_BEAST,lc,sumtype,tp)
end
function s.spfilter(c,e,tp,opp_chk)
	return c:IsSetCard(SET_GLADIATOR_BEAST) and c:IsCanBeSpecialSummoned(e,100,tp,false,false)
		and ((c:IsLevelBelow(4) and c:IsLocation(LOCATION_HAND|LOCATION_GRAVE))
		or (opp_chk and c:IsLocation(LOCATION_DECK)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,nil,e,tp,Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE|LOCATION_DECK,0,1,1,nil,e,tp,Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0):GetFirst()
		if sc and Duel.SpecialSummon(sc,100,tp,tp,false,false,POS_FACEUP)>0 then
			sc:RegisterFlagEffect(sc:GetOriginalCode(),RESET_EVENT|RESETS_STANDARD_DISABLE,0,1)
		end
	end
	local c=e:GetHandler()
	--You cannot use monsters as Link Material for the rest of this turn, except "Gladiator Beast" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetTargetRange(0xff,0xff)
	e1:SetTarget(function(e,c) return not c:IsSetCard(SET_GLADIATOR_BEAST) end)
	e1:SetValue(function(e,c) return c and c:IsControler(e:GetHandlerPlayer()) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,1))
end