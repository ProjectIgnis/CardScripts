--ライトニング・ボルコンドル
--Lightning Voltcondor
local s,id=GetID()
function s.initial_effect(c)
	--ATK change
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.tgfilter(c,tp)
	return c:IsMonster() and c:IsAbleToGrave() and c:HasLevel()
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function s.atkfilter(c,att)
	return c:IsFaceup() and c:IsMonster() and c:IsAttribute(att) and (c:IsAttackAbove(0) or c:IsDefenseAbove(0))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if Duel.SendtoGrave(tc,REASON_COST)>0 then
		--effect
		local og=Duel.GetOperatedGroup():GetFirst()
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil,og:GetAttribute())
		if g and #g>0 then
			local lv=og:GetLevel()
			for sc in g:Iter() do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetReset(RESETS_STANDARD_PHASE_END)
				e1:SetValue(-lv*300)
				sc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				sc:RegisterEffect(e2)
			end
		end
	end
end