--フォース・オブ・カジバシーフ
--Force of Thief
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Set Spells/Traps from your GY to your Spell/Trap Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousControler(tp) and c:GetPreviousSequence()<5 and c:IsReason(REASON_EFFECT)
		and c:GetReasonPlayer()==1-tp
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.ssfilter(c)
	return c:IsSpellTrap() and c:IsSSetable() and not c:IsType(TYPE_FIELD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ssfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.immfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHIC) and c:IsLevelAbove(7)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft>2 then ft=2 end
	local g=Duel.SelectMatchingCard(tp,s.ssfilter,tp,LOCATION_GRAVE,0,1,ft,nil)
	if #g==0 then return end
	Duel.HintSelection(g,true)
	if Duel.SSet(tp,g)>0 and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.immfilter),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.immfilter),tp,LOCATION_MZONE,0,1,3,nil)
		Duel.HintSelection(g2,true)
		local c=e:GetHandler()
		for tc in g2:Iter() do
			--Cannot be destroyed by battle
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3000)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
