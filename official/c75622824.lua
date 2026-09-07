--トリッキーズ・マジック４
--Tricky Spell 4
local s,id=GetID()
local TOKEN_TRICKY=id+1
local CARD_THE_TRICKY=14778250
function s.initial_effect(c)
	--Send 1 face-up "The Tricky" you control to the GY; Special Summon "Tricky Tokens" (Spellcaster-Type/WIND/Level 5/ATK 2000/DEF 1200) in Defense Position, equal to the number of monsters your opponent controls. "Tricky Tokens" cannot declare an attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_THE_TRICKY,TOKEN_TRICKY}
function s.costfilter(c,tp,token_count)
	return c:IsCode(CARD_THE_TRICKY) and c:IsFaceup() and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>=token_count
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(-100)
	local token_count=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if chk==0 then return token_count>0 and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,tp,token_count) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,token_count)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local token_count=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if chk==0 then
		local cost_skip_chk=e:GetLabel()==-100 or Duel.GetLocationCount(tp,LOCATION_MZONE)>=token_count
		e:SetLabel(0)
		if token_count>=2 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
		return cost_skip_chk and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_TRICKY,0,TYPES_TOKEN,2000,1200,5,RACE_SPELLCASTER,ATTRIBUTE_WIND)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,token_count,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,token_count,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local token_count=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if token_count==0 or Duel.GetLocationCount(tp,LOCATION_MZONE)<token_count or (token_count>=2 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_TRICKY,0,TYPES_TOKEN,2000,1200,5,RACE_SPELLCASTER,ATTRIBUTE_WIND) then return end
	local c=e:GetHandler()
	for i=1,token_count do
		local token=Duel.CreateToken(tp,TOKEN_TRICKY)
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			--"Tricky Tokens" cannot declare an attack
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3206)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1,true)
		end
	end
	Duel.SpecialSummonComplete()
end