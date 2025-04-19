--阿修羅のサイコロ
--Asura Dice
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gain LP equal to targeted monster's level x 200, then return it to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.roll_dice=true
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.TossDice(tp,1)
	Duel.Damage(1-tp,d*100,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		for sc in g:Iter() do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			e1:SetValue(-d*100)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e2)
		end
		local g2=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,LOCATION_MZONE,0,nil)
		if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			for tc in g2:Iter() do
				local e3=Effect.CreateEffect(e:GetHandler())
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetCode(EFFECT_UPDATE_ATTACK)
				e3:SetValue(d*100)
				e3:SetReset(RESETS_STANDARD_PHASE_END)
				tc:RegisterEffect(e3)
				local e4=e3:Clone()
				e4:SetCode(EFFECT_UPDATE_DEFENSE)
				tc:RegisterEffect(e4)
			end
		end
	end
end