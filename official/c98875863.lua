--Ｇゴーレム・ロックハンマー
--G Golem Rock Hammer
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Reduce this card's Level by 2
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.lvcost)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	--Tribute this card to Special Summon 3 "G Golem Tokens"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfTribute)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
s.listed_names={id+1}
function s.cfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsDiscardable()
end
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST|REASON_DISCARD,c)
end
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:HasLevel() and c:IsLevelAbove(3) end
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,c,2,0,0)
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	--Reduce Level by 2
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-2)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD|RESET_PHASE|PHASE_END)
	c:RegisterEffect(e1)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetMZoneCount(tp,e:GetHandler())>=3
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_G_GOLEM,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,0) 
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_G_GOLEM,TYPES_TOKEN,0,0,1,RACE_CYBERSE,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then
		for i=1,3 do
			local token=Duel.CreateToken(tp,id+1)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
		Duel.SpecialSummonComplete()
	end
	--Cannot Special Summon non-Cyberse monsters
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)  
end
function s.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end