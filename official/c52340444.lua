--閃刀機－ホーネットビット
--Sky Striker Mecha - Hornet Drones
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 "Sky Striker Ace Token" to your field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={52340445}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MMZONE,0)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local atk=0
	if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3 then
		atk=1500
	end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_SKY_STRIKER_ACE,TYPES_TOKEN,atk,atk,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local atk=0
	if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3 then
		atk=1500
	end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,SET_SKY_STRIKER_ACE,TYPES_TOKEN,atk,atk,1,RACE_WARRIOR,ATTRIBUTE_DARK,POS_FACEUP_DEFENSE) then return end
	local token=Duel.CreateToken(tp,id+1)
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		--Cannot be tributed
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3303)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e2)
		--Gains 1500 ATK/DEF if 3+ spells are in the GY when resolving
		if Duel.GetMatchingGroupCount(Card.IsSpell,tp,LOCATION_GRAVE,0,nil)>=3 then
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK)
			e3:SetValue(1500)
			e3:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e3)
			local e4=e3:Clone()
			e4:SetCode(EFFECT_SET_DEFENSE)
			token:RegisterEffect(e4)
		end
	end
	Duel.SpecialSummonComplete()
end