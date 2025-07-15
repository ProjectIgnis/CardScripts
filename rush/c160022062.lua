--焔魔の檻
--Cage of the Blaze Fiends
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make Fiends gain 500 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE|CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp) and Duel.IsTurnPlayer(1-tp)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,2,nil)
	if #g>0 then
		Duel.HintSelection(g)
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
			if Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsLevel,10),tp,LOCATION_MZONE,0,1,nil) then
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
				e3:SetDescription(3001)
				e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
				e3:SetRange(LOCATION_ONFIELD)
				e3:SetReset(RESETS_STANDARD_PHASE_END)
				e3:SetValue(1)
				tc:RegisterEffect(e3)
			end
		end
	end
end