--フォース・オブ・カジバシーフ
--Force of Thief
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 spell/trap on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp) and c:GetPreviousSequence()<5
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp) and rp~=tp
end
function s.ssfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable() and not c:IsType(TYPE_FIELD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.ssfilter),tp,LOCATION_GRAVE,0,1,nil) end
end
function s.immfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHIC) and c:IsLevelAbove(7)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>2 then ft=2 end
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ssfilter),tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	Duel.HintSelection(g)
	if #g>0 then
		Duel.SSet(tp,g)
		if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.immfilter),tp,LOCATION_MZONE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.immfilter),tp,LOCATION_MZONE,0,1,3,nil)
			Duel.HintSelection(g2)
			for tc in g2:Iter() do
				local e1=Effect.CreateEffect(c)
				e1:SetDescription(3000)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
				e1:SetValue(1)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffectRush(e1)
			end
		end
	end
end
