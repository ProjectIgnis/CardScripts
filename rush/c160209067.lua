--ガマンが限界！
--My Patience Has Run Out!
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Duel.GetLP(tp)<Duel.GetLP(1-tp) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHIC|RACE_OMEGAPSYCHIC)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	--Effect
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,2,nil)
	Duel.HintSelection(g,true)
	local tc=g:GetFirst()
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(900)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffectRush(e1)
		--Piercing
		tc:AddPiercing(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END,c)
	end
end
