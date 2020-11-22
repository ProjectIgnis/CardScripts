--小天使テルス
--Tellus the Little Angel
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Special summon 1 token
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tkcon)
	e1:SetTarget(s.tktg)
	e1:SetOperation(s.tkop)
	c:RegisterEffect(e1)
	--Special summon 2 tokens
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id+100)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.spcost)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
	--Stats for "Tellus Wing Token"
function s.cansstk(tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
	       Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0,TYPES_TOKEN,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT)
end
	--If sent from monster zone to GY
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
end
	--Activation legality
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return rp~=tp and s.cansstk(tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
	--Special summon 1 token
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if s.cansstk(tp) then
		local token=Duel.CreateToken(tp,id+100)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
	--Banish itself from GY and 1 spell from hand as cost
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_HAND,0,1,TYPE_SPELL) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsType,tp,LOCATION_HAND,0,1,1,TYPE_SPELL)
	g:AddCard(c)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
	--Check for "Tellus Wing Token"
function s.filter(c)
	return c:IsCode(id+100) and c:IsType(TYPE_TOKEN)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0,TYPES_TOKEN,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,2,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,0)
end
	--Special summon 2 tokens, cannot special summon except from hand
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) or Duel.GetLocationCount(tp,LOCATION_MZONE)<2
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+100,0,TYPES_TOKEN,0,0,1,RACE_FAIRY,ATTRIBUTE_LIGHT) then return end
	for i=1,2 do
		local token=Duel.CreateToken(tp,id+100)
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
	--Restricted to hand
function s.splimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsLocation(LOCATION_HAND)
end
